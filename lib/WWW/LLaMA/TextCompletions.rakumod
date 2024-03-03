use v6.d;

use WWW::LLaMA::Models;
use WWW::LLaMA::Request;
use JSON::Fast;

unit module WWW::LLaMA::TextCompletions;


#============================================================
# Completions
#============================================================

#| LLaMA completion access.
our proto LLaMATextCompletion($prompt is copy,
                              :$temperature is copy = Whatever,
                              Numeric :$top-k = 40,
                              Numeric :$top-p = 0.95,
                              Numeric :$min-p = 0.05,
                              :$max-tokens is copy = Whatever, # n_predict
                              Int :$n-keep = 0,
                              Bool :$stream = False,
                              :$stop is copy = Whatever,
                              Numeric :$tfs-z = 0,
                              Numeric :$typical-p = 0,
                              Numeric :$repeat-penalty = 0,
                              Int :$repeat-last-n = 64,
                              Bool :$penalize-nl = True,
                              Numeric :$presence-penalty = 0,
                              Numeric :$frequency-penalty = 0,
                              :$penalty-prompt is copy = Whatever,
                              UInt :$mirostat = 0,
                              Numeric :$mirostat-tau = 5.0,
                              Numeric :$mirostat-eta = 0.1,
                              :$grammar is copy = Whatever,
                              :$seed is copy = Whatever,
                              Bool :$ignore-eos = False,
                              :@logit-bias = [],
                              UInt :$n-probs = 0,
                              :@image-data = [],
                              :$slot-id is copy = Whatever,
                              Bool :$cache-prompt = False,
                              :$system-prompt is copy = Whatever,
                              :$input-prefix is copy = Whatever,
                              :$input-suffix is copy = Whatever,
                              Bool :$echo = False,
                              :api-key(:$auth-key) is copy = Whatever,
                              :$model is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'http://127.0.0.1:8080') is export {*}

#| LLaMA completion access.
multi sub LLaMATextCompletion(@prompts, *%args) {
    return @prompts.map({ LLaMATextCompletion($_, |%args) }).Array;
}

