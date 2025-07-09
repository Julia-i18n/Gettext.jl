using Documenter, Gettext

makedocs(
    modules = [Gettext],
    clean = false,
    sitename = "Gettext.jl",
    authors = "Jim Garrison, Steven G. Johnson, and contributors.",
    pages = [
        "Home" => "index.md",
        "Internationalization (i18n) API" => "i18n.md",
        "Localization (l10n) and PO files" => "l10n.md",
        "API reference" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/Julia-i18n/Gettext.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
