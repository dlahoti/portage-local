EAPI="6"

PYTHON_COMPAT=( python3_{3,4,5} )

inherit git-r3 distutils-r1

DESCRIPTION="neovim support for --remote and friends"
HOMEPAGE="https://github.com/mhinz/neovim-remote"
EGIT_REPO_URI="https://github.com/mhinz/neovim-remote.git"
if [[ "${PV}" != "9999" ]]; then
	EGIT_COMMIT="refs/tags/${PV}"
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	app-editors/neovim
"
DEPEND="
	${RDEPEND}
	app-text/pandoc
"

src_prepare() {
	default

	emake rst
}
