unit module WWW::LlamaFile;

use JSON::Fast;
use HTTP::Tiny;

use WWW::LlamaFile::ChatCompletions;
use WWW::LlamaFile::Embeddings;
use WWW::LlamaFile::Models;
use WWW::LlamaFile::Request;

#===========================================================
#| Gives the base URL of LlamaFile's endpoints.
our sub llamafile-base-url(-->Str) is export { return 'http://127.0.0.1:8080/v1';}


#===========================================================
#| LlamaFile chat completions access. (Synonym of llamafile-chat-completion.)
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
sub llamafile-completion(**@args, *%args) is export {
   return llamafile-chat-completion(|@args, |%args);
}


#===========================================================
#| LlamaFile chat completions access.
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
our proto llamafile-chat-completion(|) is export {*}

multi sub llamafile-chat-completion(**@args, *%args) {
    return WWW::LlamaFile::ChatCompletions::LlamaFileChatCompletion(|@args, |%args);
}

#===========================================================
#| LlamaFile embeddings access.
#| C<$prompt> -- prompt to make embeddings for;
#| C<:$model> -- model;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto llamafile-embeddings(|) is export {*}

multi sub llamafile-embeddings(**@args, *%args) {
    return WWW::LlamaFile::Embeddings::LlamaFileEmbeddings(|@args, |%args);
}

#===========================================================
#| LlamaFile models access.
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout.
our proto llamafile-models(|) is export {*}

multi sub llamafile-models(*%args) {
    return WWW::LlamaFile::Models::LlamaFileModels(|%args);
}

#============================================================
# Playground
#============================================================

#| LlamaFile playground access.
#| C<:path> -- end point path;
#| C<:api-key(:$auth-key)> -- authorization key (API key);
#| C<:timeout> -- timeout
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>,
#| C<*%args> -- additional arguments, see C<llamafile-chat-completion> and C<llamafile-text-completion>.
our proto llamafile-playground($text is copy = '',
                               Str :$path = 'completions',
                               :api-key(:$auth-key) is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny',
                               Str :$base-url = 'http://127.0.0.1:8080/v1',
                               *%args
                               ) is export {*}

#| LlamaFile playground access.
multi sub llamafile-playground(*%args) {
    return llamafile-playground('', |%args);
}

#| LlamaFile playground access.
multi sub llamafile-playground(@texts, *%args) {
    return @texts.map({ llamafile-playground($_, |%args) });
}

#| LlamaFile playground access.
multi sub llamafile-playground($text is copy,
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
            return llamafile-models(:$auth-key, :$timeout, :$method, :$base-url);
        }
        when $_ ∈ <completion completions chat/completions> {
            # my $url = 'http://127.0.0.1:8080/v1/chat/completions';
            my $expectedKeys = <model prompt max-tokens temperature top-p stream echo random-seed>;
            return llamafile-chat-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <embedding embeddings> {
            # my $url = 'http://127.0.0.1:8080/v1/embeddings';
            return llamafile-embeddings($text,
                    |%args.grep({ $_.key ∈ <model encoding-format> }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        default {
            die 'Do not know how to process the given path.';
        }
    }
}