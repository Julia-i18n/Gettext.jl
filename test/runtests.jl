# Our tests attempt translating strings to French, so set the LANGUAGE
# accordingly.
old_language = get(ENV, "LANGUAGE", nothing)
ENV["LANGUAGE"] = "fr"

using Gettext
using Base.Test
using Formatting

# Set up gettext
trdir = realpath(joinpath(Pkg.dir("Gettext"), "po"))
@test isfile(joinpath(trdir, "fr", "LC_MESSAGES", "sample.mo"))
bindtextdomain("sample", trdir)
textdomain("sample")

# Test basic macros
@test _"Hello, world!" == "Bonjour le monde !"
@test N_"Hello, world!" == "Hello, world!"

# Test ngettext
daystr(n) = format(ngettext("{1} day", "{1} days", n), n)
@test daystr(1) == "1 jour"
@test daystr(3) == "3 jours"

# Set the language back to normal.
if old_language != nothing
    ENV["LANGUAGE"] = old_language
else
    pop!(ENV, "LANGUAGE")
end
