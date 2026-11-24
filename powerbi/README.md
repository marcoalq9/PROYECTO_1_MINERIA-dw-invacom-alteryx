# Dashboard en Power BI (Proyecto 2)

Tablero de control con los KPIs gerenciales de Invacom Inc S.A., construido en **Power BI Desktop** y conectado al data warehouse `DW_Invacom` del Proyecto 1.

· Conexión inicial: `DWI-80` · Responsable: Kristel Ramírez 

## Archivo

| Archivo | Contenido |
|---|---|
| `Dashboard_Invacom.pbix` | Informe de Power BI con las tablas del DW importadas |
| `medidas/k7_k8.md` | Medidas DAX de K7 y K8, valores esperados y comprobación contra SQL (DWI-88) |

## Visuales de AppSource

El enunciado pide al menos dos gráficos que no vienen con Power BI. Se instalaron dos visuales gratuitos y certificados por Microsoft (*PBI Certified*), que muestran el valor de un KPI contra su meta con zonas de color (DWI-83):

| Visual | Proveedor | Uso previsto |
|---|---|---|
| **Bullet Chart** | Microsoft Corporation | Barra con el valor real, la marca de la meta y las zonas bueno/regular/malo |
| **Tachometer** | Annik Inc | Velocímetro con el valor real dentro de rangos de color |

Quedan guardados dentro del `.pbix` (`Report/CustomVisuals`), así que no hay que instalarlos en cada computadora: aparecen al final del panel *Visualizaciones*. Para instalar otro visual de AppSource hay que iniciar sesión en Power BI con el correo institucional.

## Conexión al DW

| Configuración | Valor |
|---|---|
| Origen | SQL Server (`DW_Invacom`) |
| Modo | **Importar** (no DirectQuery) |
| Autenticación | Windows (las mismas credenciales de SSMS) |
| Cifrado | Sin cifrado: el SQL Server local no tiene certificado, Power BI lo advierte y se acepta |
| Parámetros | `Servidor` (valor por defecto `localhost`) y `BaseDatos` (`DW_Invacom`) |

Las consultas no apuntan a un servidor fijo, sino a los parámetros `Servidor` y `BaseDatos`. Así cada integrante usa el mismo `.pbix` y solo cambia el nombre de su instancia.

Tablas del DW (scripts en `sql/`): `fact_alquiler`, `fact_inventario`, `dim_fecha`, `dim_cliente`, `dim_pelicula`, `dim_tienda`, `dim_actor` y `bridge_pelicula_actor`. En Power Query no se aplica ninguna transformación: la limpieza ya se hizo en el ETL de Alteryx.

## Cómo abrirlo en su computadora

1. Tener `DW_Invacom` cargado en su SQL Server local. Si no lo tiene, crear la base con los scripts de `sql/` y correr los workflows de `alteryx/workflows/` en el orden del README principal.
2. Hacer `git pull` y abrir `powerbi/Dashboard_Invacom.pbix`.
3. Inicio → **Transformar datos** → **Administrar parámetros**.
4. Cambiar `Servidor` por el nombre de su instancia, el mismo que usa para entrar en SSMS (por ejemplo `localhost` o `NOMBRE-PC\SQLEXPRESS`).
5. **Cerrar y aplicar** y luego **Actualizar**.
6. Si aparece el aviso **"Compatibilidad con cifrado"**, dar **Aceptar** para conectarse sin cifrado.

## Verificación de la carga

Después de actualizar, el recuento de filas de `fact_alquiler` debe dar **16.044**, la misma cifra validada en el Proyecto 1 (`docs/validaciones/conteos_totales.md`). Si da otro número, el DW local no está completo: revisar la ejecución del ETL (`docs/validaciones/ejecucion_ETL.md`).

## Reglas para trabajar el `.pbix` en equipo

- El `.pbix` es un archivo binario y Git **no puede combinar cambios** de dos personas. Si dos lo editan al mismo tiempo, se pierde el trabajo de uno.
- **Solo una persona lo edita a la vez.** Avisar por el chat del grupo antes de abrirlo para editar y al terminar de hacer push.
- Siempre hacer `git pull` antes de abrirlo y commit + push apenas se termine.
- Mensajes de commit con el código de la tarea de Jira, por ejemplo: `DWI-81: Agrega relaciones del modelo estrella`.


