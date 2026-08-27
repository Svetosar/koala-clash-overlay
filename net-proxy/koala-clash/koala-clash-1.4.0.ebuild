# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="GUI proxy client with TUN/VLESS/REALITY support, powered by Mihomo kernel"
HOMEPAGE="https://github.com/coolcoala/koala-clash"

SRC_URI="https://github.com/coolcoala/koala-clash/releases/download/${PV}/Koala.Clash_x64.pkg.tar.xz"

S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip test"

BDEPEND="app-arch/xz-utils"

RDEPEND="
	app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-libs/nss
	sys-apps/util-linux
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-misc/xdg-utils
"

src_install() {
	insinto /opt/Koala.Clash
	doins -r opt/Koala.Clash/.

	fperms 755 /opt/Koala.Clash/koala-clash
	fperms 755 /opt/Koala.Clash/chrome_crashpad_handler
	fperms 4755 /opt/Koala.Clash/chrome-sandbox
	fperms 755 /opt/Koala.Clash/libEGL.so
	fperms 755 /opt/Koala.Clash/libffmpeg.so
	fperms 755 /opt/Koala.Clash/libGLESv2.so
	fperms 755 /opt/Koala.Clash/libvk_swiftshader.so
	fperms 755 /opt/Koala.Clash/libvulkan.so.1
	fperms 4755 /opt/Koala.Clash/resources/sidecar/mihomo
	fperms 4755 /opt/Koala.Clash/resources/sidecar/mihomo-alpha
	fperms 755 /opt/Koala.Clash/resources/files/sparkle-service

	dosym /opt/Koala.Clash/koala-clash /usr/bin/koala-clash

	sed -i \
		-e 's|Exec=/opt/Koala.Clash/koala-clash|Exec=koala-clash|' \
		"${S}/usr/share/applications/koala-clash.desktop" || die
	domenu usr/share/applications/koala-clash.desktop

	doicon -s 512 usr/share/icons/hicolor/512x512/apps/koala-clash.png

	insinto /etc/apparmor.d
	newins opt/Koala.Clash/resources/apparmor-profile koala-clash
}

pkg_postinst() {
	xdg_pkg_postinst

	if [[ ! -f "${EROOT}/usr/bin/koala-clash" ]]; then
		ewarn "Symlink /usr/bin/koala-clash not found. Try: emerge --config ${PN}"
	fi

	elog "For tray icon support, install:"
	elog "  emerge -av dev-libs/libayatana-appindicator"
	elog
	elog "AppArmor profile installed at /etc/apparmor.d/koala-clash"
	elog "Activate with: aa-enforce koala-clash"
}
