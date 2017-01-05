EAPI="6"

inherit multilib

DESCRIPTION="forward OpenCL over a network"
HOMEPAGE="http://www.mosix.cs.huji.ac.il/index.html"
SRC_URI="http://www.mosix.cs.huji.ac.il/vcl/VCL-${PV}.tbz"

LICENSE="VCL"
SLOT="0"
IUSE="client server"
KEYWORDS="-* ~amd64"

REQUIRED_USE="|| ( client server )"

RDEPEND="
	app-eselect/eselect-opencl
	"
DEPEND=""

S="${WORKDIR}/vcl-${PV}"

CL_DIR="usr/$(get_libdir)/OpenCL/vendors/virtualcl"
ETC_DIR="etc/vcl"

QA_PREBUILT="${S}/*"

src_install() {
	insinto /usr/include
	doins "${S}/supercl.h"

	mkdir -p "${ETC_DIR}" || die "failed to make vcl config directory!"

	if use server; then
		newsbin "${S}/opencld" "vcld"
		touch "${ETC_DIR}/is_back_end" || die "failed to enable server mode!"
	fi

	if use client; then
		newsbin "${S}/broker" "vclbroker"
		dobin "${S}/vclrun"
		touch "${ETC_DIR}/is_host" || die "failed to enable client mode!"

		insinto "${CL_DIR}"
		insopts -m 755
		doins "${S}/libOpenCL.so"
		dosym "libOpenCL.so" "${CL_DIR}/libOpenCL.so.1"
		dosym "libOpenCL.so" "${CL_DIR}/libOpenCL.so.1.0.0"
		dosym "libOpenCL.so" "${CL_DIR}/libOpenCL.so.1.2"
	fi

	doman "${S}/man/man7/vcl.7"
	doman "${S}/man/man3/supercl.3"
}
