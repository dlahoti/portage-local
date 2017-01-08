EAPI=6

inherit toolchain-funcs flag-o-matic

MY_PN="tdesktop"
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="official telegram protocol client"
HOMEPAGE="https://desktop.telegram.org/"
QTVER="5.6.0"
KEYWORDS="~amd64 ~x86"
SRC_URI="
	https://github.com/telegramdesktop/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	http://download.qt.io/official_releases/qt/${QTVER%.*}/$QTVER/submodules/qtbase-opensource-src-$QTVER.tar.xz
	http://download.qt.io/official_releases/qt/${QTVER%.*}/$QTVER/submodules/qtimageformats-opensource-src-$QTVER.tar.xz
	"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug"

DEPEND="
	dev-libs/libappindicator:3
	sys-libs/zlib
	virtual/ffmpeg
	app-arch/xz-utils
	media-libs/opus
	media-libs/openal
	x11-libs/libva
	"
RDEPEND="${DEPEND}"

# taken from qmake-utils.eclass
# modified to use custom qmake
eqmake5() {
	debug-print-function ${FUNCNAME} "$@"

	ebegin "Running qmake"

	"${S}/qt/bin/qmake" \
		-makefile \
		QMAKE_AR="$(tc-getAR) cqs" \
		QMAKE_CC="$(tc-getCC)" \
		QMAKE_LINK_C="$(tc-getCC)" \
		QMAKE_LINK_C_SHLIB="$(tc-getCC)" \
		QMAKE_CXX="$(tc-getCXX)" \
		QMAKE_LINK="$(tc-getCXX)" \
		QMAKE_LINK_SHLIB="$(tc-getCXX)" \
		QMAKE_OBJCOPY="$(tc-getOBJCOPY)" \
		QMAKE_RANLIB= \
		QMAKE_STRIP= \
		QMAKE_CFLAGS="${CFLAGS}" \
		QMAKE_CFLAGS_RELEASE= \
		QMAKE_CFLAGS_DEBUG= \
		QMAKE_CXXFLAGS="${CXXFLAGS}" \
		QMAKE_CXXFLAGS_RELEASE= \
		QMAKE_CXXFLAGS_DEBUG= \
		QMAKE_LFLAGS="${LDFLAGS}" \
		QMAKE_LFLAGS_RELEASE= \
		QMAKE_LFLAGS_DEBUG= \
		"$@"

	if ! eend $? ; then
		echo
		eerror "Running qmake has failed! (see above for details)"
		eerror "This shouldn't happen - please send a bug report to https://bugs.gentoo.org/"
		echo
		die "eqmake5 failed"
	fi
}

