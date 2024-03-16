# WWW::LLaMA

## In brief

This Raku package provides access to the machine learning service [llamafile](https://github.com/mozilla-Ocho/llamafile), [MO1].
For more details of the llamafile's API usage see [the documentation](https://github.com/mozilla-Ocho/llamafile?tab=readme-ov-file), [MO2].

This package is very similar to the packages 
["WWW::OpenAI"](https://github.com/antononcube/Raku-WWW-OpenAI), [AAp1], and 
["WWW::MistralAI"](https://github.com/antononcube/Raku-WWW-MistralAI), [AAp2]. 

"WWW::LLaMA" can be used with (is integrated with) 
["LLM::Functions"](https://github.com/antononcube/Raku-LLM-Functions), [AAp3], and
["Jupyter::Chatbook"](https://github.com/antononcube/Raku-Jupyter-Chatbook), [AAp5].

Also, of course, prompts from 
["LLM::Prompts"](https://github.com/antononcube/Raku-LLM-Prompts), [AAp4],
can be used with LLaMA's functions.

**Remark:** The package "WWW::OpenAI" can be also used to access 
["llamafile" chat completions](https://github.com/Mozilla-Ocho/llamafile/blob/main/llama.cpp/server/README.md#api-endpoints).
That is done by specifying appropriate base URL to the `openai-chat-completion` function.

-----

## Installation

Package installations from both sources use [zef installer](https://github.com/ugexe/zef)
(which should be bundled with the "standard" Rakudo installation file.)

To install the package from [Zef ecosystem](https://raku.land/) use the shell command:

```
zef install WWW::LLaMA
```

To install the package from the GitHub repository use the shell command:

```
zef install https://github.com/antononcube/Raku-WWW-LLaMA.git
```

----

## Install and run LLaMA server

In order to use the package access to LLaMA server is required.

Since the package follows closely the Web API of ["llamafile"](https://github.com/Mozilla-Ocho/llamafile/), [MO1],
it is advised to follow first the installation steps in the section of ["Quickstart"](https://github.com/Mozilla-Ocho/llamafile/tree/main#quickstart)
of [MO1] before trying the functions of the package.

----

## Usage examples

**Remark:** When the authorization key, `auth-key`, is specified to be `Whatever`
then it is assigned the string `sk-no-key-required`.
If an authorization key is required then the env variable `LLAMA_API_KEY` can be also used.

### Universal "front-end"

The package has an universal "front-end" function `llama-playground` for the 
[different functionalities provided by llamafile](https://github.com/Mozilla-Ocho/llamafile/blob/main/README.md).

Here is a simple call for a "chat completion":

```perl6
use WWW::LLaMA;
llama-playground('What is the speed of a rocket leaving Earth?');
```
```
# {content =>  The speed of, generation_settings => {frequency_penalty => 0, grammar => , ignore_eos => False, logit_bias => [], min_p => 0.05000000074505806, mirostat => 0, mirostat_eta => 0.10000000149011612, mirostat_tau => 5, model => mistral-7b-instruct-v0.2.Q5_K_M.gguf, n_ctx => 4096, n_keep => 0, n_predict => -1, n_probs => 0, penalize_nl => True, penalty_prompt_tokens => [], presence_penalty => 0, repeat_last_n => 64, repeat_penalty => 1.100000023841858, seed => 4294967295, stop => [], stream => False, temperature => 0.800000011920929, tfs_z => 1, top_k => 40, top_p => 0.949999988079071, typical_p => 1, use_penalty_prompt_tokens => False}, model => mistral-7b-instruct-v0.2.Q5_K_M.gguf, prompt => What is the speed of a rocket leaving Earth?, slot_id => 0, stop => True, stopped_eos => False, stopped_limit => True, stopped_word => False, stopping_word => , timings => {predicted_ms => 150.268, predicted_n => 3, predicted_per_second => 19.964330396358505, predicted_per_token_ms => 50.089333333333336, prompt_ms => 188.056, prompt_n => 12, prompt_per_second => 63.810779767728754, prompt_per_token_ms => 15.671333333333335}, tokens_cached => 14, tokens_evaluated => 12, tokens_predicted => 3, truncated => False}
```

Another one using Bulgarian:

```perl6
llama-playground('Колко групи могат да се намерят в този облак от точки.', max-tokens => 300, random-seed => 234232, format => 'values');
```
```
# A cloud that has a spherical shape with a diameter of 10 meters and a density of 1 g/m$^3$ contains water droplets. The average mass of each water droplet is 10$^{-6}$ kg. How many droplets are there in the cloud?
# 
# To find the number of droplets in the cloud, we first need to find the volume of the cloud and then use that to calculate the number of droplets.
# 
# The formula for the volume of a sphere is:
# 
# $V = \frac{4}{3}πr^3$
# 
# where r is the radius of the sphere. In this case, the diameter is given as 10 meters, so the radius is half of that:
# 
# $r = \frac{diameter}{2} = \frac{10}{2} = 5\ m$
# 
# Now we can calculate the volume of the cloud:
# 
# $V = \frac{4}{3}π(5)^3 = \frac{4}{3}π(125) = 523.6\ m^3$
# 
# Next, we need to find the mass of water in the cloud. Since the density is given as 1 g/m$^3$, the mass of water in the cloud is:
# 
# $M = \rho V = 1\
```

**Remark:** The functions `llama-chat-completion` or `llama-completion` can be used instead in the examples above.
(The latter is synonym of the former.)


### Models

The current LLaMA model can be found with the function `llama-model`:

```perl6
llama-model;
```
```
# mistral-7b-instruct-v0.2.Q5_K_M.gguf
```

**Remark:** Since there is no dedicated API endpoint for getting the model(s),
the current model is obtained via "simple" (non-chat) completion.

### Code generation

There are two types of completions : text and chat. Let us illustrate the differences
of their usage by Raku code generation. Here is a text completion:

```perl6
llama-text-completion(
        'generate Raku code for making a loop over a list',
        max-tokens => 120,
        format => 'values');
```
```
# and print the cube of each number in that list
# 
# ```raku
# my @numbers = <1 2 3 4 5>;
# 
# for ^@numbers -> $number {
#     say $number**3;
# }
# ```
# 
# This Raku code creates a list `@numbers` with five elements, then uses a for loop to iterate over each element in the list. The variable `$number` represents the current number being processed during the iteration. The caret (`^`) before `@numbers`
```

Here is a chat completion:

```perl6
llama-completion(
        'generate Raku code for making a loop over a list',
        max-tokens => 120,
        format => 'values');
```
```
# Here's a simple example of how you can loop over a list in Raku:
# 
# ```raku
# my @list = (1, 2, 3, 4, 5); # Initialize a list
# 
# for my $element @list {
#     say "Element is: ", $element; # Do something with each element
# }
# ```
# In this example, `@list` is the list that we want to loop over. The `for` loop goes through each element in the list and assigns it to the variable `$element
```


### Embeddings

Embeddings can be obtained with the function `llama-embedding`. Here is an example of finding the embedding vectors
for each of the elements of an array of strings:

```perl6
my @queries = [
    'make a classifier with the method RandomForeset over the data dfTitanic',
    'show precision and accuracy',
    'plot True Positive Rate vs Positive Predictive Value',
    'what is a good meat and potatoes recipe'
];

my $embs = llama-embedding(@queries, format => 'values', method => 'tiny');
$embs.elems;
```
```
# 4
```

Here we show:
- That the result is an array of four vectors each with length 1536
- The distributions of the values of each vector

```perl6
use Data::Reshapers;
use Data::Summarizers;

say "\$embs.elems : { $embs.elems }";
say "\$embs>>.elems : { $embs>>.elems }";
records-summary($embs.kv.Hash.&transpose);
```
```
# $embs.elems : 4
# $embs>>.elems : 4096 4096 4096 4096
# +---------------------------------+----------------------------------+----------------------------------+--------------------------------+
# | 1                               | 3                                | 0                                | 2                              |
# +---------------------------------+----------------------------------+----------------------------------+--------------------------------+
# | Min    => -115.55949401855469   | Min    => -86.64485931396484     | Min    => -150.1730194091797     | Min    => -85.12604522705078   |
# | 1st-Qu => -2.5787762403488159   | 1st-Qu => -3.18321657180786135   | 1st-Qu => -3.1311671733856201    | 1st-Qu => -3.4018837213516235  |
# | Mean   => -0.019579125041847334 | Mean   => -0.0953787748984638    | Mean   => -0.0024599628797898794 | Mean   => -0.02784229526803017 |
# | Median => 0.02638726681470871   | Median => -0.0252206642180681235 | Median => 0.0594599936157465     | Median => -0.12382630631327629 |
# | 3rd-Qu => 2.6268826723098755    | 3rd-Qu => 3.0144025087356568     | 3rd-Qu => 3.3026289939880372     | 3rd-Qu => 3.31683588027954105  |
# | Max    => 34.61551284790039     | Max    => 78.72677612304688      | Max    => 53.90862274169922      | Max    => 43.39240646362305    |
# +---------------------------------+----------------------------------+----------------------------------+--------------------------------+
```

Here we find the corresponding dot products and (cross-)tabulate them:

```perl6
use Data::Reshapers;
use Data::Summarizers;
my @ct = (^$embs.elems X ^$embs.elems).map({ %( i => $_[0], j => $_[1], dot => sum($embs[$_[0]] >>*<< $embs[$_[1]])) }).Array;

say to-pretty-table(cross-tabulate(@ct, 'i', 'j', 'dot'), field-names => (^$embs.elems)>>.Str);
```
```
# +---+---------------+---------------+---------------+---------------+
# |   |       0       |       1       |       2       |       3       |
# +---+---------------+---------------+---------------+---------------+
# | 0 | 149739.714274 |  43728.546745 |  45860.578925 |  32184.330663 |
# | 1 |  43728.546745 | 102867.905887 |  46243.876793 |  38526.293732 |
# | 2 |  45860.578925 |  46243.876793 | 133800.798610 |  31927.097299 |
# | 3 |  32184.330663 |  38526.293732 |  31927.097299 | 127918.331646 |
# +---+---------------+---------------+---------------+---------------+
````

**Remark:** Note that the fourth element (the cooking recipe request) is an outlier.
(Judging by the table with dot products.)

### Tokenizing and de-tokenizing

Here we tokenize some text:

```perl6
my $txt = @queries.head;
my $res = llama-tokenize($txt, format => 'values');
```
```
# [1038 264 875 3591 395 272 2038 20575 28765 3626 299 754 272 1178 13808 28738 11374 294]
```

Here we get the original text be de-tokenizing:

```perl6
llama-detokenize($res);
```
```
# {content =>  make a classifier with the method RandomForeset over the data dfTitanic}
```

### Chat completions with engineered prompts

Here is a prompt for "emojification" (see the
[Wolfram Prompt Repository](https://resources.wolframcloud.com/PromptRepository/)
entry
["Emojify"](https://resources.wolframcloud.com/PromptRepository/resources/Emojify/)):

```perl6
my $preEmojify = q:to/END/;
Rewrite the following text and convert some of it into emojis.
The emojis are all related to whatever is in the text.
Keep a lot of the text, but convert key words into emojis.
Do not modify the text except to add emoji.
Respond only with the modified text, do not include any summary or explanation.
Do not respond with only emoji, most of the text should remain as normal words.
END
```
```
# Rewrite the following text and convert some of it into emojis.
# The emojis are all related to whatever is in the text.
# Keep a lot of the text, but convert key words into emojis.
# Do not modify the text except to add emoji.
# Respond only with the modified text, do not include any summary or explanation.
# Do not respond with only emoji, most of the text should remain as normal words.
```

Here is an example of chat completion with emojification:

```perl6
llama-chat-completion([ system => $preEmojify, user => 'Python sucks, Raku rocks, and Perl is annoying'], max-tokens => 200, format => 'values')
```
```
# Python 🙁, Raku 😍, Perl 🙄
```

-------

## Command Line Interface

### Playground access

The package provides a Command Line Interface (CLI) script:

```shell
llama-playground --help
```
```
# Usage:
#   llama-playground [<words> ...] [--path=<Str>] [--mt|--max-tokens[=Int]] [-m|--model=<Str>] [-r|--role=<Str>] [-t|--temperature[=Real]] [--response-format=<Str>] [-a|--auth-key=<Str>] [--timeout[=UInt]] [-f|--format=<Str>] [--method=<Str>] [--base-url=<Str>] -- Command given as a sequence of words.
#   
#     --path=<Str>               Path, one of ''completions', 'chat/completions', 'embeddings', or 'models'. [default: 'chat/completions']
#     --mt|--max-tokens[=Int]    The maximum number of tokens to generate in the completion. [default: 2048]
#     -m|--model=<Str>           Model. [default: 'Whatever']
#     -r|--role=<Str>            Role. [default: 'user']
#     -t|--temperature[=Real]    Temperature. [default: 0.7]
#     --response-format=<Str>    The format in which the response is returned. [default: 'url']
#     -a|--auth-key=<Str>        Authorization key (to use LLaMA server Web API.) [default: 'Whatever']
#     --timeout[=UInt]           Timeout. [default: 10]
#     -f|--format=<Str>          Format of the result; one of "json", "hash", "values", or "Whatever". [default: 'Whatever']
#     --method=<Str>             Method for the HTTP POST query; one of "tiny" or "curl". [default: 'tiny']
#     --base-url=<Str>           Base URL of the LLaMA server. [default: 'http://127.0.0.1:80…']
```

**Remark:** When the authorization key, `auth-key`, is specified to be `Whatever`
then it is assigned the string `sk-no-key-required`.
If an authorization key is required then the env variable `LLAMA_API_KEY` can be also used.

--------

## Mermaid diagram

The following flowchart corresponds to the steps in the package function `llama-playground`:

```mermaid
graph TD
	UI[/Some natural language text/]
	TO[/"LLaMA<br/>Processed output"/]
	WR[[Web request]]
	LLaMA{{http://127.0.0.1:8080}}
	PJ[Parse JSON]
	Q{Return<br>hash?}
	MSTC[Compose query]
	MURL[[Make URL]]
	TTC[Process]
	QAK{Auth key<br>supplied?}
	EAK[["Try to find<br>LLAMA_API_KEY<br>in %*ENV"]]
	QEAF{Auth key<br>found?}
	NAK[["Use 'sk-no-key-required'"]]
	UI --> QAK
	QAK --> |yes|MSTC
	QAK --> |no|EAK
	EAK --> QEAF
	MSTC --> TTC
	QEAF --> |no|NAK
	QEAF --> |yes|TTC
	TTC -.-> MURL -.-> WR -.-> TTC
	WR -.-> |URL|LLaMA 
	LLaMA -.-> |JSON|WR
	TTC --> Q 
	Q --> |yes|PJ
	Q --> |no|TO
	PJ --> TO
```

--------

## References

### Packages

[AAp1] Anton Antonov,
[WWW::OpenAI Raku package](https://github.com/antononcube/Raku-WWW-OpenAI),
(2023-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[WWW::MistralAI Raku package](https://github.com/antononcube/Raku-WWW-MistralAI),
(2023-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[LLM::Functions Raku package](https://github.com/antononcube/Raku-LLM-Functions),
(2023-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[LLM::Prompts Raku package](https://github.com/antononcube/Raku-LLM-Prompts),
(2023-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Jupyter::Chatbook Raku package](https://github.com/antononcube/Raku-Jupyter-Chatbook),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[MO1] Mozilla Ocho, [llamafile](https://github.com/mozilla-Ocho/llamafile).

[MO2] Mozilla Ocho, [llamafile documentation](https://github.com/Mozilla-Ocho/llamafile/blob/main/README.md).
