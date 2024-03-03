#!/usr/bin/env raku
use v6.d;

use WWW::LLaMA;

say llama-text-completion(
        "What is the min speed of a rocket leaving Earth?",
        max-tokens => 90,
        temperature => 0.3,
        :cache-prompt,
        format => 'values');

say '=' x 120;

#say llama-chat-completion("What is the min speed of a rocket leaving Earth?", format => 'values', max-tokens => 90);

say llama-playground("What is the min speed of a rocket leaving Earth?", type => 'chat', format => Whatever, max-tokens => 900);
