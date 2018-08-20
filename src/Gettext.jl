module Gettext

using PyCall

const gt = PyNULL()

function __init__()
    copy!(gt, pyimport("gettext"))
end

bindtextdomain(domain, localedir=nothing) = gt[:bindtextdomain](domain, localedir)
textdomain(domain=nothing) = gt[:textdomain](domain)

gettext(message) = gt[:gettext](message)
dgettext(domain, message) = gt[:dgettext](domain, message)
ngettext(singular, plural, n) = gt[:ngettext](singular, plural, n)
dngettext(domain, singular, plural, n) = gt[:dngettext](domain, singular, plural, n)

macro __str(s)
    gettext(s)
end

macro N__str(s)
    s
end

export bindtextdomain, textdomain, gettext, lgettext, dgettext, dlgettext, ngettext, lngettext, dngettext, ldngettext, @__str, @N__str

end # module
