# Instalación y ciclo de vida

Esta guía está orientada a **Arch Linux con KDE Plasma 6 y SDDM Qt 6**.
No instala ni habilita un gestor de acceso. Si tu equipo usa GDM, LightDM o
Plasma Login Manager, este procedimiento no lo sustituye.

## 1. Comprobar el entorno

Comandos de sólo lectura:

```bash
pacman -Q sddm qt6-base qt6-declarative plasma-workspace
command -v sddm-greeter-qt6
readlink -f /etc/systemd/system/display-manager.service
ls /usr/share/sddm/themes/
```

El enlace del display manager debe apuntar a `sddm.service`. `plasma-workspace`
identifica el escritorio objetivo; no es un import de la interfaz. El greeter
Qt 6 debe existir y **elarun y Breeze** deben estar disponibles como recuperación.
El instalador no los descarga ni los reemplaza.

Dependencias de ejecución y scripts:

```bash
sudo pacman -S --needed sddm qt6-base qt6-declarative python
```

Los imports y el entorno probado están en [dependencias](dependencies.md).
El tema declara `QtVersion=6` en [metadata.desktop](../src/theme/metadata.desktop);
SDDM elige el greeter correspondiente según [su implementación oficial](references.md#sddm-contrato-versionado).

## 2. Descargar y probar

```bash
git clone https://github.com/alexandruraboaca00/FBI_theme_Login_GUI.git
cd FBI_theme_Login_GUI
./scripts/check-dependencies.sh
./scripts/preview.sh
```

La vista previa abre el greeter real en test-mode, con una copia temporal del tema.
No contacta con un daemon de autenticación; no uses credenciales reales.
Cerrar la ventana termina la prueba sin afectar a la sesión actual.

Antes de seleccionar el tema, lee la [recuperación desde TTY](troubleshooting.md#recuperación-desde-tty).

## 3. Revisar e instalar

Sin `--apply`, las operaciones sólo muestran un plan:

```bash
./scripts/install.sh
./scripts/activate.sh
```

Para ejecutar:

```bash
sudo ./scripts/install.sh --apply
sudo ./scripts/activate.sh --apply
```

Instalación copia la distribución a `/usr/share/sddm/themes/federal-intelligence`,
registra hashes y usa recursos legibles por sddm. Activación verifica el manifiesto,
conserva las alternativas de recuperación, respalda la configuración y cambia
únicamente `[Theme] Current` en `/etc/sddm.conf`.

**No se reinicia SDDM ni se cierra tu sesión.** El tema se verá en el siguiente
inicio del greeter, al cerrar sesión o reiniciar normalmente. El bloqueo de Plasma
es una pantalla independiente y no se modifica.

## Rutas y prioridad de configuración

| Ruta | Uso |
|---|---|
| `/usr/share/sddm/themes/federal-intelligence/` | Tema instalado; no requiere el repositorio para funcionar |
| `/etc/sddm.conf` | Selección del tema |
| `/var/lib/sddm-custom/installation.json` | Manifiesto de archivos propios |
| `/var/lib/sddm-custom/active.json` | Transacción y copia de configuración previa |
| `/var/lib/sddm-custom/…/` | Respaldos protegidos para root |

El identificador del directorio se conserva para compatibilidad con las primeras
instalaciones. No es el nombre del repositorio.

En Arch, el orden de prioridad es:

```text
/usr/lib/sddm/sddm.conf.d/  →  /etc/sddm.conf.d/  →  /etc/sddm.conf
                         prioridad creciente →
```

Se modifica el archivo de mayor prioridad para evitar que un `Current` anterior
ignore un nuevo drop-in. El comportamiento está basado en el
[manual oficial sddm.conf(5)](https://github.com/sddm/sddm/blob/v0.21.0/data/man/sddm.conf.rst.in).
Los drop-ins se respaldan, pero no se modifican ni se restauran automáticamente.

## Copia independiente y comprobación opcional

Activación ya crea un backup. Para crear otro sin activar:

```bash
sudo ./scripts/backup.sh --apply
```

Para verificar el manifiesto, el preset de focos y la lectura real de recursos con
UID/GID de sddm, sin activar:

```bash
sudo python3 scripts/verify-installed.py
```

Esta comprobación requiere root para leer el manifiesto y bajar privilegios al
usuario sddm en un proceso hijo. No prueba PAM ni inicia una sesión.

## Actualizar

La instalación idéntica es idempotente. Una versión distinta no sobrescribe el
mismo destino: conserva tus ajustes y realiza el ciclo explícito:

```bash
sudo ./scripts/restore.sh --apply
sudo ./scripts/uninstall.sh --apply
git pull --ff-only
sudo ./scripts/install.sh --apply
sudo ./scripts/activate.sh --apply
```

Los archivos añadidos o modificados, incluido `theme.conf.user`, detienen la
eliminación. Guárdalos fuera del directorio instalado y devuelve los archivos al
estado registrado antes de desinstalar. No hay opción de borrado forzado.
Una copia restaurada o una reinstalación no obliga a reiniciar servicios.

## Restaurar y retirar

```bash
sudo ./scripts/restore.sh --apply
sudo ./scripts/uninstall.sh --apply
```

Restauración devuelve exactamente `/etc/sddm.conf` al estado previo, con sus
permisos; si originalmente no existía, retira sólo el creado por la transacción.
Se rechazan cambios posteriores para no perder modificaciones ajenas.
Desinstalación exige tema desactivado y coincidencia del manifiesto. Los backups
se conservan y nunca se eliminan los temas de recuperación.

[Recuperar desde TTY](troubleshooting.md#recuperación-desde-tty) · [Índice](README.md)
