
unit module WWW::LLaMA::Embeddings;

use WWW::LLaMA::Models;
use WWW::LLaMA::Request;
use JSON::Fast;

#============================================================
# Embeddings
#============================================================

#| LLaMA embeddings.
our proto LLaMAEmbeddings($prompt,
                          :@image-data = [],
                          :$model = Whatever,
                          :$encoding-format = Whatever,
                          Bool:D :$batched = False,
                          :api-key(:$auth-key) is copy = Whatever,
                          UInt :$timeout= 10,
                          :$format is copy = Whatever,
                          Str :$method = 'tiny',
                          Str :$base-url = 'http://127.0.0.1:8080',
                          Bool:D :$echo = False,
                          ) is export {*}

#| LLaMA embeddings.
multi sub LLaMAEmbeddings($prompt,
                          :@image-data = [],
                          :$model is copy = Whatever,
                          :$encoding-format is copy = Whatever,
                          Bool:D :$batched = False,
                          :api-key(:$auth-key) is copy = Whatever,
                          UInt :$timeout= 10,
                          :$format is copy = Whatever,
                          Str :$method = 'tiny',
                          Str :$base-url = 'http://127.0.0.1:8080',
                          Bool:D :$echo = False,
                          ) {

    if !$batched && $prompt ~~ (Array | List | Seq) {
        return $prompt.map({
            LLaMAEmbeddings($_, :@image-data, :$model, :$encoding-format, :$batched, :$auth-key, :$timeout, :$format, :$method, :$base-url, :$echo)
        })
    }

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'llama-embedding'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ llama-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ llama-known-models;

    #------------------------------------------------------
    # Process $encoding-format
    #------------------------------------------------------
    if $encoding-format.isa(Whatever) { $encoding-format = 'float'; }
    die "The argument \$encoding-format is expected to be Whatever or one of the strings 'float' or 'base64'."
    unless $encoding-format ~~ Str && $encoding-format.lc ∈ <float base64>;

    #------------------------------------------------------
    # LLaMA URL
    #------------------------------------------------------

    # The option $batched is used for compatibility with &llm-embedding from "LLM::Functions".
    # The default value of :$batched, False, is also for compatibility with &llm-embedding.
    # The previous name of :$batched was :$array-content.
    # That is an adapter option:
    # - Some LLaMA models want the "content" key to be an array of strings
    # - Some want it to be a string
    my %body = content => $batched ?? $prompt.Array !! $prompt;
    if @image-data {
       %body<image_data> = @image-data;
    }

    my $url = $base-url ~ '/embedding';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    if ($prompt ~~ Positional || $prompt ~~ Seq) && $method ∈ <tiny> {

        return llama-request(:$url,
                body => to-json(%body),
                :$auth-key, :$timeout, :$format, :$method, :$echo);

    } else {

        return llama-request(:$url,
                body => to-json(%body),
                :$auth-key, :$timeout, :$format, :$method, :$echo);
    }
}
