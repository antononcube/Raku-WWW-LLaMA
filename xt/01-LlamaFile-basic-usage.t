use v6.d;

use lib '.';
use lib './lib';

use WWW::LlamaFile;
use Test;

my $method = 'tiny';

plan *;

## 1
ok llamafile-playground(path => 'models', :$method);

## 2
ok llamafile-playground('What is the most important word in English today?', :$method);

## 3
ok llamafile-playground('Generate Raku code for a loop over a list', path => 'completions', type => Whatever, model => Whatever, :$method);

## 4
ok llamafile-playground('Generate Raku code for a loop over a list', path => 'chat/completions', model => 'mistral-medium', :$method);

done-testing;
