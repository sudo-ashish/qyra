# Maintainer: Qyra Contributors <qyra-desktop@proton.me>
pkgname=qyra
pkgver=0.1.0
pkgrel=1
pkgdesc="Modern, standalone desktop environment for Arch Linux + Hyprland (Lua API) + Quickshell"
arch=('any')
url="https://github.com/pear/qyra"
license=('MIT')

depends=(
  'hyprland'
  'quickshell'
  'awww'
  'hyprlock'
  'hypridle'
  'pipewire'
  'wireplumber'
  'networkmanager'
  'bluez'
  'bluez-utils'
  'upower'
  'wl-clipboard'
  'ttf-jetbrains-mono-nerd'
  'python'
  'libnotify'
  'brightnessctl'
  'grim'
  'slurp'
  'jq'
)

optdepends=(
  'kitty: Default recommended Wayland terminal emulator'
  'btop: Resource and process monitor'
  'nautilus: Recommended desktop file manager'
  'gnome-calculator: Quick calculator utility'
  'hyprglass: Window blur and glass shader effects'
  'playerctl: CLI media playback control integration'
  'fastfetch: System information fetcher'
)

package() {
  local _src="${srcdir}/.."

  # Tier 1 Immutable Core -> /usr/share/qyra/
  install -dm755 "${pkgdir}/usr/share/qyra"
  cp -r "${_src}/shell" "${pkgdir}/usr/share/qyra/"
  cp -r "${_src}/hypr" "${pkgdir}/usr/share/qyra/"
  cp -r "${_src}/defaults" "${pkgdir}/usr/share/qyra/"
  install -Dm644 "${_src}/VERSION" "${pkgdir}/usr/share/qyra/VERSION"

  # Executable Binaries -> /usr/bin/
  install -Dm755 "${_src}/bin/qyractl" "${pkgdir}/usr/bin/qyractl"
  install -Dm755 "${_src}/bin/qyra-theme-gen" "${pkgdir}/usr/bin/qyra-theme-gen"
  install -Dm755 "${_src}/install.sh" "${pkgdir}/usr/bin/qyra-setup"

  # Documentation & License -> /usr/share/doc/qyra/
  install -dm755 "${pkgdir}/usr/share/doc/qyra"
  cp -r "${_src}/docs" "${pkgdir}/usr/share/doc/qyra/"
  [[ -f "${_src}/README.md" ]] && install -Dm644 "${_src}/README.md" "${pkgdir}/usr/share/doc/qyra/README.md"
  install -Dm644 "${_src}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
