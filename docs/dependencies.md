# Dependencias y compatibilidad

## Qué componente hace qué

| Componente | Función |
|---|---|
| SDDM | Gestor de acceso: carga el tema, expone modelos y tramita autenticación |
| Greeter Qt 6 | Proceso de SDDM que interpreta los QML de este tema |
| Qt 6 / Qt Quick Controls Basic | Motor y controles; dependencias directas |
| KDE Plasma 6 | Escritorio de la instalación objetivo, abierto después del login |
| Wayland / X11 | Servidor del greeter y tipo de sesión: decisiones separadas |

Objetivo de soporte: **Arch Linux + KDE Plasma 6 + SDDM Qt 6**.
Entorno comprobado: sddm 0.21.0-7, Qt 6.12.0 y plasma-workspace 6.8.2.
Greeter configurado X11, sesión Plasma Wayland instalada y detectada. Las pruebas
de carga se hicieron offscreen/software; el inicio PAM real sigue sin verificarse.

El mínimo declarado del proyecto es Qt 6.5; no se ha probado cada versión desde
ese mínimo. ComponentBehavior: Bound se introdujo en Qt 6.4, según
[la documentación oficial](https://doc.qt.io/qt-6/qtqml-documents-structure.html#componentbehavior).
Qt 5 y Plasma 5 están fuera del objetivo de soporte. Otros escritorios con SDDM
Qt 6 podrían usarlo, pero no se afirma compatibilidad probada.

## Paquetes y recursos

| Uso | Requisito en Arch |
|---|---|
| Tema | sddm, qt6-base, qt6-declarative y sddm-greeter-qt6 disponible |
| Scripts de administración | Bash y Python 3; pacman para la comprobación de paquetes |
| Sesión de escritorio | Una sesión instalada; la referencia de desarrollo es plasma-workspace |
| Activación con estos scripts | elarun y Breeze instalados como recuperación |
| Tests y capturas | CMake, Ninja, compilador C++, pkgconf, python-pytest y Qt6 Quick/Test |
| GIF de revisión | ffmpeg opcional, sólo desarrollo |

Imports: QtQuick, QtQuick.Window y QtQuick.Controls.Basic. No se requieren imports
KDE, Kirigami, Qt5Compat, SVG, Multimedia ni red. La fuente y los datos visuales
están incluidos. No se requiere Pillow, PySide6, Xvfb ni xdotool.

Las herramientas se llaman por su ruta /usr/lib/qt6/bin/qmllint y qmltestrunner:
el PATH puede contener versiones Qt 5. Los scripts nunca instalan dependencias
ni habilitan o cambian el display manager automáticamente.

## Aspectos específicos de SDDM 0.21

SessionModel condiciona las sesiones Wayland a la existencia de /dev/dri.
Un entorno aislado puede mostrar cero sesiones aunque exista el escritorio.
El booleano primaryScreen se aporta al crear cada vista; la reasignación dinámica
en caliente no está validada. No generalizar esas decisiones a cualquier SDDM futuro.

Contratos de versión, documentación de KDE/Qt y procedencia de recursos:
[referencias oficiales](references.md).
