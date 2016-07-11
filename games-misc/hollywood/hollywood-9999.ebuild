EAPI=6

inherit git-r3

DESCRIPTION="Hollywood-style noisy text displayed on the screen"
HOMEPAGE="https://github.com/dustinkirkland/hollywood"
EGIT_REPO_URI="https://github.com/dustinkirkland/hollywood.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+apg +bmon +ccze +cmatrix +code +errno +hexdump +htop +jp2a +logs +man mplayer +mpv +speedometer +sshart +stat +tree"

DEPEND="
	app-misc/byobu
	sys-apps/coreutils
	apg? ( app-admin/apg )
	bmon? ( net-analyzer/bmon )
	ccze? ( app-admin/ccze )
	cmatrix? ( app-misc/cmatrix )
	code? ( sys-apps/mlocate dev-python/pygments )
	errno? ( sys-apps/moreutils )
	hexdump? ( sys-apps/util-linux )
	htop? ( sys-process/htop )
	jp2a? ( sys-apps/mlocate media-gfx/jp2a )
	mplayer? ( media-video/mplayer[libcaca] )
	mpv? ( media-video/mpv[libcaca] )
	speedometer? ( net-analyzer/speedometer )
	sshart? ( net-misc/openssh )
	tree? ( app-text/tree )
	"
RDEPEND="${DEPEND}"

src_prepare() {
	cd "${S}/lib/hollywood" || die
	if ! use ccze; then
		sed -i -e 's:^command -v ccze.*::g' -e 's: | ccze [^|]*::g' * || die
	fi
	if use mpv; then
		cp mplayer mpv || die
		sed -i -e 's:mplayer:mpv:g' mpv || die
	fi
	sed -i -e 's:^widget_dir=.*:widget_dir=/usr/libexec/$PKG:g' "${S}/bin/hollywood" || die

	default
}

src_install() {
	dobin "${S}/bin/hollywood"

	exeinto /usr/libexec/hollywood
	for widget in apg bmon cmatrix code errno hexdump htop jp2a logs man mplayer mpv speedometer sshart stat tree; do
		use "${widget}" && doexe "${S}/lib/hollywood/${widget}"
	done

	doman "${S}/share/man/man1/hollywood.1"

	insinto /usr/share/hollywood
	doins "${S}/share/hollywood/mi.mp4"
}
