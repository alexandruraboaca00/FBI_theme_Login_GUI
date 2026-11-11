# Contribuir

Gracias por ayudar a mantener FBI Theme Login GUI. El objetivo es una interfaz de
acceso reconocible, legible y estable, con cambios verificables y recuperación sencilla.

## Preparar el entorno

En Arch Linux, además de las dependencias de ejecución:

```bash
sudo pacman -S --needed cmake ninja gcc pkgconf python python-pytest
./scripts/test.sh
```

El tema instalable está en `src/theme`; no requiere compilar para usarlo.
Las herramientas C++ de `tools` sólo sirven para capturar el greeter en test-mode.
Resultados y binarios se generan en rutas ignoradas por Git.

Para ejecutar sólo las pruebas Python, sin Qt ni instalación de sistema:

```bash
python3 -m pytest -q tests/test_lifecycle.py tests/test_maritime.py
```

La CI ejecuta esos casos con Python 3.11 y 3.13. Qt Quick Test, qmllint y las
capturas se ejecutan localmente con herramientas Qt 6; no se presentan como
validación automática de PAM o de hardware gráfico.

## Trabajar en un cambio

1. Explica el problema o el resultado esperado y limita el cambio a ese objetivo.
2. Mantén el directorio instalable autocontenido y las opciones en theme.conf.user.
3. Prueba con `./scripts/test.sh`; revisa realmente la captura a 1920×1080 si cambia la interfaz.
4. Actualiza la guía afectada y el resultado de validación cuando corresponda.
5. Abre una pull request con descripción, pruebas y limitaciones.

Las pruebas del instalador usan raíces temporales. No reinicies SDDM, cambies PAM,
actives el tema ni cierres sesiones para verificar una contribución. No uses
credenciales reales en test-mode ni las incluyas en reportes.

## Criterios de revisión

- Autenticación mediante la API de SDDM, sin almacenamiento o logs de contraseñas.
- Recursos locales y legibles por el greeter; sin rutas personales ni descargas en runtime.
- Foco, teclado, estados de error y sesiones preservados tras cambios visuales.
- Instalación y recuperación que respeten archivos ajenos y configuración previa.
- Referencias de API fijadas a versión y evidencia propia diferenciada de supuestos.
- Atribuciones conservadas y derechos claros para nuevos recursos gráficos.

Consulta [arquitectura](docs/architecture.md), [referencias](docs/references.md) y
[validación](docs/testing.md) antes de modificar contratos con SDDM.
No añadas capturas repetidas, inventarios privados, cachés o binarios al repositorio.

## Reportes

Usa [la plantilla de errores](https://github.com/alexandruraboaca00/FBI_theme_Login_GUI/issues/new/choose).
Indica si el fallo pertenece al greeter real o al modo de prueba. Para una mejora,
explica el uso que resuelve y cómo mantendría la legibilidad y el flujo de acceso.
