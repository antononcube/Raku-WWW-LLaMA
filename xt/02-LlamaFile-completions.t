use v6.d;

use lib '.';
use lib './lib';

use WWW::LlamaFile;
use Test;

my $method = 'tiny';

plan *;

## 1
ok llamafile-completion('Generate Raku code for a loop over a list', model => Whatever, :$method);

## 2
ok llamafile-completion('Generate Raku code for a loop over a list', model => 'mistral-small', :$method);

## 3
ok llamafile-completion('Generate Raku code for a loop over a list', model => Whatever, :$method);

## 4
ok llamafile-completion('Generate Raku code for a loop over a list', model => Whatever, :$method);

## 5
dies-ok {
    llamafile-completion('Generate Raku code for a loop over a list', model => 'mistral-blah-blah', :$method)
};

## 6
ok llamafile-completion('Generate Raku code for a loop over a list', model => 'mistral-medium', random-seed => 12, :$method);

done-testing;
