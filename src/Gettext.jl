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
    # bintextdomain(domain, dir_name) returns the dir_name as a string, but
    # you are required to not free the result.  Might as well ignore it.
    @static if Sys.iswindows()
        ccall((:libintl_wbindtextdomain,libintl), Cwstring, (Cstring,Cwstring), domain, dir_name)
    else
        ccall((:libintl_bindtextdomain,libintl), Cstring, (Cstring,Cstring), domain, dir_name)
    end
    ccall((:libintl_bind_textdomain_codeset,libintl), Cstring, (Cstring,Cstring), domain, "UTF-8")
    return dir_name
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

macro __str(s)
    :(gettext($(esc(unescape_string(s)))))
end

macro N__str(s)
    :($(esc(unescape_string(s))))
end

export bindtextdomain, textdomain, gettext, pgettext, ngettext, npgettext, @__str, @N__str

end # module
