# Descripción de la solución

> Jira: DWI-55 · Responsable: Marco Andrey López Quesada
> Sección del documento final. **Pendiente:** completar el apartado de reportes cuando esté listo el libro de Excel (DWI-42 y DWI-43).

## Arquitectura

La solución tiene cuatro componentes, por los que los datos avanzan en una sola dirección:

| Componente | Herramienta | Función |
|---|---|---|
| Fuente | PostgreSQL 15 (base Pagila) | Sistema transaccional de Invacom con los alquileres, pagos e inventario |
| ETL | Alteryx Designer 2025.2 | Extrae, limpia, transforma y carga los datos |
| Data warehouse | SQL Server 2025 Developer (base `DW_Invacom`) | Almacena el modelo dimensional |
| Reportes | Microsoft Excel | Tablas dinámicas conectadas directamente al data warehouse |

La base fuente no se modifica: toda corrección ocurre en Alteryx y queda documentada. Esto separa el sistema que registra las operaciones del sistema que las analiza, que es el principio de un data warehouse (Kimball & Ross, 2013). Se usó SQL Server como destino porque es gratuito en su edición Developer, admite llaves primarias, foráneas y restricciones que rechazan datos inválidos, y Excel se conecta a él de forma nativa. Alteryx Designer fue la herramienta ETL asignada al grupo; permite construir el proceso con herramientas visuales y dejar cada paso documentado en el mismo flujo.

Las conexiones se hacen por ODBC: el DSN `pagila_local` (controlador psqlODBC) para leer PostgreSQL y el DSN `DW_Invacom` (ODBC Driver 18 for SQL Server) para escribir en el data warehouse. Las contraseñas se configuran en cada equipo y no se guardan en el repositorio.

## Proceso ETL en Alteryx

El proceso se divide en cinco flujos que se ejecutan en orden. Cada flujo deja su resultado en archivos `.yxdb`, el formato nativo de Alteryx, y el siguiente los lee:

| Orden | Flujo | Responsable | Qué hace |
|---|---|---|---|
| 1 | `01_extraccion` | Juan Daniel Ulate | Lee 14 tablas de PostgreSQL y las guarda sin modificarlas |
| 2 | `02_limpieza` | Kristel Ramírez | Aplica las reglas de limpieza y genera los archivos limpios y los rechazos |
| 3 | `dim_fecha` | Krisley Castro | Genera el calendario (4 285 días) y carga `dim_fecha` |
| 4 | `03_dimensiones` | Marco López | Asigna llaves sustitutas y carga las dimensiones cliente, película, tienda y actor |
| 5 | `04_hechos` | Marco López | Calcula las medidas, busca las llaves y carga los hechos y la tabla puente |

**Extracción sin cambios.** El primer flujo copia las tablas tal como están, incluidos duplicados y nulos. Así la limpieza trabaja sobre una copia estable y cada exclusión queda registrada, en lugar de perderse al leer la fuente. Kimball y Caserta (2004) recomiendan esta separación entre extraer y limpiar para que el proceso se pueda repetir y auditar.

**Acuerdo de archivos entre flujos.** Los nombres, columnas y tipos de los archivos limpios se definieron por escrito antes de construir los flujos de carga (`docs/etl/01-contrato-archivos-limpios.md`). Esto permitió que cada integrante trabajara en paralelo sin depender de cómo el otro resolvía su parte.

**Llaves sustitutas.** Las dimensiones reciben llaves propias del data warehouse con las herramientas *Sort* y *Record ID*, y conservan el identificador de Pagila como llave de negocio única. Los hechos reemplazan cada identificador por su llave con la herramienta *Join* contra las dimensiones ya cargadas. Con esto, el data warehouse no depende de la numeración de la fuente (Kimball & Ross, 2013).

**Medidas calculadas.** El flujo de hechos suma los pagos de cada alquiler (*Summarize*) y calcula con *Formula* los días que duró el alquiler, los días de atraso y tres indicadores de 0 o 1: si se devolvió, si se devolvió fuera de plazo y si el pago fue de cero. Se guardan como números para que Excel pueda sumarlos y calcular porcentajes.

**Carga completa y repetible.** Como la fuente no recibe datos nuevos, cada ejecución vuelve a cargar todo. Antes de escribir, cada salida ejecuta un `DELETE` que vacía primero los hechos y después su propia tabla; así el proceso se puede ejecutar varias veces sin duplicar registros. No se usa la opción *Delete Data & Append* de Alteryx porque la ejecuta como `TRUNCATE`, y SQL Server no permite `TRUNCATE` en tablas referenciadas por llaves foráneas.

## Limpieza de datos

El perfilado de la fuente encontró 26 problemas, documentados con un código en la estrategia de limpieza (`docs/analisis/07-estrategia-de-limpieza.md`). Se aplicaron tres criterios:

1. **Nada se borra en silencio.** Lo que se excluye va al archivo `rechazos.yxdb` con el código de la regla que lo excluyó.
2. **Lo real pero especial se conserva con una marca.** Por ejemplo, los alquileres sin devolver o los pagos de cero.
3. **Las reglas no dependen de esta base en particular.** Se escriben como condiciones generales, no con identificadores fijos.

Los problemas que más afectan los resultados son:

| Código | Problema | Casos | Tratamiento |
|---|---|---:|---|
| C01 | Alquileres duplicados: misma copia y mismo cliente a 30 minutos o menos | 16 044 | Se excluye el de identificador mayor |
| C02 | Pagos de los alquileres duplicados | 16 044 | Se excluyen |
| C03 | Pagos asociados a un alquiler de otro cliente | 5 | Se excluyen |
| C05 | Todos los pagos están fechados en 2017, aunque los alquileres son de 2005 | todos | El análisis usa la fecha del alquiler |
| C06 | Alquileres sin fecha de devolución | 183 | Se conservan con `devuelto` = 0 |
| C04 | Pagos con monto cero | 24 | Se conservan con `pago_cero` = 1 |
| C14 | Nombres y títulos en mayúsculas | 1 799 | Se convierten a mayúscula inicial |
| C13 | Dos actrices con el mismo nombre | 2 | Se agrega su identificador al nombre |

El hallazgo principal fue C01: la mitad de los alquileres eran copias de otros. Sin esa regla, los ingresos serían 227 758,92 en lugar de 67 406,56.

## Validación

Los conteos del data warehouse se compararon con la fuente. La diferencia corresponde exactamente a los registros del archivo de rechazos:

| Dato | Fuente | Rechazados | Data warehouse |
|---|---:|---:|---:|
| Alquileres | 32 088 | 16 044 | 16 044 |
| Pagos | 32 093 | 16 049 | 16 044 |
| Copias | 4 581 | 0 | 4 581 |
| Película–actor | 5 462 | 0 | 5 462 |

Los totales cargados también coinciden con las consultas de referencia: ingresos de 67 406,56, 183 alquileres sin devolver y 51,2 % de devoluciones fuera de plazo. Además, las restricciones de SQL Server rechazan cualquier llave repetida o valor fuera de regla, así que un error de carga no pasa inadvertido.

## Reportes

> **[PENDIENTE]** Completar cuando esté listo el libro de Excel (DWI-42 y DWI-43): cómo se conecta Excel al data warehouse, qué tablas dinámicas responde cada pregunta de negocio y una captura de cada una.

## Referencias

Kimball, R., & Caserta, J. (2004). *The data warehouse ETL toolkit: Practical techniques for extracting, cleaning, conforming, and delivering data*. Wiley.

Kimball, R., & Ross, M. (2013). *The data warehouse toolkit: The definitive guide to dimensional modeling* (3.ª ed.). Wiley.
