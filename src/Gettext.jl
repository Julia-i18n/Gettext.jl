module Gettext

using GettextRuntime_jll

textdomain() = unsafe_string(ccall((:libintl_textdomain,libintl), Cstring, (Ptr{UInt8},), C_NULL))
function textdomain(domain::AbstractString)
    # textdomain(domain) returns the domain as a string, but
    # you are required to not free the result.  Might as well ignore it.
    ccall((:libintl_textdomain,libintl), Cstring, (Cstring,), domain)
    return domain
end

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

gettext(msgid::AbstractString) = unsafe_string(ccall((:libintl_gettext,libintl), Cstring, (Cstring,), msgid))
gettext(domain::AbstractString, msgid::AbstractString) = unsafe_string(ccall((:libintl_dgettext,libintl), Cstring, (Cstring, Cstring,), domain, msgid))

ngettext(msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:libintl_ngettext,libintl), Cstring, (Cstring,Cstring,Culong), msgid, msgid_plural, n))
ngettext(domain::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:libintl_dngettext,libintl), Cstring, (Cstring,Cstring,Cstring,Culong), domain, msgid, msgid_plural, n))

# (TODO: can we make _msg_ctxt_id work at compile-time for string literals?)
const CONTEXT_GLUE = '\004' # The separator between msgctxt and msgid in a .mo file.
_msg_ctxt_id(context::AbstractString, msgid::AbstractString) = string(context, CONTEXT_GLUE, msgid)

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

Returns the translation (if any) for the given literal string via [`gettext`](@ref).  The
string can contain backslash escapes like ordinary Julia literal strings, but `\$` is
treated literally (*not* used for interpolations): translation strings should not generally
contain runtime values.

In a module `!= Main`, this passes the module's `__GETTEXT_DOMAIN__` as the domain argument
to `gettext` (whereas the global [`textdomain`](@ref) is used in the `Main` module).
"""
macro __str(s)
    _gettext_macro(gettext, unescape_string(s))
end

macro gettext(msgid)
    _gettext_macro(gettext, msgid)
end

macro ngettext(msgid, msgid_plural, n)
    _gettext_macro(ngettext, msgid, msgid_plural, n)
end

macro pgettext(context, msgid)
    _gettext_macro(pgettext, context, msgid)
end

macro npgettext(context, msgid, msgid_plural, n)
    _gettext_macro(npgettext, context, msgid, msgid_plural, n)
end

"""
    N_"..."

"No-op" translation, equivalent to "...", for strings that do not require translation.

(The main use of this macro is to explicitly mark strings to ensure that they are excluded
from automated translation tools).
"""
macro N__str(s)
    :($(esc(unescape_string(s))))
end

################################################################################################

export bindtextdomain, textdomain, gettext, pgettext, ngettext, npgettext,
       @__str, @N__str, @gettext, @ngettext, @pgettext, @npgettext

end # module
