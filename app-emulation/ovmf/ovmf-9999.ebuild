EAPI="6"

inherit git-r3

DESCRIPTION="open virtual machine firmware"
HOMEPAGE="http://www.tianocore.org/edk2/"
EGIT_REPO_URI="https://github.com/tianocore/edk2.git"
KEYWORDS=""

LICENSE=""
SLOT="0"
IUSE="debug"

DEPEND="
	>=sys-devel/gcc-5.0.0
	>=sys-devel/binutils-2.21.1
	sys-power/iasl
"
RDEPEND=""

TOOL_CHAIN_TAG="GCC5"

src_prepare() {
	sedargs=(
		-e "s:= Nt32Pkg/Nt32Pkg.dsc:= OvmfPkg/OvmfPkgX64.dsc:"
		-e "s:= IA32:= X64:"
		-e "s:= MYTOOLS:= ${TOOL_CHAIN_TAG}:"
	)
	use !debug && sedargs+=( -e "s:= DEBUG:= RELEASE:" )
	sed -i "${sedargs[@]}" "${S}/BaseTools/Conf/target.template" || die

	eapply_user
}

src_configure() {
	emake -j1 -C "${S}/BaseTools" ARCH=X64

	source "${S}/edksetup.sh" BaseTools
}

src_compile() {
	build || die
}

src_install() {
	local target="RELEASE"
	use debug && target="DEBUG"
	cd "${S}/Build/OvmfX64/${target}_${TOOL_CHAIN_TAG}/FV"
	insinto /usr/share/OVMF
	doins OVMF_CODE.fd
	doins OVMF_VARS.fd
}
