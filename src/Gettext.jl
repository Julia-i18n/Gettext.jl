"""
    module Gettext

This module offers facilities for internationalization and localization (i18n and l10n)
of software in the Julia programming language, using the standard `gettext` system.

Essentially, `Gettext` allows the programmer to mark user-visible messages (strings) for translation,
typically by simply replacing `"..."` strings with [`_"..."`](@ref `@__str`).

Then, translators can localize a Julia program or package by providing a list of translations in the
standard `.po` format (a human-readable/editable file, supported by many software tools).
"""
module Gettext

using GettextRuntime_jll

textdomain() = unsafe_string(ccall((:libintl_textdomain,libintl), Cstring, (Ptr{UInt8},), C_NULL))
function textdomain(domain::AbstractString)
    # textdomain(domain) returns the domain as a string, but
    # you are required to not free the result.  Might as well ignore it.
    ccall((:libintl_textdomain,libintl), Cstring, (Cstring,), domain)
    return domain
end

"""
    textdomain([domain::AbstractString])

Set the global Gettext domain to `domain` (if supplied), returning the current
global domain.

This domain is used for calls to low-level functions like [`gettext`](@ref)
when no domain argument is passed, and also for macros like [`_"..."`](@ref `@__str`)
and [`@getext`](@ref) when used from the `Main` module.
"""
textdomain

function bindtextdomain(domain::AbstractString)
    @static if Sys.iswindows()
        return unsafe_string(ccall((:libintl_wbindtextdomain,libintl), Cwstring, (Cstring, Ptr{Cwchar_t}), domain, C_NULL))
    else
        return unsafe_string(ccall((:libintl_bindtextdomain,libintl), Cstring, (Cstring, Ptr{UInt8},), domain, C_NULL))
    end
end

function bindtextdomain(domain::AbstractString, dir_name::AbstractString)
    abs_dir_name = abspath(dir_name) # gettext recommends against relative paths for bindtextdomain
    @static if Sys.iswindows()
        ccall((:libintl_wbindtextdomain,libintl), Cwstring, (Cstring,Cwstring), domain, abs_dir_name)
    else
        ccall((:libintl_bindtextdomain,libintl), Cstring, (Cstring,Cstring), domain, abs_dir_name)
    end
    ccall((:libintl_bind_textdomain_codeset,libintl), Cstring, (Cstring,Cstring), domain, "UTF-8")
    # bintextdomain(domain, dir_name) returns the dir_name as a string, but
    # you are required to not free the result.  Might as well ignore it.
    return abs_dir_name
end

"""
    bindtextdomain(domain::AbstractString, [path::AbstractString])

Specify that the `po` directory for `domain` is at `path` (if supplied),
returning the current (absolute) `path` for `domain`.

(If this function is not called, then `gettext` will look in a system-specific
directory like `/usr/local/share/locale` for translation catalogs.)
"""
bindtextdomain

"""
    gettext([domain::AbstractString], msgid::AbstractString)

Look up the translation (if any) of `msgid` in `domain` (if supplied, or
in the global [`textdomain`](@ref) otherwise), returning the translated
string, or returning `msgid` if no translation was found.

See also [`@gettext`](@ref) to use the domain of the current module.
"""
gettext(msgid::AbstractString) = unsafe_string(ccall((:libintl_gettext,libintl), Cstring, (Cstring,), msgid))
gettext(domain::AbstractString, msgid::AbstractString) = unsafe_string(ccall((:libintl_dgettext,libintl), Cstring, (Cstring, Cstring,), domain, msgid))

