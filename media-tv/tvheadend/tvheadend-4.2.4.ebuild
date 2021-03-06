# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit linux-info systemd toolchain-funcs user

DESCRIPTION="Tvheadend is a TV streaming server and digital video recorder"
HOMEPAGE="https://tvheadend.org/"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE="+capmt +constcw +cwc dbus debug dvbcsa dvben50221 +dvb +ffmpeg hdhomerun +imagecache +inotify iptv libressl satip systemd +timeshift uriparser xmltv zeroconf zlib"

RDEPEND="
	virtual/libiconv
	dbus? ( sys-apps/dbus )
	dvbcsa? ( media-libs/libdvbcsa )
	dvben50221? ( media-tv/linuxtv-dvb-apps )
	ffmpeg? ( media-video/ffmpeg:0/55.57.57 )
	hdhomerun? ( media-libs/libhdhomerun )
	!libressl? ( dev-libs/openssl:= )
	libressl? ( dev-libs/libressl:= )
	uriparser? ( dev-libs/uriparser )
	zeroconf? ( net-dns/avahi )
	zlib? ( sys-libs/zlib )"

DEPEND="
	${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig
	dvb? ( virtual/linuxtv-dvb-headers )"

RDEPEND+="
	dvb? ( media-tv/dtv-scan-tables )
	xmltv? ( media-tv/xmltv )"

REQUIRED_USE="dvbcsa? ( || ( capmt constcw cwc dvben50221 ) )"

# Some patches from:
# https://github.com/rpmfusion/tvheadend

PATCHES=(
	"${FILESDIR}/${PN}-4.0.9-use_system_queue.patch"
	"${FILESDIR}/${PN}-4.2.1-hdhomerun.patch"
	"${FILESDIR}/${PN}-4.2.2-dtv_scan_tables.patch"
)

DOCS=( README.md )

pkg_setup() {
	use inotify &&
		CONFIG_CHECK="~INOTIFY_USER" linux-info_pkg_setup

	enewuser tvheadend -1 -1 /etc/tvheadend video
}

src_configure() {
	CC="$(tc-getCC)" \
	PKG_CONFIG="${CHOST}-pkg-config" \
	econf \
		--disable-bundle \
		--disable-ccache \
		--disable-dvbscan \
		--disable-ffmpeg_static \
		--disable-hdhomerun_static \
		--nowerror \
		$(use_enable capmt) \
		$(use_enable constcw) \
		$(use_enable cwc) \
		$(use_enable dbus dbus_1) \
		$(use_enable debug trace) \
		$(use_enable dvb linuxdvb) \
		$(use_enable dvbcsa) \
		$(use_enable dvben50221) \
		$(use_enable ffmpeg libav) \
		$(use_enable hdhomerun hdhomerun_client) \
		$(use_enable imagecache) \
		$(use_enable inotify) \
		$(use_enable iptv) \
		$(use_enable satip satip_server) \
		$(use_enable satip satip_client) \
		$(use_enable systemd libsystemd_daemon) \
		$(use_enable timeshift) \
		$(use_enable uriparser) \
		$(use_enable zeroconf avahi) \
		$(use_enable zlib)
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	default

	newinitd "${FILESDIR}"/tvheadend.initd tvheadend
	newconfd "${FILESDIR}"/tvheadend.confd tvheadend

	use systemd &&
		systemd_dounit "${FILESDIR}"/tvheadend.service

	dodir /etc/tvheadend
	fperms 0700 /etc/tvheadend
	fowners tvheadend:video /etc/tvheadend
}

pkg_postinst() {
	elog "The Tvheadend web interface can be reached at:"
	elog "http://localhost:9981/"
	elog
	elog "Make sure that you change the default username"
	elog "and password via the Configuration / Access control"
	elog "tab in the web interface."
}
