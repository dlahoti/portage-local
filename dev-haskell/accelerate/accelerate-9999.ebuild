# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# ebuild partially generated by hackport 0.5

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal git-r3

DESCRIPTION="An embedded language for accelerated array processing"
HOMEPAGE="https://github.com/AccelerateHS/accelerate/"
EGIT_REPO_URI="https://github.com/AccelerateHS/accelerate.git"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS=""
IUSE="+bounds-checks debug ekg internal-checks unsafe-checks"

RDEPEND=">=dev-haskell/base-orphans-0.3:=[profile?]
	>=dev-haskell/exceptions-0.6:=[profile?]
	>=dev-haskell/fclabels-2.0:=[profile?]
	>=dev-haskell/hashable-1.1:=[profile?]
	>=dev-haskell/hashtables-1.0:=[profile?]
	>=dev-haskell/mtl-2.0:=[profile?]
	>=dev-haskell/transformers-0.3:=[profile?]
	dev-haskell/unique:=[profile?]
	>=dev-haskell/unordered-containers-0.2:=[profile?]
	>=dev-lang/ghc-7.8.2:=
	ekg? ( >=dev-haskell/ekg-core-0.1:=[profile?]
		>=dev-haskell/text-1.0:=[profile?] )
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.18.1.3
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag bounds-checks bounds-checks) \
		$(cabal_flag debug debug) \
		$(cabal_flag ekg ekg) \
		$(cabal_flag internal-checks internal-checks) \
		$(cabal_flag unsafe-checks unsafe-checks)
}
