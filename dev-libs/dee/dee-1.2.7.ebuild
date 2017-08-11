EAPI="6"

PYTHON_COMPAT=( python2_7 )

inherit python-r1

DESCRIPTION="Libdee is a library that uses DBus to provide objects allowing you to create Model-View-Controller type programs across DBus"
HOMEPAGE="https://launchpad.net/dee"
KEYWORDS="~amd64 ~x86"
SRC_URI="https://launchpad.net/${PN}/1.0/${PV}/+download/${P}.tar.gz"

RESTRICT="mirror"

LICENSE="LGPL"
SLOT="0"
IUSE=""

DEPEND="
	dev-lang/vala
	dev-libs/gobject-introspection
	${PYTHON_DEPS}
	"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/fix-misleading-indentation.patch"
	default
}

src_configure() {
	python_setup
	econf --disable-static --disable-tests
}

src_compile() {
	python_setup
	default
}

src_install() {
	python_setup
	default
}