src_prepare() {
	cd "${S}" || die
	mkdir -v -p "${S}/Libraries" || die

	local qt_patch_file="${S}/Telegram/Patches/qtbase_${QTVER//./_}.diff"
	local qt_src_dir="${S}/Libraries/qt${QTVER//./_}"
	if [[ "${qt_patch_file}" -nt "${qt_src_dir}" ]]; then
		rm -rf "${qt_src_dir}" || die
		mkdir -v -p "${qt_src_dir}" || die

		mv "${WORKDIR}/qtbase-opensource-src-${QTVER}" "${qt_src_dir}/qtbase" || die
		mv "${WORKDIR}/qtimageformats-opensource-src-${QTVER}" "${qt_src_dir}/qtimageformats" || die

		cd "${qt_src_dir}/qtbase" || die
		epatch "${qt_patch_file}"
	fi

	# taken from qt5-build.eclass
	# Avoid unnecessary qmake recompilations
	sed -i -re "s|^if true;.*(\[ '\!').*(\"\\\$outpath/bin/qmake\".*)|if \1 -e \2 then|" \
		configure || die "sed failed (skip qmake bootstrap)"

	# Respect CC, CXX, *FLAGS, MAKEOPTS and EXTRA_EMAKE when bootstrapping qmake
	sed -i -e "/outpath\/qmake\".*\"\$MAKE\")/ s:): \
		${MAKEOPTS} ${EXTRA_EMAKE} 'CC=$(tc-getCC)' 'CXX=$(tc-getCXX)' \
		'QMAKE_CFLAGS=${CFLAGS}' 'QMAKE_CXXFLAGS=${CXXFLAGS}' 'QMAKE_LFLAGS=${LDFLAGS}'&:" \
		-e 's/\(setBootstrapVariable\s\+\|EXTRA_C\(XX\)\?FLAGS=.*\)QMAKE_C\(XX\)\?FLAGS_\(DEBUG\|RELEASE\).*/:/' \
		configure || die "sed failed (respect env for qmake build)"
	sed -i -e '/^CPPFLAGS\s*=/ s/-g //' \
		qmake/Makefile.unix || die "sed failed (CPPFLAGS for qmake build)"

	# Respect CXX in bsymbolic_functions, fvisibility, precomp, and a few other tests
	sed -i -e "/^QMAKE_CONF_COMPILER=/ s:=.*:=\"$(tc-getCXX)\":" \
		configure || die "sed failed (QMAKE_CONF_COMPILER)"

	# Respect toolchain and flags in config.tests
	find config.tests/unix -name '*.test' -type f -execdir \
		sed -i -e 's/-nocache //' '{}' + || die

	# Don't inject -msse/-mavx/... into CXXFLAGS when detecting
	# compiler support for extended instruction sets (bug 552942)
	find config.tests/common -name '*.pro' -type f -execdir \
		sed -i -e '/QMAKE_CXXFLAGS\s*+=/ d' '{}' + || die

	# Don't add -O3 to CXXFLAGS (bug 549140)
	sed -i -e '/CONFIG\s*+=/ s/optimize_full//' \
		src/{corelib/corelib,gui/gui}.pro || die "sed failed (optimize_full)"
	# end taken portion

	# taken from other telegram ebuild
	local mode=release;
	local sedargs=()

	use debug && mode=debug;

	rm -r "${S}/Telegram/ThirdParty"

	# Safety newline, just for sure
	sed -i '$a\\n' "${S}/Telegram/Telegram.pro"

	local deps=(
		'appindicator3-0.1'
		'minizip'
	)
	local libs=(
		"${deps[@]}"
		'lib'{avcodec,avformat,avutil,swresample,swscale,va,lzma}
		'opus'
		'openal'
		'openssl'
		'libproxy-1.0'
		'x11'
		'zlib'
	)
	local defs=(
		"TDESKTOP_DISABLE_AUTOUPDATE"
		"TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME"
		"TDESKTOP_DISABLE_CRASH_REPORTS"
		"TDESKTOP_DISABLE_UNITY_INTEGRATION"
	)
	local includes=( "${deps[@]}" ) # dee-1.0 # TODO

	sedargs+=(
		# delete any references to local includes/libs
		-e 's|[^ ]*/usr/local/[^ \\]* *(\\?)| \1|'
		# delete any hardcoded includes
		-e 's|(.*INCLUDEPATH *\+= *"/usr.*)|#__hardcoded includes#\1|'
		# delete any hardcoded libs
		-e 's|(.*LIBS *\+= *-l.*)|#__hardcoded libs#\1|'
		# delete refs to bundled Google Breakpad
		-e 's|(.*breakpad/src.*)|#__hardcoded Google Breakpad#\1|'
		# delete refs to bundled minizip, Gentoo uses it's own patched version
		-e 's|(.*minizip.*)|#__hardcoded minizip#\1|'
		# delete CUSTOM_API_ID defines, use default ID
		-e 's|(.*CUSTOM_API_ID.*)|#CUSTOM_API_ID#\1|'
		# remove hardcoded flags
		-e 's|(.*QMAKE_[A-Z]*FLAGS.*)|#__hardcoded flags#\1|'
		# use release versions
		-e "s:Debug(Style|Lang):${mode^}\1:g"
		-e "s|/Debug|/${mode^}|g"
		# fix Qt version
		-e "s|5.6.0|${qt_ver}|g"
		-e "/#__hardcoded .*#/d"
		-e "/stdafx.cpp/d"
	)

	for i in "${includes[@]}"; do
		sedargs+=( -e "\$aQMAKE_CXXFLAGS += $(pkg-config --cflags-only-I ${i})" )
	done

	for l in "${libs[@]}"; do
		sedargs+=( -e "\$aLIBS += $(pkg-config --libs ${l})" )
	done

	for d in "${defs[@]}"; do
		sedargs+=( -e "\$aDEFINES += ${d}" )
	done

	sed -i -r "${sedargs[@]}" "${S}/Telegram/Telegram.pro" || die "Can't patch Telegram.pro"
	# end taken portion

	default
}

