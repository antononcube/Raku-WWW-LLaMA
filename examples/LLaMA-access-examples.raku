#!/usr/bin/env raku
use v6.d;

use lib '.';

use LLaMA;

say llama-playground("What is the min speed of a rocket leaving Earth?", format => Whatever, max-tokens => 900);

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

#say llama-embeddings('hello world'.words);