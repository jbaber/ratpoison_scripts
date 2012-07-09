# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


DESCRIPTION="The Ratpoison Graphical Task Switcher"
HOMEPAGE="http://code.google.com/p/rpexpose/"
SRC_URI="http://rpexpose.googlecode.com/files/${P}.tbz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="x11-libs/libX11
		sys-libs/glibc"
RDEPEND=""

src_compile() {
	cd ${PN}
	make || die "emake failed"
}

src_install() {
	cd ${PN}
	dobin rpexpose
	dobin rpthumb
	dobin rpselect

	dodoc rpexposerc
	doman rpexpose.1
}

pkg_postinst() {
	einfo Add the following lines to your .ratpoisonrc file
	einfo addhook switchwin exec rpthumb
	einfo addhook quit exec rpexpose --clean
	einfo bind \<key\> exec rpselect
}

pkg_postrm() {
	einfo Remember to remove all uses of rpexpose from your .ratpoisonrc file
}
