EAPI=6

inherit toolchain-funcs flag-o-matic git-r3 cmake-utils

DESCRIPTION="official telegram protocol client"
HOMEPAGE="https://desktop.telegram.org/"
KEYWORDS="~amd64 ~x86"
EGIT_REPO_URI="
	https://github.com/telegramdesktop/tdesktop.git
	"
EGIT_COMMIT="refs/tags/v${PV}"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug"

DEPENDS="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtimageformats:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-libs/libappindicator:2
	sys-libs/zlib
	virtual/ffmpeg
	app-arch/xz-utils
	media-libs/opus
	media-libs/openal
	x11-libs/libva
	"
DEPEND="${DEPENDS}
	dev-util/gyp
	dev-util/cmake
	media-sound/pulseaudio
	"
RDEPEND="${DEPENDS}
	media-fonts/open-sans
	"

# based on AUR telegram-desktop-systemqt

src_prepare() {
	epatch "${FILESDIR}/tdesktop.patch"

	cd "Telegram/ThirdParty/libtgvoip"
	epatch "${FILESDIR}/libtgvoip.patch"

	eapply_user
}

src_configure() {
	BUILDTYPE=$(usex debug Debug Release)

	export LANG=en_US.UTF-8
	export GYP_DEFINES="TDESKTOP_DISABLE_CRASH_REPORTS,TDESKTOP_DISABLE_AUTOUPDATE,TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME"
	append-cxxflags "-DTDESKTOP_DISABLE_AUTOUPDATE" "-DTDESKTOP_DISABLE_CRASH_REPORTS" "-DTDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME" "-Winvalid-pch" "-std=gnu++11"

	QTVER="$(pkg-config --modversion Qt5Core)"
	sed -i -e "s:/usr/lib/qt:/usr/lib/qt5:" -e "s:/usr/include/qt:/usr/include/qt5:" \
		-e "s|'qt_version%': '[0-9]*\.[0-9]*\.[0-9]*'|'qt_version%': '${QTVER}'|" \
		"${S}/Telegram/gyp/qt.gypi" || die "failed to patch qt.gypi!"

	gyp -Dbuild_defines="${GYP_DEFINES:1}" -Gconfig="${BUILDTYPE}" \
		--depth=Telegram/gyp --generator-output=../.. -Goutput_dir=out \
		Telegram/gyp/Telegram.gyp --format=cmake || die "gyp failed!"

	N=$(($(wc -l <out/"${BUILDTYPE}"/CMakeLists.txt) - 2))
	sed -i "$N r ${FILESDIR}/CMakeLists.inj" "${S}/out/${BUILDTYPE}/CMakeLists.txt" \
		|| die "failed to patch CMakeLists.txt!"

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_VERBOSE_MAKEFILE=ON
		-DCMAKE_BUILD_TYPE=None
	)
	S="${S}/out/${BUILDTYPE}" cmake-utils_src_configure
}

src_compile() {
	export QT_SELECT=5
	cmake-utils_src_compile
}

src_install() {
	newbin "${CMAKE_BUILD_DIR}/Telegram" "telegram-desktop"

	insinto /usr/share/applications
	doins "${FILESDIR}/telegramdesktop.desktop"

	insinto /usr/share/kservices5
	doins "${FILESDIR}/tg.protocol"

	local icon_size
	for icon_size in 16 32 48 64 128 256 512; do
		insinto /usr/share/icons/hicolor/${icon_size}x${icon_size}/apps
		newins "${S}/Telegram/Resources/art/icon${icon_size}.png" telegram-desktop.png
	done
}
