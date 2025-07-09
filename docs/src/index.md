# Gettext.jl

This package offers facilities for [internationalization and localization (i18n and l10n)](https://en.wikipedia.org/wiki/Internationalization_and_localization) of software in the Julia programming language, using the standard [`gettext`](https://en.wikipedia.org/wiki/Gettext) system.

(This package calls GNU gettext's `libintl` library directly from Julia, via the `GettextRuntime_jll` package compiled for Julia by [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil); this is automatically installed for you by Julia's [package manager](https://github.com/JuliaLang/Pkg.jl).  GNU gettext is free/open-source software licensed under the [GNU LGPL](https://www.gnu.org/software/gettext/manual/html_node/GNU-LGPL.html).)

## Overview of internationalization and localization

**Internationalization** (commonly abbreviated **i18n**) is the process of making computer software able to support translations into multiple languages.  **Localization** (abbreviated **l10n**) is the creation of a specific translation for a particular language and cultural setting (a *locale*).

`gettext` is a popular system, dating back to 1990, for i18n and l10n of **messages** (strings) exposed to users in a program's interface: prompts, menu items, error messages, and so on.  This consists of two parts:

* **i18n**: in your program, *any string that might need translation* should be wrapped in a call to a `gettext` function.   In Gettext.jl, this is typically accomplished by macros: For a typical string `"..."`, you simply replace it with [`_"..."`](@ref `@__str`) to make it translatable.  There are also more specialized macros, such as [`@ngettext`](@ref) for strings with runtime-dependent singular and plural forms.  See the [Internationalization (i18n) API](@ref) chapter.

* **l10n**: for any locale, one can create a `.po` file that lists the translations of strings in a human-readable text format — this format is designed so that non-programmers can easily contribute translations, and there are many software tools to help create `.po` files (either manually or via automated translation).   These `.po` files are then placed in a standardized directory for your package, and are converted to a binary `.mo` format with the [GNU `msgfmt` program](https://www.gnu.org/software/gettext/manual/html_node/Binaries.html).   At runtime, Gettext.jl then automatically looks up translations (if any) from the current locale (as indicated by the operating system) and substitutes them for strings like `_"..."` in your program.  See the [Localization (l10n) and PO files](@ref) chapter.

(Other forms of i18n and l10n, such as locale-specific formatting of numbers and dates, are outside the scope of `gettext`, but are provided by other libraries such as `libc`.)

See also the [introduction and overview](https://www.gnu.org/software/gettext/manual/html_node/Introduction.html) from the GNU `gettext` manual.

## Simple example

Suppose that you have the following Julia program
```jl
println("Hello, world!")
```
To i18n it, the first step is simply to change the code to:
```jl
using Gettext
println(_"Hello, world!")
```
which tells Gettext.jl to translate the string `"Hello, world!"` for the current locale, if possible.   By default, if no translation is found, [`_"..."`](@ref `@__str`)  will simply return the original untranslated string, and the program will have the same output as before.

The Gettext.jl package comes with a sample `.po` translation file that includes a translation of `"Hello, world!"` into French.    In particular, the Gettext.jl package has a text file `po/fr/LC_MESSAGES/sample.po` (along with its binary-format equivalent `po/fr/LC_MESSAGES/sample.mo`) that includes the translation:
```
msgid "Hello, world!"
msgstr "Bonjour le monde !"
```
Here in the `sample.po` file, the `msgid` is the original string, and `msgstr` is the translation.  The `po` directory (typically at the top level of the package) is where a package's translations are placed, and `po/fr/LC_MESSAGES` contains translations for French-language (`fr`) locales in the default "category" `LC_MESSAGES`.  Inside this directory, `sample.po` contains the translations for the "domain" we called `"sample"` — there will typically be one such domain per independent package/component of a program (see [Gettext for modules and packages](@ref module_gettext)).   We need to tell Gettext.jl where to find the translations we are using, which we do via:
```jl
using Gettext
bindtextdomain("sample", joinpath(dirname(pathof(Gettext)), "..", "po"))
textdomain("sample") # set domain for the global Main module only

println(_"Hello, world!")
```
Here, [`bindtextdomain`](@ref) specifies the path of the `po` directory for
a given domain.  For scripts (or interactive sessions) running in Julia's
[`Main`](https://docs.julialang.org/en/v1/base/base/#Main) module, you then call
[`textdomain`](@ref) to set the global domain.   (Inside packages and
other modules, you instead define a [`__GETTEXT_DOMAIN__`](@ref module_gettext) global to set a package-specific domain, so that each package can have independent
translations.)

Now, when you run the code, you will *still* see `"Hello, world!"` if you are in any
non-French locale, but *French* locales will instead print `"Bonjour le monde !"`.
On Unix-like systems, you can set the locale simply via the [`LANGUAGE` environment
variable](https://www.gnu.org/software/gettext/manual/html_node/Locale-Environment-Variables.htmls). This can even be changed at runtime, so
```jl
using Gettext
bindtextdomain("sample", joinpath(dirname(pathof(Gettext)), "..", "po"))
textdomain("sample")

println(_"Hello, world!")
ENV["LANGUAGE"]="fr"
println(_"Hello, world!")
```
will print
```
Hello, world!
Bonjour le monde !
```
if you are in a non-French locale to start with.

(Note: Microsoft Windows has its [own API](https://learn.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-setthreadlocale) to set the locale, not via environment variables, so you may not see French output unless you [change the Windows display language](https://support.microsoft.com/en-US/windows/manage-the-language-and-keyboard-input-layout-settings-in-windows-12a10cb4-8626-9b77-0ccb-5013e0c7c7a2).)
