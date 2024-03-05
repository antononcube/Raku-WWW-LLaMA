unit module WWW::LLaMA::ChatCompletions;

use WWW::LLaMA::Models;
use WWW::LLaMA::Request;
use JSON::Fast;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);


#============================================================
# Completions
#============================================================

# In order to understand the design of [role => message,] argument see:
# https://docs.mistral.ai/api/#operation/createChatCompletion


#| LLaMA completion access.
our proto LLaMAChatCompletion($prompt is copy,
                              :$role is copy = Whatever,
                              :$model is copy = Whatever,
                              :$temperature is copy = Whatever,
                              :$max-tokens is copy = Whatever,
                              Numeric :$top-p = 1,
                              Bool :$stream = False,
                              :$random-seed is copy = Whatever,
                              :api-key(:$auth-key) is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'http://127.0.0.1:8080') is export {*}

#| LLaMA completion access.
multi sub LLaMAChatCompletion(Str $prompt, *%args) {
    return LLaMAChatCompletion([$prompt,], |%args);
}

#| LLaMA completion access.
multi sub LLaMAChatCompletion(@prompts is copy,
                              :$role is copy = Whatever,
                              :$model is copy = Whatever,
                              :$temperature is copy = Whatever,
                              :$max-tokens is copy = Whatever,
                              Numeric :$top-p = 1,
                              Bool :$stream = False,
                              :$random-seed is copy = Whatever,
                              :api-key(:$auth-key) is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'http://127.0.0.1:8080') {

    #------------------------------------------------------
    # Process $role
    #------------------------------------------------------
    if $role.isa(Whatever) { $role = "user"; }
    die "The argument \$role is expected to be Whatever or one of the strings: { '"' ~ $knownRoles.keys.sort.join('", "') ~ '"' }."
    unless $role ∈ $knownRoles;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'gpt-3.5-turbo'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ llama-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ llama-known-models;

    #------------------------------------------------------
    # Process $temperature
    #------------------------------------------------------
    if $temperature.isa(Whatever) { $temperature = 0.7; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 2."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 2;

    #------------------------------------------------------
    # Process $max-tokens
    #------------------------------------------------------
    if $max-tokens.isa(Whatever) { $max-tokens = -1; }
    die "The argument \$max-tokens is expected to be Whatever or an integer greater than -1."
    unless $max-tokens ~~ Int && -1 ≤ $max-tokens;

    #------------------------------------------------------
    # Process $top-p
    #------------------------------------------------------
    if $top-p.isa(Whatever) { $top-p = 1.0; }
    die "The argument \$top-p is expected to be Whatever or number between 0 and 1."
    unless $top-p ~~ Numeric && 0 ≤ $top-p ≤ 1;

    #------------------------------------------------------
    # Process $stream
    #------------------------------------------------------
    die "The argument \$stream is expected to be Boolean."
    unless $stream ~~ Bool;

    #------------------------------------------------------
    # Process $random-seed
    #------------------------------------------------------
    die "The argument \$random-seed is expected to be a integer or Whatever."
    unless $random-seed.isa(Whatever) || $random-seed ~~ Int;

    #------------------------------------------------------
    # Messages
    #------------------------------------------------------
    my @messages = @prompts.map({
        if $_ ~~ Pair {
            %(role => $_.key, content => $_.value)
        } else {
            %(:$role, content => $_)
        }
    });

    #------------------------------------------------------
    # Make LLaMA URL
    #------------------------------------------------------

    my %body = :$model, :$temperature, :$stream,
               top_p => $top-p,
               :@messages,
               max_tokens => $max-tokens;

    if $random-seed ~~ Int:D {
        %body.push('random_seed' => $random-seed);
    }

    my $url = $base-url ~ '/v1/chat/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return llama-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
