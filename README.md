# Gettext.jl
[![CI](https://github.com/Julia-i18n/Gettext.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/Julia-i18n/Gettext.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Codecov](https://codecov.io/Julia-i18n/Gettext.jl/branch/master/graph/badge.svg?token=WsGRSymBmZ)](https://codecov.io/gh/Julia-i18n/Gettext.jl)

An interface to the [gettext](http://www.gnu.org/software/gettext/manual/html_node/index.html) internationalization/translation interface.

(This package calls the GNU `gettext` library directly from Julia, via the `GettextRuntime_jll` package compiled for Julia
by [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil); this is automatically installed for you by Julia's
[package manager](https://github.com/JuliaLang/Pkg.jl).  `gettext` is free/open-source software licensed under the
[GNU LGPL](https://www.gnu.org/software/gettext/manual/html_node/GNU-LGPL.html).)

## Installation

Within Julia, `import Pkg; Pkg.add("Gettext")`

## Usage

A simple string can be translated as follows:

    using Gettext

    bindtextdomain("sample", "po")
    textdomain("sample")

    println(_"Hello, world!")

In fact, such a sample program can be run from the toplevel directory of this repository as follows:

    $ LANGUAGE=fr julia helloworld.jl
    Bonjour le monde !

Note that Julia's standard backslash-escapes (like `\n` for newline or `\uXXXX` for U+XXXX) *are* supported in `_"..."` strings, but `$` interpolation is *not* supported.  The reason for the latter
is that translated strings should generally not depend on runtime values, though for the rare exceptions
you can call `gettext("...")` with an ordinary Julia string.  To substitute numerical quantities with
singular and plural forms, see below.

## Singular/plural interpolation

Gettext allows you to look up singular and plural forms of a string depending upon a runtime integer, using the `ngettext` function.

For example, you might use `"1 day"` for `n == 1` and `"$n days"` for `n > 1`.  To do this, however, it is important to substitute `n` into the string *after* looking up the translation, and to do this we typically use placeholder like `"%d"` for `n` in the translation string, as follows:

    using Gettext

    bindtextdomain("sample", "po")
    textdomain("sample")

    daystr(n) = replace(ngettext("%d day", "%d days", n), "%d"=>n)

    println(daystr(1))
    println(daystr(3))

Here, we have simply used the built-in `replace` function to substitute the value of `n` for `"%d"` after the translation is obtained; one could also use the `Printf` standard library for more complex formatting, or you could also use Python-style format strings via the [Format.jl package](https://github.com/JuliaString/Format.jl).

When run, this code gives:

    $ LANGUAGE=fr julia daystr.jl
    1 jour
    3 jours
