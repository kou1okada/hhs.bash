# hhs.bash - Happy hacking script for bash

This project provides the library for the simple way
to develop the bash script which has rich options and sub-commands.

# Installation

~~~
mkdir -p ~/git/
mkdir -p ~/local/bin
cd ~/git
git clone https://github.com/kou1okada/hhs.bash
cd hhs.bash
make
ln -sv ~/git/hhs.bash/hhs.bash ~/local/bin/
PATH=~/local/bin:$PATH
~~~

# Usage

## Examples

See below files:

* `hello`
* `sample`
* `temperature`

## Include and invoke `hhs.bash`.

Write your script as below:
~~~
#!/usr/bin/env bash

source hhs.bash 0.2.0

# Write your script
# ...

invoke_command "$@"
~~~

## Writing the command, and the comment for auto generating the usage.

You can write a `COMMAND` command that have no subcommand as below:
~~~
function COMMAND ()
{
  # Processes you want to do.
  : ...
}
~~~

Let's assume you have written the following comment:
~~~
function COMMAND () # [OPTIONS] ARG1 [ARGS ...]
# DESCRIPTIONS
# ...
{
  : processes for command
} 
~~~

In this case, `usage_default` automatically generates the help message as below:
~~~
$ COMMAND -h
Usage: COMMAND [OPTIONS] ARG1 [ARGS ...]
DESCRIPTIONS
...
~~~

If you want to write a command that have some subcommands,
only you must set a variable as below:
~~~
has_subcommand_COMMAND=1
~~~ 

And you can write `SUBCOMMAND` subcommands as below:
~~~
function COMMAND_SUBCOMMAND ()
{
  # Processes you want to do.
  : ...
}
~~~

## Analizing the command line parameters, and the comment for auto generating the usage.

For analizing the command line parameters,
you can write the optparse function for `COMMAND`
with the comment for auto generating the usage as below:
~~~
function optparse_COMMAND ()
{
  case "$1" in
    -o|--option) # PARAM
      # DESCRIPTIONS
      # ...
      nparams 1 # number of parameters.
      optset OPTION "$2" # set value of "$2" to OPT_OPTION.
      ;;
    *)
      return 1
      ;;
  esac
}
~~~

For example:
~~~
function optparse_COMMAND ()
{
  case "$1" in
    -s|--switch)
      # The option that has any parameters.
      nparam 0
      optset SWITCH "$1"
      # This will set OPT_SWITCH="$1"
      ;;
    -S|--set) PARAM1 PARAM2
      # The option that has some parameters.
      nparam 2
      optset "$1" "$2"
      # This will set "OPT_$1"="$2"
      ;;
    -o|--optional) # [PARAM]
      # The option that can take a optional parameter.
      # The optional parameter has the style as -oVALUE or --optional=VALUE.
      nparam 1 1
      optset OPTIONAL default
      # If optional parameter will be passed, this will set OPT_OPTIONAL="$2".
      # Other wise, this will set OPT_OPTIONAL=default.
      # But, if `-o` or `--optional` is not set,
      # there will nothing happen to OPT_OPTIONAL.
      ;;
    *)
      # If specified options is not known in this function,
      # it should be return false.
      return 1
      ;;
  esac
}
~~~

In this case, `usage_default` automatically generates the help message as below:
~~~
$ COMMAND -h
Usage: COMMAND [OPTIONS] ARG1 [ARGS ...]
DESCRIPTIONS
...
Options:
  -s, --switch
      The option that has any parameters.
  -S, --set=PARAM1 PARAM2
      The option that has some parameters.
  -o, --optional[=PARAM]
      The option that can take a optional parameter.
      The optional parameter has the style as -oVALUE or --optional=VALUE.
~~~
