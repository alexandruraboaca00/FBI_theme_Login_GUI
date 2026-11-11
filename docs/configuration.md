# Personalización

Los valores predeterminados reproducen la versión final: mapa de focos con barcos,
reloj bajo el emblema, fecha `dd/MM/yyyy`, hora de 24 horas y CRT reforzado.

## Dónde guardar los ajustes

Crea `theme.conf.user` junto a `theme.conf` dentro del tema instalado. SDDM aplica
sus valores sobre el archivo base, según [ThemeConfig](references.md#sddm-contrato-versionado).
No reemplaces `theme.conf` para conservar una base identificable.

```ini
[General]
MapOpacity=0.50
ShowShips=true
CRTStrength=0.20
Animations=true
```

En una instalación de sistema necesitarás permisos de administrador para editarlo.
Para probar sin instalar, crea `src/theme/theme.conf.user` y abre directamente:

```bash
sddm-greeter-qt6 --test-mode --theme "$(pwd)/src/theme"
```

`./scripts/preview.sh` utiliza el preset final y fija varios ajustes artísticos;
la ejecución directa permite revisar todos tus overrides sin ese preset.

## Opciones

| Opción | Predeterminado | Límites y comportamiento |
|---|---|---|
| MapStyle | threats | threats: continentes y focos; dots: puntos cian |
| MapOpacity | 0.56 | Intensidad de mapa, 0–0.65 |
| AnimatedMap | true | Muestra u oculta toda la capa del mapa |
| Animations | true | false congela mapas y barcos |
| ShowShips | true | Barcos, sólo con MapStyle=threats |
| CRT | true | Activa el tratamiento CRT |
| CRTStrength | 0.24 | Intensidad de líneas, 0–0.35 |
| ClockPosition | header | header bajo el emblema; footer en el pie |
| ShowClock | true | Reloj y fecha |
| ShowUtilities | true | Franja inferior; también oculta el acceso al selector de sesión |
| Accent | #7cdfe5 | Color de controles |
| ErrorColor | #ff7279 | Color de mensajes de error |
| Dim | 0 | Oscurecimiento del fondo, 0–0.8 |
| PanelOpacity | 0.10 | Fondo de campos, 0–1 |
| MapDotSize | 2.7 | Tamaño del punto en el mapa dots, 1–4 |
| Background | assets/reference.jpg | Ruta relativa al tema o URL local |
| BackgroundMode | fit | fit completo; crop recortado, sin deformar |
| PanelOffsetX / PanelOffsetY | 0 / 0 | Desplazamientos acotados a ±80 / ±45 |

Los formatos de fecha y hora son fijos: `dd/MM/yyyy` y `HH:mm`.
Las animaciones nunca consultan servicios de ataques o barcos reales.

## Ejemplos

### Mapa de puntos

```ini
[General]
MapStyle=dots
MapOpacity=0.48
MapDotSize=2.7
```

### Menos movimiento

```ini
[General]
Animations=false
ShowShips=false
CRTStrength=0.12
```

### Fondo original sin mapa

```ini
[General]
AnimatedMap=false
CRT=false
```

## Fondos, permisos y actualizaciones

Guarda fondos alternativos dentro del directorio del tema. Deben ser legibles
por sddm y no depender de rutas privadas. La distribución instalable es autocontenida.
Un fondo alternativo debe carecer de controles de acceso dibujados; la máscara
que retira el formulario raster está diseñada para la referencia incluida.
Si el fondo falla, el tema vuelve a la imagen de referencia incluida.

Los overrides añadidos o modificados después de instalar se protegen durante
la retirada: conserva tus ajustes y revisa el
[procedimiento de actualización](installation.md#actualizar).

[Diseño](design.md) · [Resolver problemas](troubleshooting.md) · [Índice](README.md)
