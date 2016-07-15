EAPI="6"

PYTHON_COMPAT=( python2_7 )

inherit git-r3 distutils-r1

DESCRIPTION="Athena locker commands"
HOMEPAGE="https://sipb.mit.edu/"
EGIT_REPO_URI="https://github.com/mit-athena/locker-support.git"
if [[ "${PV}" != "9999" ]]; then
	EGIT_COMMIT="refs/tags/release/${PV}"
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	${RDEPEND}
	dev-python/afs-python[${PYTHON_USEDEP}]
	dev-python/hesiod-python[${PYTHON_USEDEP}]
"
