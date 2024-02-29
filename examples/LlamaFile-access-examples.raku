#!/usr/bin/env raku
use v6.d;

use lib '.';

use WWW::LlamaFile;

say llamafile-playground("What is the min speed of a rocket leaving Earth?", format => Whatever, max-tokens => 900);

#say llamafile-playground("What is the min speed of a rocket leaving Earth?", format => Whatever, max-tokens => 900);

#say '=' x 120;
#
#my @models = |llamafile-playground(path => 'models');
#
#*<id>.say for @models;
#
#say '-' x 120;
#
#say llamafile-playground(path => 'models', format => 'values');
#
#say '=' x 120;

#say llamafile-embeddings('hello world'.words);