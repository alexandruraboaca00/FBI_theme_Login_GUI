# Arquitectura

`src/theme` es la distribución autocontenida: Main.qml, componentes, configuración,
metadata, fuente, imágenes y datos cartográficos. Nunca depende de una ruta personal.

| Componente | Responsabilidad |
|---|---|
| Main.qml | Contextos SDDM, lienzo 1600×900, escala uniforme y pantalla principal |
| Settings.qml | Conversión y límites de valores de theme.conf y theme.conf.user |
| AuthController.qml | Validación, sddm.login, bloqueo y señales de respuesta |
| LoginPanel.qml | Usuario, menú, contraseña, Login y mensajes |
| UtilityBar.qml / HeaderClock.qml | Sesión, teclado, energía y reloj |
| TerminalField / Button / Combo | Controles Basic personalizados |
| Backdrop.qml / CrtOverlay.qml | Referencia intacta, máscara de controles y líneas CRT |
| NetworkMap.qml | Tierra estática y rutas/focos animados en capas separadas |
| SeaTraffic.qml | Barcos con rumbo, velocidad uniforme y estela |

## Autenticación

El único envío es `sddm.login(usuario, contraseña, índiceDeSesión)`. Los modelos
proporcionan usuarios y sesiones; no se ejecutan comandos desktop desde QML.
Se respeta lastUser/lastIndex de SDDM y se admite introducir un usuario manual.
No se exige contraseña no vacía: esa política corresponde a PAM.

Mientras hay una petición pendiente, se bloquean nuevos envíos. El campo se borra
tras enviar. loginFailed desbloquea y devuelve el foco; loginSucceeded mantiene el
bloqueo mientras arranca la sesión. informationMessage se representa como texto
plano. socketDisconnected impide reintentos. No hay timeout que pueda duplicar PAM.
No se registran contraseñas; tampoco se afirma borrado criptográfico de strings QML.

Las acciones de energía dependen de canPowerOff/canReboot/canSuspend; se vuelven
a comprobar al confirmar. Escape cancela y el foco inicial del diálogo es Cancelar.

## Pantallas y recursos

El lienzo se centra y escala con min(ancho/1600, alto/900); no deforma el fondo.
SDDM 0.21 crea una vista por pantalla. El contexto primaryScreen controla dónde
se habilitan formulario y utilidades; las secundarias son decorativas.
La reasignación del primario en caliente no está validada.

WorldDots.js y WorldLand.js derivan del GeoJSON de tests/fixtures mediante los
generadores de tools. SeaRoutes.js contiene rutas decorativas locales. No hay
conexiones externas ni un servicio de telemetría. Animations=false pausa la fase.

## Instalación

manage.py concentra backup, instalación, activación, restauración y eliminación.
Sin --apply sólo imprime un plan. Los tests usan --root con directorios temporales.
Se rechazan destinos ajenos, symlinks y modificaciones fuera del manifiesto.
La configuración se reemplaza atómicamente; la restauración rechaza cambios posteriores.

La biblioteca greeter-capture es instrumental, exige --test-mode y no se instala.
verify-installed.py permite comprobar el manifiesto y lectura real como sddm;
sólo activa si se pide explícitamente --activate.

## Fuentes oficiales

Contrato contrastado con SDDM v0.21.0, commit
63780fcd79f1dbf81a30eef48c28c699ab15aded, y con el greeter instalado:

- [GreeterProxy](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/GreeterProxy.h)
- [GreeterApp y contextos](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/GreeterApp.cpp)
- [SessionModel](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/SessionModel.cpp)
- [KeyboardModel](https://github.com/sddm/sddm/blob/v0.21.0/src/greeter/KeyboardModel.h)
- [ThemeConfig](https://github.com/sddm/sddm/blob/v0.21.0/src/common/ThemeConfig.cpp)
- [Theming](https://github.com/sddm/sddm/blob/v0.21.0/docs/THEMING.md)
- [ArchWiki SDDM](https://wiki.archlinux.org/title/SDDM)
- [Qt Quick](https://doc.qt.io/qt-6/qtquick-index.html)
