# Diseño

El fondo parte de una referencia 1600×900 suministrada durante el desarrollo:
emblema cian, terminal azul oscuro, dos campos y advertencia roja. Se conserva la
composición y se reconstruye el formulario como controles reales de Qt Quick.
La fuente técnica es Share Tech Mono, una aproximación a la del original.

La imagen permanece intacta en `src/theme/assets/reference.jpg`.
SHA-256: fbe3f5c930bdc57f9549feb61891310672e9e32c9885fa639eb1f6c9dab14faa.
Una máscara QML sustituye los controles dibujados por textura vacía adyacente de
la misma imagen. No se ha usado generación ni reescalado con IA.

El reloj está bajo el emblema; la hora tiene mayor tamaño y la fecha aparece debajo.
El CRT emplea contornos luminosos y líneas horizontales suaves, sin parpadeos de
pantalla. La imagen y sus textos raster conservan su resolución original.

## Mapa de focos

Los continentes proceden de Natural Earth. El mapa ocupa 1420×570 unidades en el
lienzo lógico; su proporción evita el achatamiento de las primeras iteraciones.
La paleta combina costas azul violáceo, tráfico cian y focos cálidos. Cada recorrido
tiene vuelo con estela, llegada con dos ondas y reposo; los ritmos están escalonados.
No se representan ataques reales. Las siluetas navales siguen cuatro rutas oceánicas
con rumbo y estela en V, a menor velocidad que las partículas de red.

La tierra se dibuja en una capa estática; la actividad solicita un repintado cada
33 ms en el modo focos. Esto no garantiza FPS en todas las GPU. Máscaras suaves
protegen el formulario, el reloj y el emblema para conservar la legibilidad.

Las rutas marítimas se contrastan con tierra a escala 1:110m. Pueden no representar
islotes pequeños; no son rutas de navegación ni datos AIS.

Los valores predeterminados son la versión final de focos con barcos. Siguen
existiendo opciones de configuración para puntos, mapa estático o fondo sin mapa;
no se distribuyen carpetas duplicadas del tema.
