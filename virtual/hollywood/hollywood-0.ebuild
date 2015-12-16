# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION=""
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="+apg +bmon +cmatrix +ccze +vim +htop +jp2a +mpv +ssh +tree"

DEPEND="apg? ( app-admin/apg )
	bmon? ( net-analyzer/bmon )
	cmatrix? ( app-misc/cmatrix )
	ccze? ( app-admin/ccze )
	vim? ( app-editors/vim )
	htop? ( sys-process/htop )
	jp2a? ( media-gfx/jp2a )
	mpv? ( media-video/mpv[libcaca] )
	ssh? ( net-misc/openssh )
	tree? ( app-text/tree )"
RDEPEND="${DEPEND}"
