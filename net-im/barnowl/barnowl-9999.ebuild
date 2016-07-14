EAPI="6"

inherit git-r3 autotools

DESCRIPTION="The BarnOwl IM client"
HOMEPAGE="https://barnowl.mit.edu/"
EGIT_REPO_URI="https://github.com/barnowl/barnowl.git"
if [[ "${PV}" != "9999" ]]; then
	EGIT_BRANCH="release-${PV}"
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="facebook irc jabber twitter +wordwrap +zephyr"

DEPEND="
	sys-libs/ncurses
	dev-perl/AnyEvent
	dev-perl/Class-Accessor
	dev-perl/ExtUtils-Depends
	dev-perl/glib-perl
	dev-perl/Module-Install
	dev-perl/PAR
	facebook? (
		dev-perl/Any-Moose
		dev-perl/AnyEvent-HTTP
		dev-perl/DateTime
		dev-perl/DateTime-Format-Strptime
		dev-perl/JSON
		dev-perl/MIME-Base64-URLSafe
		dev-perl/Ouch
		dev-perl/URI
		dev-perl/URI-Encode
	)
	irc? ( dev-perl/AnyEvent-IRC )
	jabber? (
		dev-perl/Net-DNS
		dev-perl/Authen-SASL-Perl
		dev-perl/IO-Socket-SSL
		dev-perl/Digest-SHA
	)
	twitter? (
		dev-perl/HTML-Entities
		dev-perl/Net-Twitter-Lite
	)
	wordwrap? (
		dev-perl/Text-Autoformat
	)
	zephyr? (
		net-im/zephyr
	)
"
RDEPEND="${DEPEND}"

src_prepare() {
	# remove references to unused modules
	for module in Jabber IRC WordWrap Twitter Facebook; do
		if ! use ${module,,}; then
			sed -i -e '/^\s*'${module}'/d' -e "s:${module}::g" "${S}/perl/modules/Makefile.am" || die
		fi
	done
	# remove trailing backslashes that lead to empty lines
	perl -pi -0 -e 's:\\\n\n:\n\n:g' "${S}/perl/modules/Makefile.am" || die

	eapply_user

	eautoreconf
}

src_configure() {
	econf $(use_with zephyr)
}
