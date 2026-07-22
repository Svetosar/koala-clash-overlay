# Koala Clash — Gentoo ebuild

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

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

### Installation

```bash
# Add this overlay
# Clone somewhere and add to /etc/portage/repos.conf/local.conf

# Install
emerge -av net-proxy/koala-clash
```

### Post-install

The ebuild automatically sets:
- `SUID` on `mihomo` / `mihomo-alpha` (required for TUN)
- `+x` on `sparkle-service` (system proxy helper)
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
| systemd D-Bus warnings | Harmless on OpenRC, Electron app only logs them |

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

### Установка

```bash
# Добавить этот overlay (файлы ebuild)
# Прописать в /etc/portage/repos.conf/local.conf

# Установить
emerge -av net-proxy/koala-clash
```

### После установки

ebuild автоматически выставляет:
- `SUID` на `mihomo` / `mihomo-alpha` (нужен для TUN)
- `+x` на `sparkle-service` (помощник системного прокси)
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
| systemd D-Bus warnings | Безвредны на OpenRC, только логи Electron |

### Ссылки

- [Koala Clash](https://github.com/coolcoala/koala-clash)
- [Mihomo](https://github.com/MetaCubeX/mihomo)
