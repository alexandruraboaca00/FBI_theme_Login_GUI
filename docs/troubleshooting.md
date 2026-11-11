# Problemas frecuentes y recuperación

## Recuperación desde TTY

Si el greeter no permite acceder, pulsa **Ctrl+Alt+F3** e inicia sesión en una
consola. Desde el directorio donde clonaste el repositorio:

```bash
sudo ./scripts/restore.sh --apply
```

Esto restaura la configuración anterior y conserva los backups. No reinicia
servicios. Si detecta modificaciones posteriores de `/etc/sddm.conf`, se detiene
para evitar pérdida de datos.

Si el repositorio no está disponible, usa:

```bash
sudoedit /etc/sddm.conf
```

Deja una única entrada `Current=elarun` o `Current=breeze` dentro de `[Theme]`,
sin cambiar las demás opciones. El respaldo correspondiente está registrado en
`/var/lib/sddm-custom/active.json` y protegido para root.
Después reinicia normalmente cuando sea seguro. Reiniciar SDDM termina las
sesiones gráficas; los scripts nunca lo hacen automáticamente.

## El tema no aparece

Comprueba, en modo lectura:

```bash
readlink -f /etc/systemd/system/display-manager.service
command -v sddm-greeter-qt6
cat /etc/sddm.conf
ls /usr/share/sddm/themes/federal-intelligence/
```

El gestor activo debe ser SDDM, el greeter Qt 6 debe existir y la selección debe
ser `Current=federal-intelligence`. El tema se ve al iniciar el greeter, no al
bloquear Plasma. Estos scripts no sustituyen GDM, LightDM o Plasma Login Manager.

Para verificar la copia instalada sin activar:

```bash
sudo python3 scripts/verify-installed.py
```

## La vista previa no recuerda el usuario

Test-mode se ejecuta con tu usuario normal, sin las mismas condiciones del greeter
real. La interfaz usa `userModel.lastUser` cuando SDDM lo proporciona y permite
escribir un usuario. La contraseña siempre comienza vacía.
Los datos que aparecen en las capturas de muestra se inyectan sólo para documentar.

## Login se queda en «Autenticando…» en test-mode

No hay daemon de autenticación conectado. Cierra la ventana y vuelve a abrirla;
no uses contraseñas reales. Un error de socket en ese modo no demuestra un fallo
QML. La carga y los dobles de prueba no validan una conversación PAM real.

## No aparecen sesiones Wayland

SDDM 0.21 comprueba `/dev/dri` antes de enumerarlas. En entornos aislados puede no
estar visible. Ejecuta la vista previa desde tu terminal habitual y comprueba los
`.desktop` de `/usr/share/wayland-sessions/`. El tema no inventa sesiones ni índices.
[Contrato de SessionModel](references.md#sddm-contrato-versionado).

## Greeter X11 y escritorio Wayland

Son configuraciones separadas. El entorno de referencia tiene greeter X11 y una
sesión Plasma Wayland instalada y detectada. El selector utiliza el modelo de
SDDM; no cambia el servidor del greeter. La detección no certifica el inicio PAM.

## Faltan módulos o se ejecuta Qt 5

```bash
./scripts/check-dependencies.sh
```

Producción utiliza QtQuick, QtQuick.Window y QtQuick.Controls.Basic, sin imports
KDE. Para tests se llaman explícitamente las herramientas de `/usr/lib/qt6/bin`:
el PATH puede contener un qmltestrunner Qt 5. Consulta [dependencias](dependencies.md).

## La retirada rechaza archivos modificados

Es una protección del manifiesto. Conserva los overrides, imágenes u otros archivos
que hayas añadido y restaura los originales registrados antes de reintentar.
La configuración principal modificada después de activar también requiere revisión
manual. No se borran archivos ajenos para completar una desinstalación.

## ¿El mapa muestra ataques o barcos reales?

No. Son animaciones locales, sin conexión a red ni fuentes AIS. Para reducirlas:

```ini
[General]
Animations=false
ShowShips=false
```

## Informar de un fallo

Abre un [reporte de problema](https://github.com/alexandruraboaca00/FBI_theme_Login_GUI/issues/new/choose)
con distribución, versiones, pasos y si ocurre en test-mode o en el greeter real.
No publiques contraseñas ni archivos de autenticación. Los
[límites de validación conocidos](testing.md) ayudan a contextualizar el problema.

[Instalación](installation.md) · [Índice](README.md)
