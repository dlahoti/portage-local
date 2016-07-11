EAPI="6"

inherit git-r3 autotools

DESCRIPTION="The Moira service management system"
HOMEPAGE="https://sipb.mit.edu/"
EGIT_REPO_URI="https://github.com/achernya/hesiod.git"
if [[ "${PV}" != "9999" ]]; then
	EGIT_COMMIT="refs/tags/hesiod-${PV}"
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"
IUSE="+idn"

DEPEND="
	idn? ( net-dns/libidn )
	"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user

	cd "${S}" || die
	eautoreconf
}

src_configure() {
	econf $(use_with idn libidn) --sysconfdir="${EPREFIX}/etc"
}
