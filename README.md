# Gettext.jl
[![Build Status](https://travis-ci.org/garrison/Gettext.jl.svg)](https://travis-ci.org/garrison/Gettext.jl)

An interface to the [gettext](http://www.gnu.org/software/gettext/manual/html_node/index.html) internationalization/translation interface.

## Installation

Within Julia, run `Pkg.update()` and then `Pkg.add("Gettext")`

## Usage

A simple string can be translated as follows:

    using Gettext
    bindtextdomain("sample", "po/")
    textdomain("sample")
    println(_"Hello, world!")

In fact, such a sample program can be run from the toplevel directory of this repository as follows:

    $ LANGUAGE=fr julia helloworld.jl
    Bonjour le monde !

## String interpolation

For string interpolation, you will need to use a runtime method (e.g. [Formatting.jl](https://github.com/lindahua/Formatting.jl)) rather than Julia's built-in compile-time interpolation syntax.  If using Formatting.jl, it probably makes sense to use the "Python" formatting style, as it allows the translations to have different argument orders than the original strings.

## Status

Currently this library relies on Python's built-in [gettext.py](https://github.com/python/cpython/blob/master/Lib/gettext.py) implementation via [PyCall](https://github.com/stevengj/PyCall.jl).  In the future, it may make sense to port this code into a Julia-native version (see [issue #1](https://github.com/garrison/Gettext.jl/issues/1)).

## Author

This package was written by [Jim Garrison](http://jimgarrison.org/).
