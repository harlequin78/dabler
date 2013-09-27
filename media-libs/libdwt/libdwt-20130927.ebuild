# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils toolchain-funcs

PACKAGE_SUFFIX="-dev"
PACKAGE_VERSION="${PV:0:4}-${PV:4:2}-${PV:6:2}${PACKAGE_SUFFIX}"
PRODUCT_ID=211
DESCRIPTION="A cross-platform discrete wavelet transform library"
HOMEPAGE="http://www.fit.vutbr.cz/research/view_product.php?id=${PRODUCT_ID}"
SRC_URI="${HOMEPAGE}&file=%2Fproduct%2F${PRODUCT_ID}%2F${PN}-${PACKAGE_VERSION}.zip -> ${PN}-${PACKAGE_VERSION}.zip"
LICENSE="BUT"
SLOT="0"
KEYWORDS="-* amd64 ~arm"
IUSE="+doc +static-libs debug +opencv"
DEPEND="opencv? ( media-libs/opencv )
	doc? ( app-doc/doxygen )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PACKAGE_VERSION}"

src_compile() {
	emake -C src ARCH="${CHOST%%-*}" BUILD=$(usex debug debug release) || die "emake failed"
	if use opencv ; then
		emake -C src ARCH="${CHOST%%-*}" BUILD=$(usex debug debug release) cvdwt.o || die "emake failed"
	fi
	if use doc ; then
		emake -C doc || die "emake failed"
	fi
	if use static-libs ; then
		"$(tc-getAR)" -rsc "${PN}.a" "src/${PN}.o" || die "ar failed"
	fi
	if use static-libs && use opencv ; then
		"$(tc-getAR)" -rsc cvdwt.a "src/cvdwt.o" || die "ar failed"
	fi
	"$(tc-getCC)" -shared -Wl,-soname,${PN}.so.0 -o "${PN}.so.0.${PV}" "src/${PN}.o" || die "cc failed"
	ln -s "${PN}.so.0.${PV}" "${PN}.so.0"
}

src_install()
{
	install -D -m0644 src/${PN}.h ${ED}/usr/include/${PN}.h || die "install failed"
	if use opencv ; then
		install -D -m0644 src/cvdwt.h ${ED}/usr/include/cvdwt.h || die "install failed"
	fi
	if use static-libs ; then
		dolib.a "${PN}.a" || die "dolib.a failed"
	fi
	if use static-libs && use opencv ; then
		dolib.a "cvdwt.a" || die "dolib.a failed"
	fi
	dolib.so "${PN}.so.0.${PV}" || die "dolib.so failed"
	dolib.so "${PN}.so.0" || die "dolib.so failed"
	use doc && ( dohtml -r doc/html/* || die "dohtml failed" )
	dodoc AUTHORS ChangeLog INSTALL README THANKS TODO VERSION || die "dodoc failed"
}
