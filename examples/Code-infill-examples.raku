#!/usr/bin/env raku
use v6.d;

use WWW::LLaMA;

# Python code infill
say llama-code-infill(
        prefix => 'def remove_non_ascii(s):',
        format => 'values',
        max-tokens => 4096,
        temperature => 0.12
    );