unit module WWW::LLaMA;

use JSON::Fast;
use HTTP::Tiny;

use WWW::LLaMA::ChatCompletions;
use WWW::LLaMA::TextCompletions;
use WWW::LLaMA::Embeddings;
use WWW::LLaMA::Tokenizing;
use WWW::LLaMA::Models;
use WWW::LLaMA::Request;

#===========================================================
our $base-url = 'http://127.0.0.1:8080';

#| Gives or sets the base URL of the LLaMA endpoints.
our proto sub llama-base-url(|-->Str) is export {*}

multi sub llama-base-url(Str $url-->Str) {
    $base-url = $url;
    return $url;
}

multi sub llama-base-url(Whatever-->Str) is export {
    return llama-base-url('http://127.0.0.1:8080');
}

multi sub llama-base-url(-->Str) {
    return $base-url;
}


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
#| C<:$base-url> -- URL of the LLaMA server.
sub llama-completion(**@args, *%args) is export {
   return llama-chat-completion(|@args, |%args);
}

#===========================================================
#| LLaMA "simple" completion access.
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
#| C<:$base-url> -- URL of the LLaMA server.
our proto llama-text-completion(|) is export {*}

multi sub llama-text-completion(**@args, *%args) {
    return WWW::LLaMA::TextCompletions::LLaMATextCompletion(|@args, |%args);
}

#===========================================================
#| LLaMA code infill access.
#| C<:$input-prefix> -- code prefix;
#| C<:$input-suffix> -- code suffix;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
#| C<:$base-url> -- URL of the LLaMA server.
our proto llama-code-infill(|) is export {*}

multi sub llama-code-infill(*%args) {
    my %args2 = %args;
    %args2<input-prefix> = %args<input-prefix> // %args<prefix> // Whatever;
    %args2<input-suffix> = %args<input-suffix> // %args<suffix> // Whatever;
    %args2 = %args2.grep({ $_.key ∉ <prompt stream prefix suffix> });
    return WWW::LLaMA::TextCompletions::LLaMATextCompletion('', |%args2);
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
#| C<:$base-url> -- URL of the LLaMA server.
our proto llama-chat-completion(|) is export {*}

multi sub llama-chat-completion(**@args, *%args) {
    my %args2 = %args;
    %args2<base-url> = %args<base-url> // llama-base-url;
    return WWW::LLaMA::ChatCompletions::LLaMAChatCompletion(|@args, |%args2);
}

#===========================================================
#| LLaMA embeddings access.
#| C<$prompt> -- prompt to make embeddings for;
#| C<:$model> -- model;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
#| C<:$base-url> -- URL of the LLaMA server.
our proto llama-embedding(|) is export {*}

multi sub llama-embedding(**@args, *%args) {
    my %args2 = %args;
    %args2<base-url> = %args<base-url> // llama-base-url;
    return WWW::LLaMA::Embeddings::LLaMAEmbeddings(|@args, |%args2);
}

#===========================================================
#| LLaMA tokenizing access.
#| C<$prompt> -- prompt to tokenize;
#| C<:$timeout> -- timeout;
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
#| C<:$base-url> -- URL of the LLaMA server.
our proto llama-tokenize(|) is export {*}

multi sub llama-tokenize(**@args, *%args) {
    my %args2 = %args;
    %args2<base-url> = %args<base-url> // llama-base-url;
    return WWW::LLaMA::Tokenizing::LLaMATokenizing(|@args, type => 'tokenize', |%args2);
}

#===========================================================
#| LLaMA de-tokenizing access.
#| C<$prompt> -- tokens to de-tokenize;
#| C<:$timeout> -- timeout;
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
#| C<:$base-url> -- URL of the LLaMA server.
our proto llama-detokenize(|) is export {*}

multi sub llama-detokenize(**@args, *%args) {
    my %args2 = %args;
    %args2<base-url> = %args<base-url> // llama-base-url;
    return WWW::LLaMA::Tokenizing::LLaMATokenizing(|@args, type => 'detokenize', |%args2);
}

#===========================================================
#| LLaMA models access.
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout.
#| C<:$base-url> -- URL of the LLaMA server.
our proto llama-model(|) is export {*}

multi sub llama-model(*%args) {
    my %args2 = %args;
    %args2<base-url> = %args<base-url> // llama-base-url;
    return WWW::LLaMA::Models::LLaMAModels(|%args2);
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
#| C<:$base-url> -- URL of the LLaMA server.
#| C<*%args> -- additional arguments, see C<llama-chat-completion> and C<llama-text-completion>.
our proto llama-playground($text is copy = '',
                           Str :$path = 'completions',
                           :api-key(:$auth-key) is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = llama-base-url,
                           *%args
                           ) is export {*}

#| LLaMA playground access.
multi sub llama-playground(*%args) {
    return llama-playground('', |%args);
}

#| LLaMA playground access.
multi sub llama-playground($text is copy,
                           Str :$path = 'completion',
                           :api-key(:$auth-key) is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = llama-base-url,
                           *%args
                           ) {

    #------------------------------------------------------
    # Array argument handling
    #------------------------------------------------------

    if ($text ~~ Iterable) && $path.lc ∉ <de-tokenizing detokenizing detokenize de-tokenize> {
        return $text.map({ llama-playground($_, :$path, :$auth-key, :$timeout, :$format, :$method, :$base-url, |%args) });
    }

    #------------------------------------------------------
    # Dispatch
    #------------------------------------------------------
    my $paramsForAll = <$auth-key timeout format method base-url>;

    given $path.lc {
        when $_ ∈ <model models> {
            return llama-model(:$auth-key, :$timeout, :$method, :$base-url);
        }
        when $_ ∈ <chat chat/completion chat/completions> {
            # my $url = 'http://127.0.0.1:8080/v1/chat/completions';
            my $expectedKeys = <model prompt max-tokens temperature top-p stream echo random-seed>;
            return llama-chat-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <completion completions text/completion text/completions> {
            # my $url = 'https://127.0.0.1:8080/completion';
            # Find known parameters
            my $expectedKeys = &WWW::LLaMA::TextCompletions::LLaMATextCompletion.candidates.map({ $_.signature.params.map({ $_.usage-name }) }).flat;
            $expectedKeys = $expectedKeys (-) $paramsForAll;
            return llama-text-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <infill code-infill> {
            # my $url = 'https://127.0.0.1:8080/infill';
            # Find known parameters
            my $expectedKeys = &WWW::LLaMA::TextCompletions::LLaMATextCompletion.candidates.map({ $_.signature.params.map({ $_.usage-name }) }).flat;
            $expectedKeys = $expectedKeys (-) $paramsForAll;
            return llama-code-infill(
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <embedding embeddings> {
            # my $url = 'http://127.0.0.1:8080/embeddings';
            return llama-embedding($text,
                    |%args.grep({ $_.key ∈ <model encoding-format> }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <tokens tokenize tokenizing> {
            # my $url = 'http://127.0.0.1:8080/tokenize';
            return llama-tokenize($text,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <de-tokenizing detokenizing detokenize de-tokenize> {
            # my $url = 'http://127.0.0.1:8080/detokenize';
            note (:$text);
            return llama-detokenize($text,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        default {
            die 'Do not know how to process the given path.';
        }
    }
}