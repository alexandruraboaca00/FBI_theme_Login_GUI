# FBI_theme_Login_GUI

Tema de inicio de sesión para **SDDM y Qt 6**, con estética de terminal CRT,
mapa mundial animado, focos de actividad simulada y barcos sobre rutas oceánicas.
Diseñado para Arch Linux y KDE Plasma, con greeter X11 y sesiones Wayland o X11.

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

## Requisitos

Validado con SDDM 0.21.0, Qt 6.12 y Plasma 6.8 sobre Arch Linux. El código requiere
Qt ≥6.5. Imports: QtQuick, QtQuick.Window y QtQuick.Controls.Basic.
La fuente está incluida; no requiere Kirigami, componentes KDE ni Qt5Compat.

```bash
sudo pacman -S --needed sddm qt6-base qt6-declarative
```

El instalador no instala paquetes. El script de activación exige que **elarun y
Breeze estén disponibles** como alternativas de recuperación. Breeze suele estar
incluido con Plasma; comprueba `/usr/share/sddm/themes/` antes de activar.
El tema no configura SDDM como gestor activo ni cambia el servidor gráfico.

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
`/etc/sddm.conf` tiene prioridad sobre los archivos de `sddm.conf.d`, por eso no
se añade un drop-in que pudiera quedar ignorado.

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

## Licencias y recursos

El código se publica bajo **BSD de 3 cláusulas (BSD-3-Clause)**, una licencia
permisiva. Texto completo en [LICENSE](LICENSE). La fuente Share Tech Mono usa
SIL OFL; los datos cartográficos Natural Earth son de dominio público.
La imagen de referencia y sus apariciones en capturas mantienen sus derechos
originales y están excluidas de la licencia del código. No se atribuye su propiedad
ni se concede una licencia nueva sobre ese material. Consulta
[NOTICE.txt](src/theme/NOTICE.txt) para las atribuciones.
