# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

# Python is required for tests and some build tasks.
PYTHON_COMPAT=( python2_7 python3_{4,5,6} pypy )

inherit python-any-r1 cmake-multilib

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/google/googletest"
else
	SRC_URI="https://github.com/google/googletest/archive/release-${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos"
	S="${WORKDIR}"/googletest-release-${PV}
fi

DESCRIPTION="Google C++ Testing Framework"
HOMEPAGE="https://github.com/google/googletest"

LICENSE="BSD"
SLOT="0"
IUSE="examples test"

DEPEND="test? ( ${PYTHON_DEPS} )"
RDEPEND="!dev-cpp/gmock"

PATCHES=(
	"${FILESDIR}"/${PN}-9999-fix-gcc6-undefined-behavior.patch
)

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_GMOCK=ON
		-DBUILD_GTEST=ON
		-DINSTALL_GMOCK=ON
		-DINSTALL_GTEST=ON
		-Dgtest_build_samples=OFF
		-Dgtest_disable_pthreads=OFF

		# currently only static libs work
		# due to numerous ODR violations
		# https://github.com/google/googletest/issues/930
		-DBUILD_SHARED_LIBS=OFF

		# tests
		-Dgmock_build_tests=$(usex test)
		-Dgtest_build_tests=$(usex test)
		-DPYTHON_EXECUTABLE="${PYTHON}"
	)
	cmake-utils_src_configure
}

multilib_src_install_all() {
	einstalldocs

	if use examples; then
		docinto examples
		dodoc googletest/samples/*.{cc,h}
	fi
}
