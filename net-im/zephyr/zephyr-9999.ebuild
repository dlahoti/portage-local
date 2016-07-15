EAPI="6"

inherit git-r3 autotools user

DESCRIPTION="The Zephyr notification system"
HOMEPAGE="https://zephyr-im.org/"
EGIT_REPO_URI="https://github.com/zephyr-im/zephyr.git"
if [[ "${PV}" != "9999" ]]; then
	EGIT_COMMIT="refs/tags/release/${PV}"
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"
IUSE="X +cares cmu +com_err +hesiod +iconv +kerberos +ss systemd"
REQUIRED_USE="ss? ( com_err )"

DEPEND="
	|| ( sys-libs/ncurses sys-libs/libtermcap-compat )
	X? ( x11-libs/libX11 x11-proto/xproto )
	cares? ( net-dns/c-ares )
	com_err? ( sys-libs/e2fsprogs-libs )
	hesiod? ( net-dns/hesiod )
	iconv? ( virtual/libiconv )
	kerberos? ( virtual/krb5 )
"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewuser zephyr -1 -1 /etc/zephyr
}

src_prepare() {
	eapply_user

	eautoreconf
}

src_configure() {
	econf $(use_with com_err) $(use_with ss) $(use_with cares) $(use_with X x) $(use_with hesiod) $(use_with kerberos krb5) \
		$(use_enable cmu cmu-zwgcplus) $(use_enable cmu cmu-zctl-punt) $(use_enable cmu cmu-hm-flush-restrict) $(use_enable cmu cmu-opstaff-locate-self)
}

src_install() {
	default

	newinitd "${FILESDIR}/zhm.init" zhm
	newconfd "${FILESDIR}/zhm.conf" zhm
	if use systemd; then
		insinto /usr/lib/systemd/system
		doins "${FILESDIR}/zhm.service"
	fi

	insinto /etc/zephyr
	newins "${FILESDIR}/zhm.etc" config
}
