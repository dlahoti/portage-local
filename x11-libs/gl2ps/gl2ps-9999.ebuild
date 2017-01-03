# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit cmake-utils subversion

DESCRIPTION="OpenGL to PostScript printing library"
HOMEPAGE="http://www.geuz.org/gl2ps/"
ESVN_REPO_URI="https://geuz.org/svn/gl2ps/trunk"
ESVN_OPTIONS="--trust-server-cert"
ESVN_USER="gl2ps"
ESVN_PASSWORD="gl2ps"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc png zlib"

RDEPEND="
	media-libs/freeglut
	x11-libs/libXmu
	png? ( media-libs/libpng:0= )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	doc? (
		dev-tex/tth
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexrecommended )"

PATCHES=( "${FILESDIR}"/${PN}-1.3.8-cmake.patch )

src_prepare() {
	cmake-utils_src_prepare
	sed '/^install.*TODO\.txt/d' -i "${S}"/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DUSE_ENABLE_DOC="$(usex doc)"
		-DUSE_ENABLE_PNG="$(usex png)"
		-DUSE_ENABLE_ZLIB="$(usex zlib)"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	if [[ ${CHOST} == *-darwin* ]] ; then
		install_name_tool \
			-id "${EPREFIX}"/usr/$(get_libdir)/libgl2ps.dylib \
			"${D%/}${EPREFIX}"/usr/$(get_libdir)/libgl2ps.dylib || die
	fi
}
