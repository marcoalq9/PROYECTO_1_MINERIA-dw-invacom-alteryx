# Dashboard en Power BI (Proyecto 2)

Tablero de control con los KPIs gerenciales de Invacom Inc S.A., construido en **Power BI Desktop** y conectado al data warehouse `DW_Invacom` del Proyecto 1.

· Conexión inicial: `DWI-80` · Responsable: Kristel Ramírez 

## Archivo

| Archivo | Contenido |
|---|---|
| `Dashboard_Invacom.pbix` | Informe de Power BI con las tablas del DW importadas |
| `medidas/base.md` | Medidas DAX base del equipo: Ingresos, Alquileres, Clientes activos, Copias e Ingresos mes anterior (DWI-84) |
| `medidas/k1_k2.md` | Medidas DAX de K1 y K2, valores esperados, comprobación contra SQL (DWI-85) y medidas de las tarjetas y gráficos de su página (DWI-90) |
| `medidas/k7_k8.md` | Medidas DAX de K7 y K8, valores esperados y comprobación contra SQL (DWI-88), visuales de su página (DWI-93) y página de contexto (DWI-96) |
| `medidas/matriz_funciones_dax.md` | Matriz de control de funciones DAX por integrante (DWI-89) |
| `medidas/k3_k4.md` | Medidas y visuales de clientes |
| `medidas/k5_k6.md` | Medidas y comparaciones mensuales de inventario |
| `../docs/validaciones/proyecto2/qa_dashboard.md` | QA del 27/11/2026: checklist, evidencias y observaciones abiertas; K2/K3 sin cambios por indicación del usuario |

## Páginas y navegación

El PBIX revisado el 27/11/2026 tiene siete páginas visibles: **Ingresos** (K1 y K2), **Clientes** (K3 y K4), **Inventario** (K5 y K6), **Devoluciones** (K7 y K8), **Contexto** (preguntas 3, 4, 7 y 8), **Árbol de ingresos** y **Mapa** (pregunta 6). No contiene una Página 1 oculta en esta versión.

El [QA](../docs/validaciones/proyecto2/qa_dashboard.md) registra los objetos analíticos por página. Inventario tiene siete si se cuentan sus cuatro tarjetas, dos gráficos y tabla individualmente; hay que contrastar con el enunciado original si el máximo de seis incluye esos objetos. No se debe afirmar cumplimiento de ese límite sin aclararlo.

Cada página trae a la izquierda el mismo menú lateral (DWI-90): un fondo oscuro de 250 px de ancho, el título *INVACOM DASHBOARD* y un **navegador de páginas** de Power BI. El navegador se arma solo con los nombres de las páginas visibles, así que si alguien cambia el nombre de una página o agrega otra, el menú se actualiza sin tocarlo.

Para que todas las páginas se vean iguales:

- Poner los visuales a la derecha del menú, desde **x = 280**. El lienzo es de 1920 × 1080.
- Dejar arriba el título de la página (x = 280, y = 20) y los segmentadores de mes y tienda.
- No mover ni borrar el menú. Si se borra por error, copiarlo de otra página (fondo, título y navegador) y pegarlo: queda en la misma posición.

## Visuales de AppSource

El enunciado pide al menos dos gráficos que no vienen con Power BI. Se instalaron dos visuales gratuitos y certificados por Microsoft (*PBI Certified*), que muestran el valor de un KPI contra su meta con zonas de color (DWI-83):

| Visual | Proveedor | Uso previsto |
|---|---|---|
| **Bullet Chart** | Microsoft Corporation | Barra con el valor real, la marca de la meta y las zonas bueno/regular/malo |
| **Tachometer** | Annik Inc | Velocímetro con el valor real dentro de rangos de color |

En la página **Devoluciones · K7 y K8** el Tachometer muestra K7 contra su meta y el Bullet Chart muestra K8 por mes contra su meta (DWI-93).

El QA confirmó ambos en uso y renderizados, además de Deneb y Bullet Chart en Clientes. El árbol usa el visual nativo de descomposición; el mapa usa el visual nativo **Azure Maps** (sucesor del visual `Map` de Bing, que Microsoft está retirando), con País → Ciudad, burbujas por Alquileres e Ingresos en la información sobre herramientas. Mapa tiene menú, cabecera y segmentadores independientes de mes y tienda. Para que se muestre se necesitan Internet y sesión iniciada en Power BI Desktop: ver el paso 7 de *Cómo abrirlo en su computadora*.

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
7. Revisar la página **Mapa**. Si sale en blanco o con error:
   - «Para mostrar los objetos visuales de Azure Maps, inicie sesión» → iniciar sesión en Power BI Desktop (arriba a la derecha) con la cuenta institucional.
   - «No están habilitados para su organización» → lo bloquea el administrador de la cuenta, no el archivo; cerrar sesión o usar otra cuenta.
   - «Los objetos visuales de mapa … están deshabilitados» → *Archivo → Opciones y configuración → Opciones → Global → Seguridad* → marcar **«Usar objetos visuales de mapa y de mapa coroplético»**.

   La captura de respaldo está en `docs/validaciones/evidencias/qa_mapa_azure.png` y la explicación en el documento final (`docs/entrega/metodologia-kpis.md`, sección *Requisitos para visualizar la página Mapa*).

## Verificación de la carga

Después de actualizar, el recuento de filas de `fact_alquiler` debe dar **16.044**, la misma cifra validada en el Proyecto 1 (`docs/validaciones/conteos_totales.md`). Si da otro número, el DW local no está completo: revisar la ejecución del ETL (`docs/validaciones/ejecucion_ETL.md`).

## Reglas para trabajar el `.pbix` en equipo

- El `.pbix` es un archivo binario y Git **no puede combinar cambios** de dos personas. Si dos lo editan al mismo tiempo, se pierde el trabajo de uno.
- **Solo una persona lo edita a la vez.** Avisar por el chat del grupo antes de abrirlo para editar y al terminar de hacer push.
- Siempre hacer `git pull` antes de abrirlo y commit + push apenas se termine.
- Mensajes de commit con el código de la tarea de Jira, por ejemplo: `DWI-81: Agrega relaciones del modelo estrella`.


