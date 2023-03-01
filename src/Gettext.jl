module Gettext

using Gettext_jll

textdomain() = unsafe_string(ccall((:textdomain,libgettext), Cstring, (Ptr{UInt8},), C_NULL))
function textdomain(domain::AbstractString)
    # textdomain(domain) returns the domain as a string, but
    # you are required to not free the result.  Might as well ignore it.
    ccall((:textdomain,libgettext), Cstring, (Cstring,), domain)
    return domain
end

bindtextdomain(domain::AbstractString) = unsafe_string(ccall((:bindtextdomain,libgettext), Cstring, (Cstring, Ptr{UInt8},), domain, C_NULL))
function bindtextdomain(domain::AbstractString, dir_name::AbstractString)
    # bintextdomain(domain, dir_name) returns the dir_name as a string, but
    # you are required to not free the result.  Might as well ignore it.
    @static if Sys.iswindows()
        ccall((:wbindtextdomain,libgettext), Cwstring, (Cstring,Cwstring), domain, dir_name)
    else
        ccall((:bindtextdomain,libgettext), Cstring, (Cstring,Cstring), domain, dir_name)
    end
    return dir_name
end

gettext(msgid::AbstractString) = unsafe_string(ccall((:gettext,libgettext), Cstring, (Cstring,), msgid))
dgettext(domain::AbstractString, msgid::AbstractString) = unsafe_string(ccall((:dgettext,libgettext), Cstring, (Cstring, Cstring,), domain, msgid))

ngettext(msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:ngettext,libgettext), Cstring, (Cstring,Cstring,Culong), msgid, msgid_plural, n))
dngettext(domain::AbstractString, msgid::AbstractString, msgid_plural::AbstractString, n::Integer) = unsafe_string(ccall((:dngettext,libgettext), Cstring, (Cstring,Cstring,Cstring,Culong), domain, msgid, msgid_plural, n))

macro __str(s)
    gettext(s)
end

macro N__str(s)
    s
end

export bindtextdomain, textdomain, gettext, dgettext, ngettext, dngettext, @__str, @N__str

end # module
