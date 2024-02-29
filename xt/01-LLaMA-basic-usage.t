use v6.d;

use lib '.';
use lib './lib';

use LLaMA;
use Test;

my $method = 'tiny';

plan *;

## 1
ok llama-playground(path => 'models', :$method);

## 2
ok llama-playground('What is the most important word in English today?', :$method);

## 3
ok llama-playground('Generate Raku code for a loop over a list', path => 'completions', type => Whatever, model => Whatever, :$method);

## 4
ok llama-playground('Generate Raku code for a loop over a list', path => 'chat/completions', model => 'mistral-medium', :$method);

done-testing;