"""
    ngettext([domain::AbstractString], msgid::AbstractString, msgid_plural::AbstractString, n::Integer)
    ngettext([domain::AbstractString], msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString, <:Integer})

Look up the translation (if any) of `msgid` in `domain` (if supplied, or
in the global [`textdomain`](@ref) otherwise), with the plural form
given by `msgid_plural`, returning the singular form if `n == 1` and
a plural form if `n != 1` (`n` must be nonnegative), giving a translated
string if available.

Instead of passing an integer `n`, you can pass a `Pair` `placeholder=>n`,
in which case case the string `placeholder` is replaced by `n` in the returned
string; most commonly, `placeholder == "%d"` (in `printf` style).  (Note that this
is a simple string replacement; if you want more complicated `printf`-style formating
like `"%05d"` then you will need to call a library like `Printf` yourself.)

See also [`@ngettext`](@ref) to use the domain of the current module.
"""
ngettext(msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:libintl_ngettext,libintl), Cstring, (Cstring,Cstring,Culong), msgid, msgid_plural, n))
ngettext(domain::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:libintl_dngettext,libintl), Cstring, (Cstring,Cstring,Cstring,Culong), domain, msgid, msgid_plural, n))

# (TODO: can we make _msg_ctxt_id work at compile-time for string literals?)
const CONTEXT_GLUE = '\004' # The separator between msgctxt and msgid in a .mo file.
_msg_ctxt_id(context::AbstractString, msgid::AbstractString) = string(context, CONTEXT_GLUE, msgid)

"""
    pgettext([domain::AbstractString], context::AbstractString, msgid::AbstractString)

Like [`gettext`](@ref), but also supplies a `context` string for looking up `msgid`
(in `domain`, if supplied, or the global [`textdomain`](@ref) otherwise),
returning the translation (if any) or `msgid` (if no translation was found).

See also [`@pgettext`](@ref) to use the domain of the current module.
"""
function pgettext(context::AbstractString, msgid::AbstractString)
    msg_ctxt_id = _msg_ctxt_id(context, msgid)
    text = gettext(msg_ctxt_id)
    return text == msg_ctxt_id ? msgid : text
end
function pgettext(domain::AbstractString, context::AbstractString, msgid::AbstractString)
    msg_ctxt_id = _msg_ctxt_id(context, msgid)
    text = gettext(domain, msg_ctxt_id)
    return text == msg_ctxt_id ? msgid : text
end

"""
    npgettext([domain::AbstractString], context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer)
    npgettext([domain::AbstractString], context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString, <:Integer})

Like [`ngettext`](@ref), but also supplies a `context` string for looking up `msgid`
or its plural form `msgid_plural` (depending on `n`), optionally performing a
text substitution if a `Pair` is passed for the final argument.

See also [`@npgettext`](@ref) to use the domain of the current module.
"""
function npgettext(context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer)
    msg_ctxt_id = _msg_ctxt_id(context, msgid)
    text = ngettext(msg_ctxt_id, msgid_plural, n)
    return text == msg_ctxt_id ? msgid : text
end
function npgettext(domain::AbstractString, context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer)
    msg_ctxt_id = _msg_ctxt_id(context, msgid)
    text = ngettext(domain, msg_ctxt_id, msgid_plural, n)
    return text == msg_ctxt_id ? msgid : text
end

################################################################################################
# simplify the common replace(ngettext(...), "%d"=>n) idiom by instead
# allowing ngettext(singular, plural, "%d"=>n):

ngettext(msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString,<:Integer}) =
    replace(ngettext(msgid, msgid_plural, nsub.second), nsub)
ngettext(domain::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString,<:Integer}) =
    replace(ngettext(domain, msgid, msgid_plural, nsub.second), nsub)
npgettext(context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString,<:Integer}) =
    replace(npgettext(context, msgid, msgid_plural, nsub.second), nsub)
npgettext(domain::AbstractString, context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString,<:Integer}) =
    replace(npgettext(domain, context, msgid, msgid_plural, nsub.second), nsub)

################################################################################################
# macro versions … not only are these shorter, but they also implicitly use the current module's
# @__MODULE__().__GETTEXT_DOMAIN__ instead of the global domain (unless @__MODULE__() == Main).   This
# is important to ensure that translations from different packages do not conflict.