#| LLaMA completion access.
multi sub LLaMATextCompletion($prompt is copy,
                              :$temperature is copy = Whatever,
                              Numeric :$top-k = 40,
                              Numeric :$top-p = 0.95,
                              Numeric :$min-p = 0.05,
                              :$max-tokens is copy = Whatever, # n_predict
                              Int :$n-keep = 0,
                              Bool :$stream = False,
                              :$stop is copy = Whatever,
                              Numeric :$tfs-z = 0,
                              Numeric :$typical-p = 0,
                              Numeric :$repeat-penalty = 0,
                              Int :$repeat-last-n = 64,
                              Bool :$penalize-nl = True,
                              Numeric :$presence-penalty = 0,
                              Numeric :$frequency-penalty = 0,
                              :$penalty-prompt is copy = Whatever,
                              UInt :$mirostat = 0,
                              Numeric :$mirostat-tau = 5.0,
                              Numeric :$mirostat-eta = 0.1,
                              :$grammar is copy = Whatever,
                              :$seed is copy = Whatever,
                              Bool :$ignore-eos = False,
                              :@logit-bias = [],
                              UInt :$n-probs = 0,
                              :@image-data = [],
                              :$slot-id is copy = Whatever,
                              Bool :$cache-prompt = False,
                              :$system-prompt is copy = Whatever,
                              :$input-prefix is copy = Whatever,
                              :$input-suffix is copy = Whatever,
                              Bool :$echo = False,
                              :api-key(:$auth-key) is copy = Whatever,
                              :$model is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'http://127.0.0.1:8080') {

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'gpt-3.5-turbo'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ llama-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ llama-known-models;

    #------------------------------------------------------
    # Process $temperature
    #------------------------------------------------------
    if $temperature.isa(Whatever) { $temperature = 0.8; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 2."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 2;

    #------------------------------------------------------
    # Process $top-k
    #------------------------------------------------------
    if $top-k.isa(Whatever) { $top-k = 40; }
    die "The argument \$top-k is expected to be Whatever or a non-negatice integer."
    unless $top-k ~~ Int && 0 ≤ $top-k;

    #------------------------------------------------------
    # Process $top-p
    #------------------------------------------------------
    if $top-p.isa(Whatever) { $top-p = 0.95 }
    die "The argument \$top-p is expected to be Whatever or number between 0 and 1."
    unless $top-p ~~ Numeric && 0 ≤ $top-p ≤ 1;

    #------------------------------------------------------
    # Process $min-p
    #------------------------------------------------------
    if $min-p.isa(Whatever) { $min-p = 0.05; }
    die "The argument \$min-p is expected to be Whatever or number between 0 and 1."
    unless $min-p ~~ Numeric && 0 ≤ $min-p ≤ 1;

    #------------------------------------------------------
    # Process $max-tokens
    #------------------------------------------------------
    # Corresponds to llamafile's n_predict
    if $max-tokens.isa(Whatever) { $max-tokens = -1; }
    die "The argument \$max-tokens is expected to be Whatever or an integer greater or equal to -1."
    unless $max-tokens ~~ Int && -1 ≤ $max-tokens;

    #------------------------------------------------------
    # Process $n-keep
    #------------------------------------------------------
    die "The argument \$n-keep is expected to be an integer greater or equal to -1."
    unless -1 ≤ $n-keep;

    #------------------------------------------------------
    # Process $stream
    #------------------------------------------------------
    die "The argument \$stream is expected to be Boolean."
    unless $stream ~~ Bool;

    #------------------------------------------------------
    # Process $echo
    #------------------------------------------------------
    die "The argument \$echo is expected to be Boolean."
    unless $echo ~~ Bool;

    #------------------------------------------------------
    # Process $stop
    #------------------------------------------------------
    if !$stop.isa(Whatever) {
        die "The argument \$stop is expected to be a string, a list strings, or Whatever."
        unless $stop ~~ Str || $stop ~~ Positional && $stop.all ~~ Str;
    }

    $stop = do given $stop {
        when Str:D { [$_, ]}
        when Empty { Whatever }
        when $_ ~~ Positional && $_.elems { $_ }
        when $_ ~~ Iterable   && $_.elems { $_.Array }
        default { Whatever }
    }

    #------------------------------------------------------
    # Process $presence-penalty
    #------------------------------------------------------
    die "The argument \$presence-penalty is expected to be Boolean."
    unless $presence-penalty ~~ Numeric && -2 ≤ $presence-penalty ≤ 2;

    #------------------------------------------------------
    # Process $frequency-penalty
    #------------------------------------------------------
    die "The argument \$frequency-penalty is expected to be Boolean."
    unless $frequency-penalty ~~ Numeric && -2 ≤ $frequency-penalty ≤ 2;


    #------------------------------------------------------
    # Process $system-prompt
    #------------------------------------------------------
    if $system-prompt.isa(Whatever) { $system-prompt = {}; }
    die "The argument \$system-prompt is expected to be Hash or Whatever."
    unless $system-prompt ~~ Hash:D;


    #------------------------------------------------------
    # Process $input-prefix
    #------------------------------------------------------
    if !$input-prefix.isa(Whatever) {
        die "The argument \$input-prefix is expected to be a string or Whatever."
        unless $input-prefix ~~ Str;
    }

    #------------------------------------------------------
    # Process $input-suffix
    #------------------------------------------------------
    if !$input-suffix.isa(Whatever) {
        die "The argument \$input-suffix is expected to be a string or Whatever."
        unless $input-suffix ~~ Str;
    }

    #------------------------------------------------------
    # Make LLaMA(file) URL
    #------------------------------------------------------

    my %body = :$prompt,
               cache_prompt => $cache-prompt,
               system_prompt => $system-prompt,
               n_predict => $max-tokens, :$temperature,
               top_k => $top-k, top_p => $top-p, min_p => $min-p,
               n_keep => $n-keep,
               penalize_nl => $penalize-nl,
               :$stream, :$echo,
               :$mirostat, mirostat_eta => $mirostat-eta, mirostat_tau => $mirostat-tau,
               presence_penalty => $presence-penalty,
               frequency_penalty => $frequency-penalty;

    if !$stop.isa(Whatever) { %body<stop> = $stop; }
    if !$input-prefix.isa(Whatever) { %body<input_prefix> = $input-prefix; }
    if !$input-suffix.isa(Whatever) { %body<input_suffix> = $input-suffix; }
    if !$penalty-prompt.isa(Whatever) { %body<penalty_prompt> = $penalty-prompt; }
    if @image-data { %body<image_data> = @image-data; }

    my $url;
    if !$input-prefix.isa(Whatever) || !$input-suffix.isa(Whatever) {
        # For code infill drop prompt and stream
        %body = %body.grep({ $_.key ∉ <stream prompt> });
        $url = $base-url ~ '/infill';
    } else {
        $url = $base-url ~ '/completion';
    }


    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return llama-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
