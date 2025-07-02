module Gettext

using GettextRuntime_jll

const LC_ALL = zero(Cint)
function setlocale(locale::AbstractString="")
    ret = ccall(:setlocale, Ptr{UInt8}, (Cint, Cstring), LC_ALL, "")
    ret == C_NULL && throw(ArgumentError("invalid locale $locale"))
    return unsafe_string(ret)
end


function __init__()
    # initialize locale from environment
    setlocale()
end

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
    return dir_name
end

gettext(msgid::AbstractString) = unsafe_string(ccall((:libintl_gettext,libintl), Cstring, (Cstring,), msgid))
dgettext(domain::AbstractString, msgid::AbstractString) = unsafe_string(ccall((:libintl_dgettext,libintl), Cstring, (Cstring, Cstring,), domain, msgid))

ngettext(msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:libintl_ngettext,libintl), Cstring, (Cstring,Cstring,Culong), msgid, msgid_plural, n))
dngettext(domain::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:libintl_dngettext,libintl), Cstring, (Cstring,Cstring,Cstring,Culong), domain, msgid, msgid_plural, n))

macro __str(s)
    :(gettext($(esc(s))))
end

macro N__str(s)
    :($(esc(s)))
end

export bindtextdomain, textdomain, gettext, dgettext, ngettext, dngettext, @__str, @N__str

end # module
