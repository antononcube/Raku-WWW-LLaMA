use v6.d;

use lib '.';
use lib './lib';

use WWW::LLaMA;
use Test;

my $method = 'tiny';

plan *;

## 1
my $query = 'make a classifier with the method RandomForeset over the data dfTitanic; show precision and accuracy; plot True Positive Rate vs Positive Predictive Value.';

is llama-embedding($query, format => "values", :$method).WHAT ∈ (Array, Positional, Seq), True;

## 2
my @queries = [
        'make a classifier with the method RandomForeset over the data dfTitanic',
        'show precision and accuracy',
        'plot True Positive Rate vs Positive Predictive Value',
        'what is a good meat and potatoes recipe'
];

is llama-embedding(@queries, format => "values", :$method, encoding-format => 'base64').WHAT ∈ (Array, Positional, Seq), True;

## 3
is llama-embedding(@queries, format => "values", :$method).elems, @queries.elems;

done-testing;
