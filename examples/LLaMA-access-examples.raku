#!/usr/bin/env raku
use v6.d;

use WWW::LLaMA;

say llama-text-completion(
        "What is the min speed of a rocket leaving Earth?",
        max-tokens => 90,
        temperature => 0.3,
        :cache-prompt,
        format => 'values');

#say llama-chat-completion("What is the min speed of a rocket leaving Earth?", format => 'values', max-tokens => 90);

#say llama-playground("What is the min speed of a rocket leaving Earth?", format => Whatever, max-tokens => 900);

#say '=' x 120;
#
#my @models = |llama-playground(path => 'models');
#
#*<id>.say for @models;
#
#say '-' x 120;
#
#say llama-playground(path => 'models', format => 'values');
#
#say '=' x 120;

#say llama-embedding('hello world'.words, format => 'values');