unit module WWW::LLaMA;

use JSON::Fast;
use HTTP::Tiny;

use WWW::LLaMA::ChatCompletions;
use WWW::LLaMA::Embeddings;
use WWW::LLaMA::Models;
use WWW::LLaMA::Request;

#===========================================================
#| Gives the base URL of llamafile's endpoints.
our sub llama-base-url(-->Str) is export { return 'http://127.0.0.1:8080/v1';}


#===========================================================
#| LLaMA chat completions access. (Synonym of llama-chat-completion.)
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$stream> -- whether to stream the result or not;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
sub llama-completion(**@args, *%args) is export {
   return llama-chat-completion(|@args, |%args);
}


#===========================================================
#| LLaMA chat completions access.
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$stream> -- whether to stream the result or not;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto llama-chat-completion(|) is export {*}

multi sub llama-chat-completion(**@args, *%args) {
    return WWW::LLaMA::ChatCompletions::LLaMAChatCompletion(|@args, |%args);
}

#===========================================================
#| LLaMA embeddings access.
#| C<$prompt> -- prompt to make embeddings for;
#| C<:$model> -- model;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto llama-embeddings(|) is export {*}

multi sub llama-embeddings(**@args, *%args) {
    return WWW::LLaMA::Embeddings::LLaMAEmbeddings(|@args, |%args);
}

#===========================================================
#| LLaMA models access.
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout.
our proto llama-models(|) is export {*}

multi sub llama-models(*%args) {
    return WWW::LLaMA::Models::LLaMAModels(|%args);
}

#============================================================
# Playground
#============================================================

#| LLaMA playground access.
#| C<:path> -- end point path;
#| C<:api-key(:$auth-key)> -- authorization key (API key);
#| C<:timeout> -- timeout
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>,
#| C<*%args> -- additional arguments, see C<llama-chat-completion> and C<llama-text-completion>.
our proto llama-playground($text is copy = '',
                           Str :$path = 'completions',
                           :api-key(:$auth-key) is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = 'http://127.0.0.1:8080/v1',
                           *%args
                           ) is export {*}

#| LLaMA playground access.
multi sub llama-playground(*%args) {
    return llama-playground('', |%args);
}

#| LLaMA playground access.
multi sub llama-playground(@texts, *%args) {
    return @texts.map({ llama-playground($_, |%args) });
}

#| LLaMA playground access.
multi sub llama-playground($text is copy,
                           Str :$path = 'completions',
                           :api-key(:$auth-key) is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = 'http://127.0.0.1:8080/v1',
                           *%args
                           ) {

    #------------------------------------------------------
    # Dispatch
    #------------------------------------------------------
    given $path.lc {
        when $_ eq 'models' {
            # my $url = 'http://127.0.0.1:8080/v1/models';
            return llama-models(:$auth-key, :$timeout, :$method, :$base-url);
        }
        when $_ ∈ <completion completions chat/completions> {
            # my $url = 'http://127.0.0.1:8080/v1/chat/completions';
            my $expectedKeys = <model prompt max-tokens temperature top-p stream echo random-seed>;
            return llama-chat-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <embedding embeddings> {
            # my $url = 'http://127.0.0.1:8080/v1/embeddings';
            return llama-embeddings($text,
                    |%args.grep({ $_.key ∈ <model encoding-format> }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        default {
            die 'Do not know how to process the given path.';
        }
    }
}