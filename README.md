# FBI_theme_Login_GUI

**Tema de inicio de sesión para SDDM · Qt 6 / QML · KDE Plasma 6 · Arch Linux**

Personaliza el **greeter de [SDDM (Simple Desktop Display Manager)](https://github.com/sddm/sddm)**,
la pantalla donde eliges usuario y sesión antes de entrar al escritorio. Está
orientado a **KDE Plasma 6 sobre Arch Linux** y construido con **Qt 6 / Qt Quick**.
Incluye estética CRT, mapa mundial animado, focos simulados y barcos oceánicos.

**Alcance:** no es un tema global de Plasma, una aplicación de escritorio ni una
pantalla de bloqueo. Sólo se aplica si el gestor de acceso activo es SDDM y dispone
del greeter Qt 6. No sirve para GDM, LightDM ni Plasma Login Manager.

- [Compatibilidad y entorno](#compatibilidad-y-entorno)
- [Descargar y probar](#descargar-y-probar)
- [Instalar y activar](#instalar-y-activar)
- [Configurar](#configurar)
- [Recuperación desde TTY](#recuperación-desde-tty)
- [Preguntas frecuentes](#preguntas-frecuentes)
- [Referencias oficiales y atribuciones](docs/references.md)

![Vista del tema](src/theme/preview.png)

[Ver demostración animada](docs/media/preview.gif)

## Funciones

- Usuario recordado o introducido manualmente y selector de usuarios.
- Contraseña oculta, Enter para acceder, bloqueo durante la autenticación y reintentos.
- Selector de sesiones disponible en «Sesión», respetando la última sesión de SDDM.
- Fecha `dd/MM/yyyy`, hora de 24 horas y aviso de Bloq Mayús.
- Distribuciones de teclado y energía según las capacidades de SDDM; acciones confirmadas.
- Mapa con partículas, estelas y ondas de llegada, y cuatro barcos con rumbo y estela.
- Composición proporcional, soporte de escalado y controles sólo en la pantalla principal.
- Instalación con manifiesto, backup automático al activar y restauración de la configuración.

Las rutas, focos y barcos son **decorativos y funcionan offline**. No muestran
ataques reales, tráfico AIS ni información de tu red.

## Compatibilidad y entorno

| Componente | Entorno comprobado / alcance |
|---|---|
| Distribución | Arch Linux; scripts de dependencias e instalación orientados a Arch |
| Escritorio | **KDE Plasma 6.8.2** instalado durante desarrollo |
| Gestor de acceso | **SDDM 0.21.0-7**, seleccionado como display manager |
| Motor del tema | **Qt 6.12.0**, QML / Qt Quick Controls Basic |
| Greeter | Configurado en **X11**; las capturas y pruebas se ejecutan en offscreen/software |
| Sesión de usuario | **Plasma Wayland**, detectada por el modelo de sesiones de SDDM |
| Sesiones X11 | Selector implementado y probado con dobles; no había sesión X11 instalada en el equipo de prueba |
| Qt mínimo declarado | 6.5; sólo 6.12 está probado, sin garantía para cada versión intermedia |
| Qt 5 / Plasma 5 | Fuera del objetivo de soporte; no se ofrece una variante Qt 5 |
| Otros escritorios o distribuciones | Posibles con SDDM Qt 6, pero no verificados; scripts y nombres de paquetes pueden requerir adaptación |

**KDE Plasma 6 es el escritorio; Qt 6 es el framework que dibuja el tema; SDDM es
el gestor que lo carga.** Plasma 6 y Qt 6 tienen numeraciones independientes.
El tema no importa bibliotecas KDE: sus dependencias directas son QtQuick,
QtQuick.Window y QtQuick.Controls.Basic. La fuente está incluida.

El greeter puede usar X11 y abrir después una sesión Wayland: son configuraciones
separadas de SDDM. Este proyecto no cambia ninguna de ellas. Los modelos y la API
están contrastados con [SDDM v0.21.0](docs/references.md#sddm-contrato-versionado).
La arquitectura de Plasma 6 se contextualiza en el
[anuncio oficial de KDE](https://kde.org/announcements/megarelease/6/).

La carga del tema, las interacciones de prueba y la instalación **no equivalen a
un inicio de sesión PAM real validado**. Los límites exactos están en
[docs/testing.md](docs/testing.md).

## Requisitos

**Ejecución:** SDDM con `sddm-greeter-qt6`, Qt 6 y una sesión de escritorio instalada.
**Scripts:** Bash, Python 3 y `pacman` en Arch. No requieren herramientas de
compilación para instalar o abrir la vista previa.

```bash
sudo pacman -S --needed sddm qt6-base qt6-declarative python
```

El instalador no instala paquetes. El script de activación exige que **elarun y
Breeze estén disponibles** como alternativas de recuperación. Breeze suele estar
incluido con Plasma; comprueba `/usr/share/sddm/themes/` antes de activar.
El tema no configura SDDM como gestor activo ni cambia el servidor gráfico.

Antes de instalar, estas comprobaciones son de sólo lectura:

```bash
pacman -Q sddm qt6-base qt6-declarative plasma-workspace
command -v sddm-greeter-qt6
readlink -f /etc/systemd/system/display-manager.service
ls /usr/share/sddm/themes/
```

El enlace del gestor activo debe apuntar a `sddm.service`. Tener KDE Plasma 6
instalado no garantiza por sí solo que SDDM sea el gestor activo. Si usas otro,
esta guía no lo sustituye ni lo habilita automáticamente. `plasma-workspace`
identifica el entorno de prueba; no es un import requerido por el tema.
El campo [`QtVersion=6`](src/theme/metadata.desktop) identifica la variante Qt del
tema; el ejecutable correspondiente debe existir. Véase
[la selección del greeter en SDDM](https://github.com/sddm/sddm/blob/v0.21.0/src/daemon/Greeter.cpp#L83-L102).

## Descargar y probar

```bash
git clone https://github.com/alexandruraboaca00/FBI_theme_Login_GUI.git
cd FBI_theme_Login_GUI
./scripts/check-dependencies.sh
./scripts/preview.sh
```

La vista previa usa el ejecutable real `sddm-greeter-qt6 --test-mode`, con una
copia temporal autocontenida del tema. Cierra la ventana para salir. **No prueba
PAM ni debe utilizarse con contraseñas reales**: sin daemon, Login puede quedarse
en «Autenticando…» hasta cerrar la vista previa.

En entornos aislados sin `/dev/dri`, SDDM 0.21 puede omitir las sesiones Wayland.
En ese caso se muestra el aviso de ausencia de sesiones. Comprueba desde una
terminal normal antes de atribuirlo al tema.

## Instalar y activar

Primero revisa la vista previa y el [procedimiento de recuperación](#recuperación-desde-tty).
No necesitas cerrar tu sesión ni reiniciar SDDM durante la instalación.

Los scripts son **simulación por defecto**:

```bash
./scripts/install.sh
./scripts/activate.sh
```

Para ejecutar los cambios:

```bash
sudo ./scripts/install.sh --apply
sudo ./scripts/activate.sh --apply
```

- Instalación: `/usr/share/sddm/themes/federal-intelligence/`.
- Activación: cambia únicamente `[Theme] Current` en `/etc/sddm.conf`.
- Copias y manifiestos: `/var/lib/sddm-custom/`, protegidos para root.

El identificador instalable `federal-intelligence` se conserva para facilitar
compatibilidad y restauraciones; el repositorio se llama FBI_theme_Login_GUI.
El [manual oficial de configuración de SDDM](https://github.com/sddm/sddm/blob/v0.21.0/data/man/sddm.conf.rst.in)
establece el orden de carga. En el destino Arch de estos scripts:
`/usr/lib/sddm/sddm.conf.d/` → `/etc/sddm.conf.d/` → `/etc/sddm.conf`, con mayor
prioridad al final. Por eso no se añade un drop-in que pudiera quedar ignorado.

La activación crea automáticamente una copia de la configuración previa.
También puedes generar una copia independiente con `sudo ./scripts/backup.sh --apply`.
Ningún script reinicia servicios, modifica PAM, habilita autologin, cambia la
pantalla de bloqueo de Plasma ni toca Plasma Login Manager.

El tema aparecerá en el siguiente inicio del greeter, al cerrar sesión o reiniciar
normalmente. Bloquear la sesión de Plasma utiliza su pantalla de bloqueo independiente.

## Configurar

Crear `theme.conf.user` dentro del directorio instalado, conservando `theme.conf`:

```ini
[General]
MapOpacity=0.50
ShowShips=true
CRTStrength=0.20
Animations=true
```

Para probar ajustes antes de instalar, puedes crear el mismo archivo en `src/theme`.
Los presets de vista previa fijan sus valores artísticos; usa el greeter directamente
sobre `src/theme` si quieres revisar todos tus overrides sin preset:

```bash
sddm-greeter-qt6 --test-mode --theme "$(pwd)/src/theme"
```

| Opción | Predeterminado | Descripción |
|---|---|---|
| MapStyle | threats | threats: focos; dots: puntos cian |
| MapOpacity | 0.56 | Intensidad del mapa, 0–0.65 |
| AnimatedMap | true | Mostrar el mapa |
| Animations | true | false congela la actividad |
| ShowShips | true | Barcos, sólo en el mapa de focos |
| CRT / CRTStrength | true / 0.24 | Máscara CRT; intensidad 0–0.35 |
| ClockPosition | header | header bajo emblema, footer en el pie |
| ShowClock / ShowUtilities | true / true | Reloj y franja de utilidades |
| Accent | #7cdfe5 | Color de controles |
| Dim | 0 | Oscurecimiento del fondo, 0–0.8 |
| PanelOpacity | 0.10 | Fondo de los campos, 0–1 |
| Background | assets/reference.jpg | Ruta relativa al tema o URL local |
| BackgroundMode | fit | fit completo, crop recortado, sin deformar |
| PanelOffsetX / PanelOffsetY | 0 / 0 | Desplazamiento acotado ±80 / ±45 |

Fecha y hora mantienen formatos fijos `dd/MM/yyyy` y `HH:mm`.
Guarda fondos alternativos dentro del tema con permisos de lectura para sddm.
Un fondo alternativo debe carecer de campos de acceso dibujados.

## Restaurar, actualizar o desinstalar

```bash
sudo ./scripts/restore.sh --apply
sudo ./scripts/uninstall.sh --apply
```

Restauración devuelve exactamente la configuración anterior. Si se modificó
`/etc/sddm.conf` después de activar, se detiene para no sobrescribir cambios.
Desinstalación elimina sólo archivos que coincidan con el manifiesto y rechaza
un tema todavía activo. Las copias de seguridad se conservan.

Un `theme.conf.user` añadido o cambiado después de instalar detendrá la eliminación:
guarda tus ajustes y devuelve el directorio al estado registrado antes de reintentar.
No hay borrado forzado. Para actualizar: restaurar, desinstalar e instalar la nueva
versión. Repetir una instalación idéntica no modifica nada.

## Recuperación desde TTY

Si el greeter falla, pulsa **Ctrl+Alt+F3**, inicia sesión en consola y ejecuta,
desde el directorio donde clonaste el repositorio:

```bash
sudo ./scripts/restore.sh --apply
```

Si el repositorio no está disponible, usa `sudoedit /etc/sddm.conf` y deja una
única entrada `Current=elarun` o `Current=breeze` dentro de `[Theme]`, conservando
las demás opciones. La copia de seguridad se identifica en
`/var/lib/sddm-custom/active.json`.

Después reinicia normalmente cuando sea seguro. Reiniciar SDDM termina las
sesiones gráficas; los scripts nunca lo hacen automáticamente.

## Desarrollo y pruebas

```bash
sudo pacman -S --needed cmake ninja gcc pkgconf python python-pytest
./scripts/test.sh
```

Las pruebas de instalación usan **raíces temporales**, no el sistema real.
Qt Quick Test verifica interacciones con dobles; las capturas usan el greeter real
con QPA offscreen y renderizado software. Resultados generados en `tests/results`
y `tests/screenshots`, excluidos de Git. `ffmpeg` es opcional para exportar la
animación con `python3 scripts/capture-motion.py` después de compilar las herramientas.

Probados: cuatro resoluciones (1366×768 a 2560×1440), DPR 1.25 y dos monitores
simulados. No se afirma validación de PAM, acciones físicas de energía, GPU,
hotplug o lector de pantalla. MFA y cambio obligatorio de contraseña no están
implementados. El monitor principal se decide al crear las vistas de SDDM 0.21.

Consulta [arquitectura](docs/architecture.md), [diseño](docs/design.md),
[dependencias](docs/dependencies.md) y [validación](docs/testing.md).

## Preguntas frecuentes

**¿Se aplica desde un tema global de KDE Plasma 6?**

No: se instala en el directorio de temas de SDDM. Cambia la pantalla de acceso,
no el escritorio, las ventanas, los iconos ni el bloqueo de Plasma.

**¿Funciona sólo por tener KDE Plasma 6 instalado?**

Necesita SDDM activo y su greeter Qt 6. No requiere imports KDE; otros escritorios
con ese runtime podrían funcionar, pero no se han validado.

**¿Puedo usar Plasma Wayland aunque el greeter sea X11?**

Sí: el selector usa las sesiones que proporciona SDDM. La configuración comprobada
combina greeter X11 y una sesión Plasma Wayland detectada. No se cambia el servidor
del greeter ni se presupone que esa detección pruebe la autenticación real.

**¿Por qué la vista previa no recuerda mi usuario o se queda autenticando?**

Se ejecuta en test-mode con tu usuario normal y sin un daemon conectado. No es la
misma ejecución que el greeter de acceso. El tema real toma `userModel.lastUser`;
la contraseña nunca viene predefinida. No introduzcas credenciales reales en test-mode.

**¿El mapa muestra hackeos o barcos reales?**

No: las animaciones son decorativas, locales y sin red.

## Referencias y atribuciones

La documentación del contrato usa la versión **SDDM v0.21.0**, no ejemplos de
Qt 5 copiados de la wiki. Consulta el
[índice de fuentes con su alcance](docs/references.md): SDDM, Qt, KDE, ArchWiki,
Natural Earth y Share Tech Mono. Los enlaces de código están fijados a versión
cuando corresponde y las pruebas propias se identifican por separado.

## Licencias y recursos

El código se publica bajo **BSD de 3 cláusulas (BSD-3-Clause)**, una licencia
permisiva. Texto completo en [LICENSE](LICENSE). La fuente Share Tech Mono usa
SIL OFL; los datos cartográficos Natural Earth son de dominio público.
La imagen de referencia y sus apariciones en capturas mantienen sus derechos
originales y están excluidas de la licencia del código. No se atribuye su propiedad
ni se concede una licencia nueva sobre ese material. Consulta
[NOTICE.txt](src/theme/NOTICE.txt) para las atribuciones.
