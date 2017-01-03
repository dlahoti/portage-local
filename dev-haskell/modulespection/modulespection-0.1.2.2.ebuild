# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# ebuild generated by hackport 0.5

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Template Haskell for introspecting a module's declarations"
HOMEPAGE="https://github.com/jfischoff/modulespection"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/exceptions-0.5:=[profile?]
	>=dev-haskell/ghc-paths-0.1:=[profile?] <dev-haskell/ghc-paths-0.2:=[profile?]
	>=dev-haskell/temporary-1.2:=[profile?] <dev-haskell/temporary-1.3:=[profile?]
	>=dev-lang/ghc-7.6.1:=
	|| ( ( >=dev-haskell/transformers-0.3:=[profile?] <dev-haskell/transformers-0.4:=[profile?] )
		( >=dev-haskell/transformers-0.4:=[profile?] <dev-haskell/transformers-0.5:=[profile?] ) )
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.16.0
"

src_prepare() {
	cabal_chdeps 'exceptions >= 0.5 && < 0.7' 'exceptions >= 0.5'
	cabal_chdeps 'filepath == 1.3.*' 'filepath >= 1.3'

	eapply_user
}