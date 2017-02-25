EAPI="6"

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit distutils-r1

DESCRIPTION="python wrapper for Philips Hue API"
HOMEPAGE="https://github.com/quentinsf/${PN}"
SRC_URI="https://github.com/quentinsf/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
