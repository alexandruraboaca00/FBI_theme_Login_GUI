#!/usr/bin/env bash
set -euo pipefail
missing=0
for package in sddm qt6-base qt6-declarative; do
    if ! pacman -Q "$package"; then missing=1; fi
done
for module in QtQuick QtQuick/Window QtQuick/Controls/Basic; do
    if [[ ! -f "/usr/lib/qt6/qml/$module/qmldir" ]]; then
        printf 'Falta módulo QML: %s\n' "$module" >&2; missing=1
    fi
done
command -v sddm-greeter-qt6 >/dev/null || missing=1
printf '%s\n' 'Sesiones instaladas:'
for session_dir in /usr/local/share/wayland-sessions /usr/share/wayland-sessions /usr/local/share/xsessions /usr/share/xsessions; do
    if [[ -d "$session_dir" ]]; then
        find "$session_dir" -maxdepth 1 -name '*.desktop' -print
    fi
done
if [[ ! -d /dev/dri ]]; then
    printf '%s\n' 'AVISO: /dev/dri no visible; SDDM 0.21 puede omitir sesiones Wayland en esta vista previa.' >&2
fi
exit "$missing"
