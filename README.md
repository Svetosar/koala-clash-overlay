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

This repository has two [GitHub Actions](.github/workflows/) workflows:

- **update.yml** — daily at 6:00 UTC (and manually via *Actions → Update ebuild → Run workflow*):
  1. Resolves the latest upstream stable release from the GitHub API (tags have no `v` prefix)
  2. Downloads `Koala.Clash_x64.pkg.tar.xz`, verifies its internal layout (sidecar kernels, chrome-sandbox, .desktop, …)
  3. Copies the newest ebuild as template, regenerates `Manifest` for **all** files (DIST + every ebuild + MISC metadata.xml)
  4. Self-checks ebuild and Manifest, then opens a pull request on branch `bump/<version>`
  5. Merging is done manually after review
- **validate.yml** — runs on every pull request touching `net-proxy/`, `scripts/` or workflows:
  - ebuild syntax + required fields + SUID bits (`test-ebuild.sh`)
  - Manifest structure and hashes (`test-manifest.sh`)
  - **container smoke** (`scripts/smoke.sh`): fetches the distfile, re-generates the Manifest and unpacks the ebuild inside a real `gentoo/portage` container — proving the tarball opens, hashes match, and phases run

After a merge, just run `emerge --sync` on your Gentoo machine to get the updated ebuild.
You can also manually trigger the workflow via Actions → Update ebuild → Run workflow.

The ebuild uses `~amd64` keyword (testing). If your `ACCEPT_KEYWORDS` does not include
`~amd64`, add to `/etc/portage/package.accept_keywords/koala-clash`:
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

### How to rollback

If an update breaks your setup, downgrade to a previous version:

```bash
# 1. Find available ebuilds in the overlay
ls /var/db/repos/koala-clash-overlay/net-proxy/koala-clash/

# 2. Emerge a specific version
emerge -av =net-proxy/koala-clash-1.3.1
```

The overlay keeps all previous ebuilds — nothing is ever deleted.

### Development / CI

The overlay has automated CI pipeline (GitHub Actions):

```
Schedule (daily 6:00 UTC) / manual dispatch
        │
        ▼
  release.sh  (API → download → layout check → ebuild → Manifest)
        │
        ▼
  PR "bump/<version>"  ──►  validate.yml (lint + container smoke)
        │
        ▼
  manual merge to main  ──►  emerge --sync on users' machines
```

Tests:
- `test-ebuild.sh` — validates ebuild syntax, required fields, KEYWORDS, SUID bits
- `test-manifest.sh` — checks Manifest: DIST hashes (SHA256/BLAKE2B/SHA512), every ebuild present, `MISC metadata.xml`, no stale entries
- `smoke.sh` — builds the ebuild in a `gentoo/portage` container (`fetch` + `manifest` + `prepare`)

All updates go through a pull request for review before merging to `main`.
To trigger manually: Actions → Update ebuild → Run workflow → optionally set version.

[![Update ebuild](https://github.com/Svetosar/koala-clash-overlay/actions/workflows/update.yml/badge.svg)](https://github.com/Svetosar/koala-clash-overlay/actions/workflows/update.yml)

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

В репозитории два [GitHub Actions](.github/workflows/) воркфлоу:

- **update.yml** — каждый день в 6:00 UTC (и вручную: Actions → Update ebuild → Run workflow):
  1. берёт последний стабильный релиз из GitHub API (в тегах апстрима нет префикса `v`)
  2. скачивает `Koala.Clash_x64.pkg.tar.xz`, проверяет внутреннюю раскладку (sidecar-ядра, chrome-sandbox, .desktop, …)
  3. копирует последний ebuild как шаблон, пересобирает Manifest для **всех** файлов (DIST + каждый ebuild + MISC metadata.xml)
  4. самопроверяет ebuild и Manifest, затем открывает pull request на ветке `bump/<версия>`
  5. мержится вручную после ревью
- **validate.yml** — на каждый pull request, затрагивающий `net-proxy/`, `scripts/` или воркфлоу:
  - синтаксис ebuild + обязательные поля + SUID-биты (`test-ebuild.sh`)
  - структура и хеши Manifest (`test-manifest.sh`)
  - **контейнерная smoke-сборка** (`scripts/smoke.sh`): скачивание дистрибутива, повторная генерация Manifest и распаковка ebuild внутри настоящего `gentoo/portage`-контейнера — доказывает, что архив открывается, хеши совпадают и фазы выполняются

После мержа на машине достаточно `emerge --sync`, чтобы забрать обновлённый ebuild.

ebuild использует ключевое слово `~amd64` (тестирование). Если у вас в `ACCEPT_KEYWORDS`
нет `~amd64`, добавьте в `/etc/portage/package.accept_keywords/koala-clash`:
```
net-proxy/koala-clash ~amd64
```

### Откат версии

```bash
# Список доступных ebuild
ls /var/db/repos/koala-clash-overlay/net-proxy/koala-clash/

# Установка конкретной версии
emerge -av =net-proxy/koala-clash-1.3.1
```

Все предыдущие версии сохраняются в оверлее.

### CI/CD пайплайн

```
Расписание (ежедневно 6:00 UTC) / ручной запуск
        │
        ▼
  release.sh  (API → скачивание → проверка раскладки → ebuild → Manifest)
        │
        ▼
  PR "bump/<версия>"  ──►  validate.yml (lint + контейнерная smoke)
        │
        ▼
  ручной merge в main  ──►  emerge --sync на машинах пользователей
```

Тесты:
- `test-ebuild.sh` — синтаксис ebuild, обязательные поля, KEYWORDS, SUID-биты
- `test-manifest.sh` — хеши DIST (SHA256/BLAKE2B/SHA512), наличие каждого ebuild, `MISC metadata.xml`, отсутствие битых записей
- `smoke.sh` — сборка ebuild в `gentoo/portage`-контейнере (`fetch` + `manifest` + `prepare`)

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
