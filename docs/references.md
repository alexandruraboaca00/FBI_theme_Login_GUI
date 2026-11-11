# Referencias oficiales y procedencia

Revisión documental: 11 de noviembre de 2026. Las versiones instaladas y los
resultados de pruebas son evidencia del proyecto, no garantías de los upstream.
Se distingue documentación general, contrato de la versión usada y pruebas locales.

## SDDM: contrato versionado

Se contrastó **v0.21.0**, commit `63780fcd79f1dbf81a30eef48c28c699ab15aded`.
El paquete de prueba de Arch fue `sddm 0.21.0-7`: la revisión de empaquetado puede
incluir parches, por lo que también se probó el ejecutable instalado.

| Fuente primaria | Qué respalda en este proyecto |
|---|---|
| [Repositorio oficial SDDM](https://github.com/sddm/sddm) | Identidad del gestor de acceso y proyecto upstream |
| [THEMING.md v0.21.0](https://github.com/sddm/sddm/blob/v0.21.0/docs/THEMING.md) | Temas Qt Quick, proxy sddm, login y señales de resultado |
| [GreeterProxy.h](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/GreeterProxy.h) y [GreeterProxy.cpp](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/GreeterProxy.cpp) | Firma exacta login(user,password,sessionIndex), capacidades y señales |
| [Greeter.cpp](https://github.com/sddm/sddm/blob/v0.21.0/src/daemon/Greeter.cpp#L83-L102) | Elección de sddm-greeter según la versión Qt de metadata y fallback si falta |
| [GreeterApp.cpp](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/GreeterApp.cpp) | Contextos QML, creación de una vista por pantalla y modo de prueba |
| [SessionModel.cpp](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/SessionModel.cpp) | Sesiones X11/Wayland, lastIndex y condición /dev/dri en 0.21 |
| [UserModel.h](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/UserModel.h) | Usuarios, lastUser y lastIndex |
| [KeyboardModel.h](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/KeyboardModel.h) | Bloq Mayús, distribuciones y capacidades de teclado |
| [ThemeConfig.cpp](https://github.com/sddm/sddm/blob/v0.21.0/src/common/ThemeConfig.cpp) | Lectura de theme.conf y overrides theme.conf.user |
| [Manual sddm.conf(5)](https://github.com/sddm/sddm/blob/v0.21.0/data/man/sddm.conf.rst.in) | Prioridad de configuración, Current, ThemeDir, DisplayServer y directorios de sesiones |

La [wiki Theming](https://github.com/sddm/sddm/wiki/Theming) es complementaria.
Sus ejemplos y parte del texto de THEMING.md son históricos: para multimonitor,
Wayland y detalles de Qt se prioriza el código de la versión, no un ejemplo aislado.

## Qt 6 y QML

| Fuente primaria | Qué respalda |
|---|---|
| [Qt Quick](https://doc.qt.io/qt-6/qtquick-index.html) | Lienzo, elementos QML y comportamiento visual |
| [Qt Quick Controls](https://doc.qt.io/qt-6/qtquickcontrols-index.html) | Controles estándar sobre los que se personaliza la interfaz |
| [Basic Style](https://doc.qt.io/qt-6/qtquickcontrols-basic.html) | Estilo Basic usado en campos, botones y selectores |
| [Customizing Qt Quick Controls](https://doc.qt.io/qt-6/qtquickcontrols-customize.html) | Fondos y contentItem personalizados |
| [Estructura QML: ComponentBehavior](https://doc.qt.io/qt-6/qtqml-documents-structure.html#componentbehavior) | Alcance de IDs en delegados con pragma ComponentBehavior: Bound |
| [TextInput](https://doc.qt.io/qt-6/qml-qtquick-textinput.html) | Contraseña oculta, edición, selección y entrada de texto |
| [Canvas](https://doc.qt.io/qt-6/qml-qtquick-canvas.html) | Mapa, máscaras y barcos dibujados por el tema |
| [High DPI](https://doc.qt.io/qt-6/highdpi.html) | Píxeles lógicos y DPR; no acredita pruebas físicas propias |

El mínimo declarado del proyecto es **Qt 6.5**, y la versión probada es **6.12**.
No se afirma que Bound se introdujera en 6.5: Qt lo documenta desde **6.4**.
El mínimo declarado no sustituye una matriz de pruebas en cada versión intermedia.

## KDE Plasma 6 y Arch Linux

- [KDE MegaRelease 6](https://kde.org/announcements/megarelease/6/): contexto oficial
  de Plasma 6 y la transición tecnológica. No es una certificación de este tema.
- [ArchWiki: SDDM](https://wiki.archlinux.org/title/SDDM): guía complementaria de
  administración, temas y resolución de problemas en Arch. Puede requerir acceso
  interactivo por su protección anti-bot; el orden de configuración se contrasta
  también con el manual upstream enlazado arriba.

**Plasma 6, Qt 6 y SDDM son componentes distintos.** Que un escritorio use Qt 6 no
prueba que su gestor activo sea SDDM o que el ejecutable del greeter sea Qt 6.
Los scripts no sustituyen otro display manager ni configuran un escritorio.

## Recursos gráficos y licencias

| Recurso | Procedencia y licencia |
|---|---|
| Código del proyecto | [BSD-3-Clause](../LICENSE); [texto de referencia OSI](https://opensource.org/license/bsd-3-clause) |
| Share Tech Mono | [google/fonts, directorio de la fuente](https://github.com/google/fonts/tree/main/ofl/sharetechmono); [OFL incluida](../src/theme/assets/OFL.txt) |
| Tierra y puntos | [Natural Earth, datos 1:110m](https://github.com/nvkelso/natural-earth-vector/blob/master/geojson/ne_110m_land.geojson); [términos de uso](https://www.naturalearthdata.com/about/terms-of-use/) |
| Referencia gráfica y emblema | Imagen suministrada durante desarrollo; no se identificó autor ni videojuego con certeza. Derechos originales reservados, excluidos de BSD-3-Clause |
| Rutas, barcos y focos animados | Dibujos y datos decorativos del proyecto; sin servicios AIS ni feeds de ataques |

La procedencia de una imagen no se inventa ni se deduce de su estética. El hash
de la referencia se conserva en [design.md](design.md). Las capturas muestran
ese material y no reciben una licencia nueva sobre la imagen subyacente.
[NOTICE.txt](../src/theme/NOTICE.txt) mantiene las atribuciones junto al tema.

## Evidencia propia y límites

La [matriz de validación](testing.md) documenta las pruebas locales y sus pendientes.
La carga en test-mode, los dobles QML y los fotogramas capturados no prueban PAM,
acciones físicas de energía, GPU real ni hotplug. La documentación no atribuye
esas verificaciones a SDDM, Qt, KDE o Arch por el mero hecho de enlazarlos.


## Integración continua

El [workflow del proyecto](../.github/workflows/ci.yml) usa las acciones oficiales
[checkout v7.0.1](https://github.com/actions/checkout/tree/3d3c42e5aac5ba805825da76410c181273ba90b1)
y [setup-python v7.1.0](https://github.com/actions/setup-python/tree/6d4fd22b20465ccc0f7354476588e8df7c9ca0e0),
fijadas a sus commits. El estado visible en la portada corresponde sólo a los
tests Python descritos en [testing.md](testing.md), no a PAM o hardware gráfico.
