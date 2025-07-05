# Gettext.jl
[![CI](https://github.com/Julia-i18n/Gettext.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/Julia-i18n/Gettext.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Codecov](https://codecov.io/Julia-i18n/Gettext.jl/branch/master/graph/badge.svg?token=WsGRSymBmZ)](https://codecov.io/gh/Julia-i18n/Gettext.jl)

An interface to the [gettext](http://www.gnu.org/software/gettext/manual/html_node/index.html) internationalization/translation interface.

(This package calls the GNU `gettext` library directly from Julia, via the `GettextRuntime_jll` package compiled for Julia
by [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil); this is automatically installed for you by Julia's
[package manager](https://github.com/JuliaLang/Pkg.jl).  `gettext` is free/open-source software licensed under the
[GNU LGPL](https://www.gnu.org/software/gettext/manual/html_node/GNU-LGPL.html).)

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
