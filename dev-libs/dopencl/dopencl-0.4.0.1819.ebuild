EAPI="6"

inherit cmake-utils

MY_PV="0.4.0_r1819"
MY_P="${PN}-${MY_PV}-asio"

DESCRIPTION="transparently integrate the nodes of a distributed system into a single OpenCL platform"
HOMEPAGE="http://www.uni-muenster.de/PVS/en/research/dopencl/"
SRC_URI="${MY_P}.tar.gz"
RESTRICT="fetch"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${MY_P}"

RDEPEND="
	>=dev-libs/opencl-clhpp-2.0.10-r1
	>=dev-libs/boost-1.41.0
	virtual/opencl
	"
DEPEND="
	${RDEPEND}
	>=dev-util/cmake-2.6
	"
