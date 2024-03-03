#!/usr/bin/env raku
use v6.d;

use WWW::LLaMA;
use Image::Markup::Utilities;

my $url ='https://i.imgur.com/dtNEeHU.png';

my $img = image-import($url, format => 'asis');

my $res = llama-text-completion(
        "USER:[img-12]Describe the image.\nASSISTANT:",
        image-data => [{data => $img, id => 12},],
        temperature => 0.16,
        format => 'values');

say $res;