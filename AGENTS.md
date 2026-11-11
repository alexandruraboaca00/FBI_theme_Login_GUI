# FBI_theme_Login_GUI — mantenimiento

Las guías de uso están indexadas en docs/README.md; colaboración en CONTRIBUTING.md.
El tema autocontenido está en src/theme. Lienzo lógico 1600×900, escalado uniforme.
Los valores predeterminados son focos con barcos y reloj bajo el emblema.
No modificar la imagen de referencia; su hash se documenta en docs/design.md.
La maestra local assets/reference/Imagen.jpg, si existe, no se publica en Git.

## Seguridad

Durante desarrollo, escribir sólo en el proyecto o /tmp. Operaciones privilegiadas
de instalación/activación sólo si el usuario las solicita expresamente y con backup.
Nunca reiniciar SDDM, cerrar sesión, cambiar PAM o servicios como parte de una prueba.
Las pruebas del ciclo de vida usan raíces temporales. Nunca usar credenciales reales
ni registrar contraseñas; los dobles conservan sólo longitud y datos ficticios.
Mantener intactos SDDM, los temas de recuperación y Plasma Login Manager.
No suponer que el tema actualmente seleccionado en el equipo sea elarun.

## Contratos y validación

Consultar la fuente oficial SDDM v0.21.0; enlaces exactos en docs/architecture.md.
Usar Qt 6 y controles Basic personalizados, sin imports KDE. Autenticación sólo
mediante sddm.login(user,password,sessionIndex); no reenviar peticiones por timeout.
Después de cambios ejecutar scripts/test.sh y revisar realmente las capturas,
especialmente 1920×1080. Distinguir dobles, greeter test-mode y PAM real.
No afirmar pruebas físicas de monitores o GPU basándose en offscreen/software.
La biblioteca de captura sólo actúa en el proceso hijo con --test-mode y nunca
se instala con el tema. Resultados, cachés, binarios e inventarios locales no se publican.

## Publicación

Revisar la licencia del código y NOTICE antes de publicar recursos. La fuente y
los datos cartográficos mantienen sus licencias. No atribuir propiedad ni licenciar
de nuevo la imagen de referencia. Mantener instrucciones de instalación y TTY.
