using Gettext
using Test

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

module FooBad
    using Gettext
    hello() = _"Hello, world!" # error: undefined __GETTEXT_DOMAIN__
end
module Foo
    using Gettext
    const __GETTEXT_DOMAIN__ = "sample2"
    function __init__()
        bindtextdomain(__GETTEXT_DOMAIN__, joinpath(@__DIR__, "..", "po"))
    end
    hello() = _"Hello, world!"
    daystr(n) = @ngettext("%d day", "%d days", "%d"=>n)
    julia() = @pgettext("test", "Julia is inspired")
    boats(n) = @npgettext("test", "%d boat", "%d boats", "%d"=>n)
end
import .FooBad, .Foo

# set up a temporary Unicode pathname with a po file,
# to make sure that we support Unicode directory names
tmpdir = mktempdir()
try
    trdir = mkpath(joinpath(tmpdir, "ünicøde🐨", "po"))
    podir = mkpath(joinpath(trdir, "fr_FR", "LC_MESSAGES"))
    pkg_podir = joinpath(@__DIR__, "..", "po", "fr", "LC_MESSAGES")
    for file in ["sample.mo", "sample.po"]
        cp(joinpath(pkg_podir, file), joinpath(podir, file))
    end

    # Set up gettext
    @testset "setup" begin
        @test isfile(joinpath(podir, "sample.mo"))
        bindtextdomain("sample", trdir)
        textdomain("sample")
        @test bindtextdomain("sample") == abspath(trdir)
        @test textdomain() == "sample"
    end

    @testset "basic tests" begin
        # Test basic macros
        @test _"H\u0065llo, world!" == "Bonjour le monde !"
        @test N_"H\u0065llo, world!" == "Hello, world!"

        @test _"Unknown key" == "Unknown key"

        # Test ngettext
        daystr(n) = @ngettext("%d day", "%d days", "%d"=>n)
        @test daystr(1) == "1 jour"
        @test daystr(3) == "3 jours"

        # Test dgettext and dngettext
        @test gettext("sample", "Hello, world!") == "Bonjour le monde !"
        @test gettext("sample2", "Hello, world!") == "Salut tout le monde!"
        @test ngettext("sample", "%d day", "%d days", "%d"=>1) == "1 jour"
    end

    @testset "pgettext" begin
        # test pgettext
        @test @pgettext("test", "Julia is inspired") == "Julia est inspirée"
        @test @npgettext("test", "%d boat", "%d boats", "%d"=>1) == "1 bateau"
        @test @npgettext("test", "%d boat", "%d boats", "%d"=>2) == "2 bateaux"

        # test untranslated strings
        @test pgettext("test", "GNU gettext") == "GNU gettext"
        @test npgettext("test", "%d frog", "%d frogs", "%d"=>1) == "1 frog"
        @test npgettext("test", "%d frog", "%d frogs", "%d"=>2) == "2 frogs"
    end

    @testset "modules" begin
        @test_throws UndefVarError FooBad.hello()
        @test Foo.hello() == "Salut tout le monde!"
        @test Foo.daystr(1) == "1 rotation de la terre"
        @test Foo.daystr(3) == "3 rotations de la terre"
        @test Foo.julia() == "Julia est ingénieux"
        @test Foo.boats(1) == "1 vaisseau"
        @test Foo.boats(2) == "2 vaisseaux"
    end

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
