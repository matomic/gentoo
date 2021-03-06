# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools flag-o-matic

DESCRIPTION="Reiserfs Utilities"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/fs/reiserfs/"
SRC_URI="mirror://kernel/linux/utils/fs/reiserfs/${P}.tar.xz
	mirror://kernel/linux/kernel/people/jeffm/${PN}/v${PV}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 -sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="static-libs"

PATCHES=(
	"${FILESDIR}/${PN}-3.6.25-no_acl.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	append-flags -std=gnu89 #427300
	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--libdir="${EPREFIX}/$(get_libdir)"
		--sbindir="${EPREFIX}/sbin"
		$(use_enable static-libs static)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	dodir /usr/$(get_libdir)
	mv "${ED}"/$(get_libdir)/pkgconfig "${ED}"/usr/$(get_libdir) || die

	if use static-libs ; then
		mv "${ED}"/$(get_libdir)/*a "${ED}"/usr/$(get_libdir) || die
		gen_usr_ldscript libreiserfscore.so
	else
		find "${ED}" -type f \( -name "*.a" -o -name "*.la" \) -delete
	fi
}
