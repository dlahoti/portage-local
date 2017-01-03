EAPI=6

inherit git-r3 cmake-utils

DESCRIPTION="a cross-platform implementation of various reaction-diffusion systems"
HOMEPAGE="https://github.com/GollyGang/ready"
EGIT_REPO_URI="https://github.com/GollyGang/ready.git"
#SRC_URI="https://github.com/GollyGang/ready/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc"

RDEPEND="
	>=x11-libs/wxGTK-2.9.2
	x11-libs/libXt
	virtual/opencl
	media-libs/mesa
	dev-libs/ocl-icd
	>=sci-libs/vtk-6.2
	"
DEPEND="
	${RDEPEND}
	>=dev-util/cmake-3.3
	doc? ( app-doc/doxygen )
	"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_use cpu_flags_x86_sse SSE)
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		cmake-utils_src_make doc
	fi
}
