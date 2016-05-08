# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils git-r3 savedconfig toolchain-funcs

DESCRIPTION="a generic, highly customizable, and efficient menu for the X Window System"
HOMEPAGE="http://tools.suckless.org/dmenu/"
EGIT_REPO_URI="git://git.suckless.org/dmenu"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="xinerama"

RDEPEND="
	media-libs/fontconfig
	x11-libs/libX11
	x11-libs/libXft
	xinerama? ( x11-libs/libXinerama )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/xproto
"

src_prepare() {
	sed -i \
		-e 's|^	@|	|g' \
		-e 's|${CC} -o|$(CC) $(CFLAGS) -o|g' \
		-e '/^	echo/d' \
		Makefile || die

  restore_config config.def.h
  epatch_user
}

src_compile() {
	emake CC=$(tc-getCC) \
		"FREETYPEINC=$( $(tc-getPKG_CONFIG) --cflags x11 fontconfig xft 2>/dev/null )" \
		"FREETYPELIBS=$( $(tc-getPKG_CONFIG) --libs x11 fontconfig xft 2>/dev/null )" \
		"XINERAMAFLAGS=$(
			usex xinerama "-DXINERAMA $(
				$(tc-getPKG_CONFIG) --cflags xinerama 2>/dev/null
			)" ''
		)" \
		"XINERAMALIBS=$(
			usex xinerama "$( $(tc-getPKG_CONFIG) --libs xinerama 2>/dev/null)" ''
		)"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install

	save_config config.def.h
}
