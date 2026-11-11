# Documentación

Guías de **FBI Theme Login GUI**, tema de SDDM con Qt 6 orientado a KDE Plasma 6
en Arch Linux. La versión predeterminada incluye mapa de focos, barcos y reloj superior.

## Usar y administrar

| Guía | Qué encontrarás |
|---|---|
| [Instalación](installation.md) | Comprobaciones previas, simulación, activación, backup, actualización y retirada |
| [Configuración](configuration.md) | Opciones, valores predeterminados, presets y ejemplos |
| [Compatibilidad](dependencies.md) | Diferencias entre SDDM, Plasma, Qt, X11 y Wayland; paquetes y entorno probado |
| [Problemas y recuperación](troubleshooting.md) | Vista previa, sesiones, usuario recordado, permisos y restauración desde TTY |

**Primera instalación:** compatibilidad → vista previa → recuperación → instalación.
Los scripts no habilitan otro display manager ni reinician servicios.

## Comprender y contribuir

| Documento | Qué encontrarás |
|---|---|
| [Arquitectura](architecture.md) | Componentes, autenticación, recursos, monitores y herramientas |
| [Diseño](design.md) | Composición de referencia, CRT, cartografía y animaciones |
| [Validación](testing.md) | Casos de prueba, evidencias y verificaciones pendientes |
| [Referencias](references.md) | Fuentes oficiales y qué afirmaciones respalda cada una |
| [Contribuir](../CONTRIBUTING.md) | Entorno de desarrollo y preparación de cambios |

## Mapa del repositorio

```text
FBI_theme_Login_GUI/
├── src/theme/              # Distribución instalable autocontenida
│   ├── components/         # Interfaz, autenticación y animaciones
│   └── assets/             # Imágenes, fuente y datos locales
├── scripts/                # Vista previa, administración y pruebas
├── tests/                  # QML, ciclo de vida y geometría marítima
├── tools/                  # Captura del greeter y generación de mapas
├── docs/                   # Guías, diseño y referencias
│   └── media/              # Recursos visuales de la documentación
└── .github/                # CI y plantillas de colaboración
```

Resultados, capturas intermedias, cachés y binarios son regenerables y están
excluidos de Git. La fuente del tema no depende de directorios personales.

[Volver a la portada](../README.md)
