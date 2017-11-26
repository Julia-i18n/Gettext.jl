# Gettext.jl
[![Build Status](https://travis-ci.org/Julia-i18n/Gettext.jl.svg)](https://travis-ci.org/Julia-i18n/Gettext.jl)
[![Coverage Status](https://coveralls.io/repos/Julia-i18n/Gettext.jl/badge.svg?branch=master)](https://coveralls.io/r/Julia-i18n/Gettext.jl?branch=master)

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

For string interpolation, you will need to use a runtime method (e.g. [Formatting.jl](https://github.com/lindahua/Formatting.jl)) rather than Julia's built-in compile-time interpolation syntax.  If using Formatting.jl, it probably makes sense to use the "Python" formatting style, as it allows the translations to have different argument orders than the original strings.  For example,

    using Gettext
    using Formatting

    bindtextdomain("sample", "po/")
    textdomain("sample")

    daystr(n) = format(ngettext("{1} day", "{1} days", n), n)

    println(daystr(1))
    println(daystr(3))

When run, this gives

    $ LANGUAGE=fr julia daystr.jl
    1 jour
    3 jours

## Status

Currently this library relies on Python's built-in [gettext.py](https://github.com/python/cpython/blob/master/Lib/gettext.py) implementation via [PyCall](https://github.com/stevengj/PyCall.jl).  In the future, it may make sense to port this code into a Julia-native version (see [issue #1](https://github.com/Julia-i18n/Gettext.jl/issues/1)).
