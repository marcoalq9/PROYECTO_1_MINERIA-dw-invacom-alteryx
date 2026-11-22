# Tema visual de Invacom — Proyecto 2

Para que el dashboard del equipo tenga una apariencia uniforme, vamos a utilizar el tema **`tema_invacom_elegido.json`** en Power BI. Es un diseño oscuro, con fondo gris casi negro, letras claras y colores vivos (azul, celeste, morado, rosado y coral, entre otros). También incluye estilos para filtros, botones, bordes y algunos gráficos.

## Cómo descargarlo y aplicarlo

1. En el repositorio de GitHub, abrir la carpeta **`powerbi/`** y descargar **`tema_invacom_elegido.json`** y **`Dashboard_Invacom.pbix`**. Si ya tienen el repositorio clonado, basta con hacer `git pull` para obtener los últimos cambios.
2. Abrir **`Dashboard_Invacom.pbix`** en **Power BI Desktop**.
3. Ir a **Vista → Temas → Examinar temas** (el nombre puede variar según la versión de Power BI).
4. Seleccionar **`tema_invacom_elegido.json`** y comprobar que se apliquen los colores y estilos.
5. Si van a guardar cambios en el `.pbix`, coordinarlo con el equipo: **solo una persona debe editarlo a la vez**, porque Git no combina fácilmente ese archivo.

## Acuerdos de presentación

- Mantener el **fondo oscuro**, los textos claros y la paleta del JSON.
- Usar títulos claros y específicos para cada gráfico, no nombres genéricos.
- Revisar que las etiquetas, los números y las leyendas se puedan leer bien.
- Ajustar manualmente las **fuentes, tamaños, sombras y etiquetas** cuando el tema no los configure automáticamente.
- Configurar el **formato condicional** de cada KPI cuando el equipo defina los colores de cumplimiento.

> **Importante:** el JSON personaliza la apariencia general, pero **no sustituye la revisión de cada gráfico**. La rúbrica penaliza dejar visualizaciones con el formato predeterminado de Power BI.

**Ubicación sugerida en GitHub:** guardar esta guía y el JSON dentro de `powerbi/`, junto al archivo `.pbix`.
