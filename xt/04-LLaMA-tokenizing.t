use v6.d;

use lib '.';
use lib './lib';

use WWW::LLaMA;
use Test;

my $method = 'tiny';

plan *;

## 1
my $query1 = 'make a classifier with the method RandomForeset over the data dfTitanic; show precision and accuracy; plot True Positive Rate vs Positive Predictive Value.';

is llama-tokenize($query1, format => "values", :$method).WHAT ∈ (Array, Positional, Seq), True;

## 2
my $res2 = llama-tokenize($query1, format => "values", :$method);
is llama-detokenize($res2, format => "values", :$method).WHAT ∈ (Str), True;

## 3
my $res3 = llama-detokenize($res2, format => "values", :$method);
is $res3.trim, $query1;

done-testing;