function _gettext_macro(gettext_func, gettext_args...)
    args = esc.(gettext_args)
    quote
        if @__MODULE__() === $Main
            $gettext_func($(args...))
        else
            $gettext_func(@__MODULE__().__GETTEXT_DOMAIN__, $(args...))
        end
    end
end

"""
    _"..."

Returns the translation (if any) for the given literal string `"..."` via [`@gettext`](@ref).

This string can contain backslash escapes like ordinary Julia literal strings, but `\$` is
treated literally (*not* used for interpolations): translation strings should not generally
contain runtime values.
"""
macro __str(s)
    _gettext_macro(gettext, unescape_string(s))
end

"""
    @gettext(msgid::AbstractString)

Look up the translation (if any) of `msgid`, returning the translated
string, or returning `msgid` if no translation was found.

In a module `!= Main`, this passes the module's `__GETTEXT_DOMAIN__` as the domain argument
to [`gettext`](@ref), whereas the global [`textdomain`](@ref) is used in the `Main` module.
"""
macro gettext(msgid)
    _gettext_macro(gettext, msgid)
end

"""
    @ngettext(msgid::AbstractString, msgid_plural::AbstractString, n::Integer)
    @ngettext(msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString, <:Integer})

Look up the translation (if any) of `msgid`, with the plural form
given by `msgid_plural`, returning the singular form if `n == 1` and
a plural form if `n != 1` (`n` must be nonnegative), giving a translated
string if available.

Instead of passing an integer `n`, you can pass a `Pair` `placeholder=>n`,
in which case case the string `placeholder` is replaced by `n` in the returned
string; most commonly, `placeholder == "%d"` (in `printf` style).  (Note that this
is a simple string replacement; if you want more complicated `printf`-style formating
like `"%05d"` then you will need to call a library like `Printf` yourself.)

In a module `!= Main`, this passes the module's `__GETTEXT_DOMAIN__` as the domain argument
to [`ngettext`](@ref), whereas the global [`textdomain`](@ref) is used in the `Main` module.
"""
macro ngettext(msgid, msgid_plural, n)
    _gettext_macro(ngettext, msgid, msgid_plural, n)
end

"""
    @pgettext([domain::AbstractString], context::AbstractString, msgid::AbstractString)

Like [`@gettext`](@ref), but also supplies a `context` string for looking up `msgid`,
returning the translation (if any) or `msgid` (if no translation was found).

In a module `!= Main`, this passes the module's `__GETTEXT_DOMAIN__` as the domain argument
to [`pgettext`](@ref), whereas the global [`textdomain`](@ref) is used in the `Main` module.
"""
macro pgettext(context, msgid)
    _gettext_macro(pgettext, context, msgid)
end

"""
    @npgettext(context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer)
    @npgettext(context::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, nsub::Pair{<:AbstractString, <:Integer})

Like [`@ngettext`](@ref), but also supplies a `context` string for looking up `msgid`
or its plural form `msgid_plural` (depending on `n`), optionally performing a
text substitution if a `Pair` is passed for the final argument.

In a module `!= Main`, this passes the module's `__GETTEXT_DOMAIN__` as the domain argument
to [`npgettext`](@ref), whereas the global [`textdomain`](@ref) is used in the `Main` module.
"""
macro npgettext(context, msgid, msgid_plural, n)
    _gettext_macro(npgettext, context, msgid, msgid_plural, n)
end

"""
    N_"..."

"No-op" translation, equivalent to `"..."`, for strings that do *not* require translation.

This string can contain backslash escapes like ordinary Julia literal strings, but `\$` is
treated literally (*not* used for interpolations).

(The main use of this macro is to explicitly mark strings to ensure that they are excluded
from automated translation tools.)
"""
macro N__str(s)
    :($(esc(unescape_string(s))))
end

################################################################################################

export bindtextdomain, textdomain, gettext, pgettext, ngettext, npgettext,
       @__str, @N__str, @gettext, @ngettext, @pgettext, @npgettext

end # module
