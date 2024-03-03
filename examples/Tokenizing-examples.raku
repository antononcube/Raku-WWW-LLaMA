#!/usr/bin/env raku
use v6.d;

use WWW::LLaMA;

my $text = 'hello world';
my $res = llama-tokenize($text, format => 'values');

say $res;

my $res2 = llama-detokenize($res, format => 'asis');

say $res2;

say $text eq $res2;
say $text.trim eq $res2.trim;