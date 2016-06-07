EAPI="6"

inherit systemd

DESCRIPTION="systemd unit files for AppArmor"
HOMEPAGE="http://github.com/dlahoti/portage-local"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	sys-apps/systemd
	sys-apps/apparmor"

RDEPEND="${DEPEND}"

pkg_setup() {
	mkdir -p "${S}"
}

src_install() {
	systemd_dounit "${FILESDIR}/apparmor.target"
	systemd_dounit "${FILESDIR}/apparmor@.service"
}
