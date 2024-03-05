#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use WWW::LLaMA;

my $base-url = 'http://127.0.0.1:5060';
llama-base-url($base-url);

say llama-completion(
        "What is the population of Brazil?",
        max-tokens => 90,
        temperature => 0.3,
        format => 'values');

#========================================================================================================================
say '=' x 120;

#say llama-chat-completion("What is the min speed of a rocket leaving Earth?", format => 'values', max-tokens => 90);

say llama-playground(
        "What is the min speed of a rocket leaving Earth?",
        type => 'chat',
        format => Whatever,
        max-tokens => 900);

#========================================================================================================================
say '=' x 120;

say llama-model;