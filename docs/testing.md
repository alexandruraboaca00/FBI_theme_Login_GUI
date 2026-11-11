# Validación

Las pruebas no ejecutan autenticación real, acciones de energía ni reinicios.
No se utilizan contraseñas reales. Resultados locales regenerables:

```bash
./scripts/test.sh
```

- 11 casos pytest de instalación, prioridad de configuración, rollback, manifiestos,
  destinos ajenos, symlinks, ajustes de usuario y selección de preset.
- 4 casos de rutas marítimas: 101 muestras por segmento contrastadas con tierra
  Natural Earth 1:110m.
- 15 casos de interacción Qt Quick, más inicio/fin: usuario, contraseña, Enter,
  reintentos, foco, sesión, teclado, capacidades de energía, diálogos, mensajes,
  pantalla secundaria, reloj, animaciones y barcos.
- qmllint sin avisos en la validación de desarrollo.
- Capturas del ejecutable real sddm-greeter-qt6 en test-mode/offscreen/software,
  sin fallback, a 1600×900, 1920×1080, 1366×768 y 2560×1440.
- DPR 1.25 y dos pantallas simuladas: una sola vista interactiva.
- Secuencia real de 50 fotogramas para revisar movimiento; GIF exportado a 10 fps.

Las capturas de muestra contienen un usuario y una contraseña ficticios inyectados
únicamente por la herramienta de captura. No se preconfiguran credenciales en el tema.
En test-mode es esperable un error de socket porque no hay daemon conectado.
Las capturas no demuestran PAM ni el comportamiento físico de la pantalla.

Se verificó además una instalación solicitada por el usuario: hashes íntegros,
lectura de los recursos con UID/GID de sddm y carga de la copia instalada en
modo de prueba. No se publican inventarios del equipo ni respaldos de configuración.

## Pendientes que no deben confundirse con verificaciones realizadas

- Inicio de sesión PAM real y persistencia posterior de la última sesión.
- Acciones físicas de energía, GPU/X11 y escalado de un greeter real.
- Monitores físicos, hotplug y cambio de monitor principal en caliente.
- Lector de pantalla y configuraciones de idioma/teclado diversas.

MFA y cambio obligatorio de contraseña no están implementados. El tamaño lógico
recomendado mínimo es 960×540. No se ha realizado un benchmark formal de FPS.
