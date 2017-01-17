EAPI="6"

inherit cmake-utils

DESCRIPTION="transparently integrate the nodes of a distributed system into a single OpenCL platform"
HOMEPAGE="https://github.com/dlahoti/dopencl"
SRC_URI="https://github.com/dlahoti/dopencl/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-libs/opencl-clhpp-2.0.10-r1
	>=dev-libs/boost-1.41.0
	virtual/opencl
	"
DEPEND="
	${RDEPEND}
	>=dev-util/cmake-2.6
	"
