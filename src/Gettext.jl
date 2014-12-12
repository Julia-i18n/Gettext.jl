module Gettext

using PyCall

@pyimport gettext as gt

bindtextdomain(domain, localedir=nothing) = gt.bindtextdomain(domain, localedir)
textdomain(domain=nothing) = gt.textdomain(domain)

gettext(message) = gt.gettext(message)
lgettext(message) = gt.lgettext(message)
dgettext(domain, message) = gt.dgettext(domain, message)
dlgettext(domain, message) = gt.dlgettext(domain, message)
ngettext(singular, plural, n) = gt.ngettext(singular, plural, n)
lngettext(singular, plural, n) = gt.lngettext(singular, plural, n)
dngettext(domain, singular, plural, n) = gt.dngettext(domain, singular, plural, n)
ldngettext(domain, singular, plural, n) = gt.ldngettext(domain, singular, plural, n)

macro __str(s)
  gettext(s)
end

export bindtextdomain, textdomain, gettext, lgettext, dgettext, dlgettext, ngettext, lngettext, dngettext, ldngettext, @__str

end # module
