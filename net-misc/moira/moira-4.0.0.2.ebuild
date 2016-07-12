EAPI="6"

inherit git-r3 autotools

DESCRIPTION="The Moira service management system"
HOMEPAGE="https://sipb.mit.edu/"
EGIT_REPO_URI="https://github.com/mit-athena/moira.git"
if [[ "${PV}" != "9999" ]]; then
	EGIT_COMMIT="refs/tags/${PV}"
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"
IUSE="+hesiod"

DEPEND="
	app-crypt/mit-krb5
	sys-libs/libtermcap-compat
	hesiod? ( net-dns/hesiod )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/moira"

src_prepare() {
	local client toreplace

	cd "${S}" || die
	for client in chfn chsh; do
		toreplace=(
			"clients/Makefile.in"
			"clients/${client}/Makefile.in"
			"configure.in"
			"man/Makefile.in"
			"man/${client}.1"
			"man/moira.1"
			"configure"
		)
		for file in "${toreplace[@]}"; do
			sed -i -e "s:${client}:mr${client}:g" "${S}/${file}" || die
		done
		mv "${S}/man/${client}.1" "${S}/man/mr${client}.1" || die
		mv "${S}/clients/${client}/${client}.c" "${S}/clients/${client}/mr${client}.c" || die
		mv "${S}/clients/${client}" "${S}/clients/mr${client}" || die
	done

	eapply_user

	cd "${S}/util/et" || die
	eautoreconf
}

src_configure() {
	cd "${S}/util/et" || die
	econf

	cd "${S}" || die
	econf --with-krb5="${EPREFIX}/usr/lib" $(use_with hesiod hesiod=/usr/lib) CFLAGS=-fPIC
}

src_compile() {
	cd "${S}/util/et" || die
	emake

	cd "${S}" || die
	emake
}
