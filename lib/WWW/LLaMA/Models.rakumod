unit module WWW::LLaMA::Models;

use HTTP::Tiny;
use JSON::Fast;
use WWW::LLaMA::Request;


#============================================================
# Known models
#============================================================
# See : https://docs.mistral.ai/platform/endpoints

my $knownModels = Set.new(<mistral-tiny mistral-small mistral-medium mistral-embed>);


our sub llama-known-models() is export {
    return $knownModels;
}

#============================================================
# Compatibility of models and end-points
#============================================================

# See : https://docs.mistral.ai/platform/endpoints

my %endPointToModels =
        'embeddings' => <mistral-embed>,
        'chat/completions' => <mistral-tiny mistral-small mistral-medium>;

#| End-point to models retrieval.
proto sub llama-end-point-to-models(|) is export {*}

multi sub llama-end-point-to-models() {
    return %endPointToModels;
}

multi sub llama-end-point-to-models(Str $endPoint) {
    return %endPointToModels{$endPoint};
}

#| Checks if a given string an identifier of a chat completion model.
proto sub llama-is-chat-completion-model($model) is export {*}

multi sub llama-is-chat-completion-model(Str $model) {
    return $model ∈ llama-end-point-to-models{'generateMessage'};
}

#------------------------------------------------------------
# Invert to get model-to-end-point correspondence.
# At this point (2023-04-14) only the model "whisper-1" has more than one end-point.
my %modelToEndPoints = %endPointToModels.map({ $_.value.Array X=> $_.key }).flat.classify({ $_.key }).map({ $_.key => $_.value>>.value.Array });

#| Model to end-points retrieval.
proto sub llama-model-to-end-points(|) is export {*}

multi sub llama-model-to-end-points() {
    return %modelToEndPoints;
}

multi sub llama-model-to-end-points(Str $model) {
    return %modelToEndPoints{$model};
}

#============================================================
# Models
#============================================================

#| LLaMA models.
our sub LLaMAModels(
        :$format is copy = Whatever,
        Str :$method = 'tiny',
        Str :$base-url = 'http://127.0.0.1:8080/v1',
        :api-key(:$auth-key) is copy = Whatever,
        UInt :$timeout = 10) is export {
    #------------------------------------------------------
    # Process $auth-key
    #------------------------------------------------------
    # This code is repeated in other files.
    if $auth-key.isa(Whatever) {
        if %*ENV<LLAMA_API_KEY>:exists {
            $auth-key = %*ENV<LLAMA_API_KEY>;
        } else {
            note 'Cannot find Mistral.AI authorization key. ' ~
                    'Please provide a valid key to the argument auth-key, or set the ENV variable LLAMA_API_KEY.';
            $auth-key = ''
        }
    }
    die "The argument auth-key is expected to be a string or Whatever."
    unless $auth-key ~~ Str;

    #------------------------------------------------------
    # Retrieve
    #------------------------------------------------------
    my Str $url = $base-url ~ '/models';

    return llama-request(:$url, body => '', :$auth-key, :$timeout, :$format, :$method);
}
