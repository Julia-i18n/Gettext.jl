# Gettext.jl
[![CI](https://github.com/Julia-i18n/Gettext.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/Julia-i18n/Gettext.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Codecov](https://codecov.io/Julia-i18n/Gettext.jl/branch/master/graph/badge.svg?token=WsGRSymBmZ)](https://codecov.io/gh/Julia-i18n/Gettext.jl)

Documentation:
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Julia-i18n.github.io/Gettext.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://Julia-i18n.github.io/Gettext.jl/dev)

This package offers facilities for [internationalization and localization (i18n and l10n)](https://en.wikipedia.org/wiki/Internationalization_and_localization) of software in the Julia programming language, using the standard [`gettext`](https://en.wikipedia.org/wiki/Gettext) system.

Essentially, Gettext.jl allows the programmer to mark user-visible messages (strings) for translation, typically by simply replacing `"..."` strings with `_"..."`.  Then, translators can localize a Julia program or package by providing a list of translations in the standard `.po` format (a human-readable/editable file, supported by many software tools).

(This package calls GNU gettext's `libintl` library directly from Julia, via the `GettextRuntime_jll` package compiled for Julia by [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil); this is automatically installed for you by Julia's [package manager](https://github.com/JuliaLang/Pkg.jl).  GNU gettext is free/open-source software licensed under the [GNU LGPL](https://www.gnu.org/software/gettext/manual/html_node/GNU-LGPL.html).)