src_configure() {
	local qt_src_dir="${S}/Libraries/qt${QTVER//./_}"
	local mode=release

	use debug && mode=debug

	cd "${qt_src_dir}/qtbase" || die
	./configure \
		-prefix "${S}/qt" \
		-${mode} \
		-force-debug-info \
		-opensource \
		-confirm-license \
		-system-zlib \
		-system-libpng \
		-system-libjpeg \
		-system-freetype \
		-system-harfbuzz \
		-system-pcre \
		-system-xcb \
		-system-xkbcommon-x11 \
		-no-opengl \
		-static \
		-nomake examples \
		-nomake tests
}

src_compile() {
	local qt_src_dir="${S}/Libraries/qt${QTVER//./_}"
	local mode=release
	local d module

	use debug && mode=debug

	cd "${qt_src_dir}/qtbase" || die
	elog "Building Qt ${QTVER}"
	emake
	emake install

	cd "${qt_src_dir}/qtimageformats"
	eqmake5
	emake
	emake install

	for module in style numbers; do
		d="${S}/Linux/obj/codegen_${module}/${mode^}"
		mkdir -v -p "${d}" && cd "${d}" || die

		elog "Building ${PWD/${S}\/}"
		eqmake5 CONFIG+=${mode} "${S}/Telegram/build/qmake/codegen_${module}/codegen_${module}.pro"
		emake
	done

	for module in Lang; do
		d="${S}/Linux/${mode^}Intermediate${module}"
		mkdir -v -p "${d}" && cd "${d}" || die

		elog "Building ${PWD/${S}\/}"
		eqmake5 QT_TDESKTOP_PATH="${S}/qt" QT_TDESKTOP_VERSION="${QTVER}" CONFIG+="${mode}" "${S}/Telegram/Meta${module}.pro"
		emake
	done

	d="${S}/Linux/${mode^}Intermediate"
	mkdir -v -p "${d}" && cd "${d}" || die

	elog "Preparing the main build..."
	"${S}/Linux/codegen/${mode^}/codegen_style" \
		-I"${S}/Telegram/Resources" \
		-I"${S}/Telegram/SourceFiles" \
		-o"${S}/Telegram/GeneratedFiles/styles" \
		all_files.style --rebuild || die
	"${S}/Linux/codegen/${mode^}/codegen_numbers" \
		-o"${S}/Telegram/GeneratedFiles" \
		"${S}/Telegram/Resources/numbers.txt" || die
	"${S}/Linux/${mode^}Lang/MetaLang" \
		-lang_in "${S}/Telegram/Resources/langs/lang.strings" \
		-lang_out "${S}/Telegram/GeneratedFiles/lang_auto" || die

	elog "Building Telegram..."
	eqmake5 QT_TDESKTOP_PATH="${S}/qt" QT_TDESKTOP_VERSION="${QTVER}" CONFIG+="${mode}" "${S}/Telegram/Telegram.pro"
	emake
}

src_install() {
	newbin "${S}/Linux/Release/Telegram" "telegram-desktop"

	insinto /usr/share/applications
	doins "${FILESDIR}/telegramdesktop.desktop"

	insinto /usr/share/kde4/services
	doins "${FILESDIR}/tg.protocol"

	local icon_size
	for icon_size in 16 32 48 64 128 256 512; do
		insinto /usr/share/icons/hicolor/${icon_size}x${icon_size}/apps
		newins "${S}/Telegram/Resources/art/icon${icon_size}.png" telegram-desktop.png
	done
}
