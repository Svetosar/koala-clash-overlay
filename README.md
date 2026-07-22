# Koala Clash — Gentoo ebuild

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Update ebuild](https://github.com/Svetosar/koala-clash-overlay/actions/workflows/update.yml/badge.svg)](https://github.com/Svetosar/koala-clash-overlay/actions/workflows/update.yml)

---

## English

### Description

Gentoo Linux ebuild for [Koala Clash](https://github.com/coolcoala/koala-clash) — a GUI proxy client powered by [Mihomo](https://github.com/MetaCubeX/mihomo) core.

Supports:
- VLESS / VMess / Shadowsocks / SOCKS5 protocols
- REALITY (TLS fingerprint spoofing via uTLS)
- TUN mode (system-wide VPN)
- Full-cone NAT / fake-ip DNS
- Mihomo stable & alpha cores
- OpenRC compatible (no systemd required)

### Adding the overlay

**Method 1 — eselect-repository (if you have app-eselect/eselect-repository):**
```bash
eselect repository add koala-clash-overlay git https://github.com/Svetosar/koala-clash-overlay.git
emerge --sync koala-clash-overlay
```

**Method 2 — manual config file:**
Create `/etc/portage/repos.conf/koala-clash-overlay.conf` with:
```ini
[koala-clash-overlay]
location = /var/db/repos/koala-clash-overlay
sync-type = git
sync-uri = https://github.com/Svetosar/koala-clash-overlay.git
auto-sync = yes
```

Then sync and install:
```bash
doas emerge --sync koala-clash-overlay
emerge -av net-proxy/koala-clash
```

### How auto-update works

This repository has a [GitHub Actions workflow](.github/workflows/update.yml) that:
1. Checks for new Koala Clash releases every day at 6:00 UTC
2. If a new version is found, downloads the archive, calculates SHA256/BLAKE2B/SHA512
3. Creates a new ebuild, generates Manifest, commits and pushes back to this repo

After that, running `emerge --sync` on your Gentoo machine will pull the updated ebuild.
You can also manually trigger the workflow via Actions → Update ebuild → Run workflow.

Unlike Gentoo CI, this ebuild uses `~amd64` keyword — meaning it's available for testing on
AMD64 systems. If you want to mask testing packages globally, add to `/etc/portage/package.accept_keywords/koala-clash`:
```
net-proxy/koala-clash ~amd64
```

### Post-install

The ebuild automatically sets:
- `SUID` on `mihomo` / `mihomo-alpha` (required for TUN mode)
- `+x` on `sparkle-service` (system proxy helper for turning VPN off)
- `SUID` on `chrome-sandbox` (Electron sandbox)

For system tray icon:
```bash
emerge -av dev-libs/libayatana-appindicator
```

### Troubleshooting

| Error | Solution |
|-------|----------|
| `connect error: nil ecdheKey` | Set `client-fingerprint: chrome` in proxy config |
| `configure tun interface: operation not permitted` | Check SUID on mihomo: `ls -la /opt/Koala.Clash/resources/sidecar/mihomo` |
| `spawn sparkle-service EACCES` | Check +x on sparkle-service: `ls -la /opt/Koala.Clash/resources/files/sparkle-service` |
| systemd D-Bus warnings | Harmless on OpenRC, Electron app only logs them, no effect on functionality |

### Upstream

- [Koala Clash](https://github.com/coolcoala/koala-clash)
- [Mihomo](https://github.com/MetaCubeX/mihomo)

---

## Русский

### Описание

ebuild для [Koala Clash](https://github.com/coolcoala/koala-clash) на Gentoo Linux — GUI-клиент для прокси на базе ядра [Mihomo](https://github.com/MetaCubeX/mihomo).

Поддерживает:
- VLESS / VMess / Shadowsocks / SOCKS5
- REALITY (TLS fingerprint spoofing через uTLS)
- TUN-режим (системный VPN)
- Full-cone NAT / fake-ip DNS
- Mihomo stable и alpha ядра
- Совместимость с OpenRC (systemd не требуется)

### Подключение оверлея

**Способ 1 — через eselect-repository (если установлен app-eselect/eselect-repository):**
```bash
eselect repository add koala-clash-overlay git https://github.com/Svetosar/koala-clash-overlay.git
emerge --sync koala-clash-overlay
```

**Способ 2 — вручную:**
Создайте файл `/etc/portage/repos.conf/koala-clash-overlay.conf` с содержимым:
```ini
[koala-clash-overlay]
location = /var/db/repos/koala-clash-overlay
sync-type = git
sync-uri = https://github.com/Svetosar/koala-clash-overlay.git
auto-sync = yes
```

После этого синхронизируйте и установите:
```bash
doas emerge --sync koala-clash-overlay
emerge -av net-proxy/koala-clash
```

### Как работает авто-обновление

В этом репозитории настроен [GitHub Actions](.github/workflows/update.yml):
1. Каждый день в 6:00 UTC проверяет выход новых версий Koala Clash
2. Если есть новая версия — скачивает архив, считает SHA256/BLAKE2B/SHA512
3. Создаёт новый ebuild, генерирует Manifest, коммитит и пушит обратно

После этого на вашей Gentoo машине достаточно выполнить `emerge --sync`, чтобы получить
обновлённый ebuild. Также есть возможность запустить вручную: Actions → Update ebuild → Run workflow.

ebuild использует ключевое слово `~amd64` (тестирование). Если у вас в `ACCEPT_KEYWORDS`
нет `~amd64`, добавьте в `/etc/portage/package.accept_keywords/koala-clash`:
```
net-proxy/koala-clash ~amd64
```

### После установки

ebuild автоматически выставляет:
- `SUID` на `mihomo` / `mihomo-alpha` (нужен для TUN-режима)
- `+x` на `sparkle-service` (помощник системного прокси для выключения VPN)
- `SUID` на `chrome-sandbox` (песочница Electron)

Для иконки в системном трее:
```bash
emerge -av dev-libs/libayatana-appindicator
```

### Решение проблем

| Ошибка | Решение |
|--------|---------|
| `connect error: nil ecdheKey` | Установить `client-fingerprint: chrome` в настройках прокси |
| `configure tun interface: operation not permitted` | Проверить SUID на mihomo: `ls -la /opt/Koala.Clash/resources/sidecar/mihomo` |
| `spawn sparkle-service EACCES` | Проверить +x на sparkle-service: `ls -la /opt/Koala.Clash/resources/files/sparkle-service` |
| systemd D-Bus warnings | Безвредны на OpenRC, только логи Electron, на работу не влияют |

### Ссылки

- [Koala Clash](https://github.com/coolcoala/koala-clash)
- [Mihomo](https://github.com/MetaCubeX/mihomo)
