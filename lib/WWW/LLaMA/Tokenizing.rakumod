
unit module WWW::LLaMA::Tokenizing;

use WWW::LLaMA::Models;
use WWW::LLaMA::Request;
use JSON::Fast;

#============================================================
# Embeddings
#============================================================

#| LLaMA (de-)tokenizing.
our proto LLaMATokenizing($prompt,
                          Str :$type = 'tokenize',
                          UInt :$timeout= 10,
                          :$format is copy = Whatever,
                          :api-key(:$auth-key) is copy = Whatever,
                          Str :$method = 'tiny',
                          Str :$base-url = 'http://127.0.0.1:8080',
                          Bool:D :$echo = False
                          ) is export {*}


#| LLaMA (de-)tokenizing.
multi sub LLaMATokenizing($prompt,
                          Str :$type is copy = 'tokenize',
                          UInt :$timeout= 10,
                          :$format is copy = Whatever,
                          :api-key(:$auth-key) is copy = Whatever,
                          Str :$method = 'tiny',
                          Str :$base-url = 'http://127.0.0.1:8080',
                          Bool:D :$echo = False) {

    #------------------------------------------------------
    # Process $type
    #------------------------------------------------------
    $type = $type.lc;
    die "The argument \$type is expected to be one of the strings 'tokenize' or 'detokenize'."
    unless $type ∈ <tokenize detokenize>;

    #------------------------------------------------------
    # LLaMA URL
    #------------------------------------------------------

    my $url = "$base-url/$type";

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    my $option = $type eq 'tokenize' ?? 'content' !! 'tokens';

    if ($prompt ~~ Positional || $prompt ~~ Seq) && $method ∈ <tiny> {

        return llama-request(:$url,
                body => to-json(%( Pair.new($option, $prompt) )),
                :$auth-key, :$timeout, :$format, :$method, :$echo);

    } else {

        return llama-request(:$url,
                body => to-json(%( Pair.new($option, $prompt) )),
                :$auth-key, :$timeout, :$format, :$method, :$echo);
    }
}
