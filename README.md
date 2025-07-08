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

```jl
using Gettext

bindtextdomain("sample", joinpath(dirname(pathof(Gettext)), "..", "po")
textdomain("sample")

println(_"Hello, world!")
```

In fact, such a sample program can be run as follows:

```sh
$ LANGUAGE=fr julia helloworld.jl
Bonjour le monde !
```

Note that Julia's standard backslash-escapes (like `\n` for newline or `\uXXXX` for U+XXXX) *are* supported in `_"..."` strings, but `$` interpolation is *not* supported.  The reason for the latter
is that translated strings should generally not depend on runtime values, though for the rare exceptions
you can call `gettext("...")` with an ordinary Julia string.  To substitute numerical quantities with
singular and plural forms, see below.

## Using in modules/packages

To use Gettext.jl in a package or module, it is undesirable to
employ a single global `textdomain`, since that would cause
different packages to interfere with one another.  Instead,
you should define a unique domain name for your package,
typically `"MyPackage-<uuid>"` where `<uuid>` is the unique UUID
identifier of your package, and then pass that as the first
argument to `gettext(...)` and similar functions.

To help automate this, we provide a set of macros, `_"..."`, `@gettext`,
and similar, which pass the global variable `__GETTEXT_DOMAIN__` from
your module to the corresponding functions.  You should use it as follows:

```jl
module MyModule

using Gettext
const __GETTEXT_DOMAIN__ = "MyModule-<uuid>" # replace with package UUID
function __init__()
    bindtextdomain(__GETTEXT_DOMAIN__, joinpath(@__DIR__, "..", "po"))
end

# ...module implementation...

end
```

This assumes that you have a top-level directory `po` in your module
(similar to the Gettext.jl package) that is used to store translation
(`.po`) files `po/<locale>/LC_MESSAGES/MyModule-<uuid>.po`, where
`<locale>` is the standard locale identifier, e.g. `en` (English) or
`en_GB` (English, Great Britain), and `MyModule-<uuid>` is your
domain name from above.

Then, in the module, you can simply use `_"..."`, `@gettext("...")`,
`@ngettext(singular, plural, n)`, `@pgettext(context, "...")`, or
`@npgettext(context, singular, plural, n)`, exactly as you would
the corresponding functions.  Note that the `_"..."` macro *requires*
you to define the `__GETTEXT_DOMAIN__` global variable in your module.

If you use these variables in Julia's special `Main` module (e.g.
an interactive environment like the REPL, or in a script), then
they instead use the global `textdomain("...")` as in the examples
of the previous section.

If your module has submodules, they can employ the same domain as
the parent module `MyModule`, via
```jl
using Gettext
using ..MyModule: __GETTEXT_DOMAIN__`
```

## Singular/plural interpolation

Gettext allows you to look up singular and plural forms of a string depending upon a runtime integer, using the `ngettext` function.

For example, you might use `"1 day"` for `n == 1` and `"$n days"` for `n > 1`.  To do this, however, it is important to substitute `n` into the string *after* looking up the translation, and to do this we typically use a `printf`-style placeholder like `"%d"` for `n` in the translation string, as follows:

```jl
using Gettext

bindtextdomain("sample", joinpath(dirname(pathof(Gettext)), "..", "po"))
textdomain("sample")

daystr(n) = ngettext("%d day", "%d days", "%d"=>n)

println(daystr(1))
println(daystr(3))
```

Here, `ngettext` substitutes the value of `n` for `"%d"` after the translation is obtained.  If you want to do more complex formatting, you can instead call `ngettext("%d day", "%d days", n)`, which does no substitution (returning `"%d day"` or `"%d days"` depending on `n`).  In that case, one could use the `Printf` standard library, or perhaps Python-style format strings via the [Format.jl package](https://github.com/JuliaString/Format.jl).

When run, this code gives:

```sh
$ LANGUAGE=fr julia daystr.jl
1 jour
3 jours
```
