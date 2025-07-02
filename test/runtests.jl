using Gettext
using Test
using Formatting
import Pkg

# Our tests attempt translating strings to French, so set the LANGUAGE
# etcetera accordingly.

# Windows, of course, uses its own mechanism to set locale
@static if Sys.iswindows()
    fr_FR = 0x040C # LCID for fr_FR
    old_LCID = ccall(:GetThreadLocale, stdcall, UInt32, ())
    ccall(:SetThreadLocale, stdcall, Cint, (UInt32,), fr_FR)
end

old_language = get(ENV, "LANGUAGE", nothing)
old_lang = get(ENV, "LANG", nothing)
ENV["LANG"] = ENV["LANGUAGE"] = "fr_FR"

# set up a temporary Unicode pathname with a po file,
# to make sure that we support Unicode directory names
tmpdir = mktempdir()
try
    # trdir = mkpath(joinpath(tmpdir, "ünicøde🐨", "po"))
    trdir = mkpath(joinpath(tmpdir, "ascii", "po"))
    podir = mkpath(joinpath(trdir, "fr", "LC_MESSAGES"))
    pkg_podir = joinpath(@__DIR__, "..", "po", "fr", "LC_MESSAGES")
    for file in ["sample.mo", "sample.po"]
        cp(joinpath(pkg_podir, file), joinpath(podir, file))
    end
    # trdir = joinpath(@__DIR__, "..", "po")

    # Set up gettext
    @test isfile(joinpath(trdir, "fr", "LC_MESSAGES", "sample.mo"))
    bindtextdomain("sample", trdir)
    textdomain("sample")
    @test bindtextdomain("sample") == trdir
    @test textdomain() == "sample"

    # Test basic macros
    @test _"Hello, world!" == "Bonjour le monde !"
    @test N_"Hello, world!" == "Hello, world!"

    @test _"Unknown key" == "Unknown key"

    # Test ngettext
    daystr(n) = format(ngettext("{1} day", "{1} days", n), n)
    @test daystr(1) == "1 jour"
    @test daystr(3) == "3 jours"

    # Test dgettext and dngettext
    @test dgettext("sample", "Hello, world!") == "Bonjour le monde !"
    @test dngettext("sample", "{1} day", "{1} days", 1) == "{1} jour"

finally
    # Set the language back to normal.
    @static if Sys.iswindows()
        ccall(:SetThreadLocale, stdcall, Cint, (UInt32,), old_LCID)
    end
    if old_language !== nothing
        ENV["LANGUAGE"] = old_language
    else
        pop!(ENV, "LANGUAGE")
    end
    if old_lang !== nothing
        ENV["LANG"] = old_lang
    else
        pop!(ENV, "LANG")
    end

    rm(tmpdir, recursive=true)
end
