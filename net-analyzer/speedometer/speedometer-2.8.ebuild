EAPI="6"

DESCRIPTION="Measure and display the rate of data across a network connection or data being stored in a file"
HOMEPAGE="https://excess.org/speedometer/"
SRC_URI="https://excess.org/speedometer/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/urwid"

src_prepare() {
	sed -i -e 's:#!/usr/bin/python:#!/usr/bin/env python2:g' "${S}/speedometer.py"
	default
}

src_install() {
	newbin "${S}/speedometer.py" speedometer
}
