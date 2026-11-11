# Dependencias

Objetivo de soporte: Arch Linux, SDDM con Qt 6 y KDE Plasma. Validado inicialmente
con SDDM 0.21.0-7, Qt 6.12 y Plasma 6.8.2. No se da por garantizada compatibilidad
con otras versiones o distribuciones.

Producción: sddm, qt6-base y qt6-declarative. Imports QtQuick, QtQuick.Window y
QtQuick.Controls.Basic. Qt ≥6.5 por ComponentBehavior: Bound.
No se usa Qt5Compat, Kirigami, SVG, Multimedia ni módulos de red.
Share Tech Mono y sus términos OFL están incluidos.

Activación segura: elarun y Breeze deben estar instalados como recuperación.
Los scripts no cambian gestor, servicios, PAM ni sesiones instaladas.

Desarrollo: CMake, Ninja, compilador C++, pkgconf, Python, pytest y Qt6 Quick/Test.
Se usan explícitamente /usr/lib/qt6/bin/qmllint y qmltestrunner para evitar que
herramientas Qt 5 del PATH se ejecuten por error. ffmpeg es opcional para el GIF.
No se requiere Pillow, PySide6, Xvfb ni xdotool.

SDDM 0.21 condiciona las sesiones Wayland a la existencia de /dev/dri. Un entorno
headless o aislado puede mostrar cero sesiones aunque el escritorio esté instalado.
El tema lo indica y no inventa índices para disimularlo.
