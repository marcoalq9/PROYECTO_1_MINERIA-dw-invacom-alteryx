# Proyecto 1 · Minería de Datos 3C2026 — Data Warehouse Invacom Inc S.A.

Implementación de un Data Warehouse para **Invacom Inc S.A.** a partir de la base de datos fuente asignada por el profesor. El proceso ETL se desarrolla con **Alteryx Designer** y los reportes se construyen con tablas dinámicas de Excel conectadas al DW.

Universidad Técnica Nacional — Sede San Carlos.

## Equipo

| Integrante | Usuario GitHub | Rol |
|---|---|---|
| Marco Andrey López Quesada | @marcoalq9 | Desarrollo |
| Krisley Endrina Castro Barrantes | @Sweetkriiz | Desarrollo |
| Juan Daniel Ulate Aguilar | @Juanulate01 | Desarrollo |
| Kristel Daniela Ramírez Duarte | @ikrisr | Scrum Master |

- **Coordinador** (nombrado por el profesor):
- **Scrum Master:** Kristel Daniela Ramírez Duarte
- **Product Owner:** el profesor

## Estructura del repositorio

```
├── alteryx/
│   ├── workflows/     # Workflows de ETL (.yxmd)
│   └── macros/        # Macros reutilizables (.yxmc)
├── sql/               # Scripts para crear el DW (tablas, llaves, vistas)
├── docs/
│   ├── analisis/      # Requisitos, objetivos, inventario de fuentes y calidad de datos
│   ├── modelo/        # Diagrama del modelo dimensional
│   ├── sprints/       # Evidencia semanal: planning, capturas del tablero, review
│   └── entrega/       # Documento final en APA 7
├── reportes/          # Libros de Excel con tablas dinámicas conectadas al DW
└── datos/             # Notas sobre la BD fuente (no subir respaldos grandes)
```

## Flujo ETL (Alteryx)

| Orden | Workflow | Propósito |
|---|---|---|
| 1 | `01_extraccion.yxmd` | Conexión a la BD fuente y extracción de tablas |
| 2 | `02_limpieza.yxmd` | Manejo de nulos, duplicados y formatos inconsistentes |
| 3 | `03_dimensiones.yxmd` | Carga de dimensiones con llaves sustitutas |
| 4 | `04_hechos.yxmd` | Carga de la tabla de hechos |

_Los nombres son una propuesta; ajustarlos cuando existan los workflows._

## Cómo trabajamos

- **Sprints de una semana.** de miércoles a miércoles. El Sprint Planning es cada miércoles y cada sprint termina con un entregable concreto en este repo.
- **Daily Asíncrono** por el chat del grupo: que hice, que haré y que me bloquea 
- **Tablero en Jira:** proyecto `DWI` en https://marcolopezquesada15.atlassian.net 
- **Commits:** todos los integrantes hacen commits cada semana con sus propios aportes.
- **Mensajes de commit** en español y en imperativo, por ejemplo: `Agrega workflow de limpieza de clientes`.
- **Ramas:** una rama por tarea (`feature/dim-tiempo`), fusionada a `main` por pull request.

## Entregables

- [ ] Modelo dimensional (`docs/modelo/`)
- [ ] Workflows de ETL funcionando de punta a punta (`alteryx/workflows/`)
- [ ] Scripts del DW (`sql/`)
- [ ] Tablas dinámicas en Excel conectadas al DW (`reportes/`)
- [ ] Documento final en APA 7 (`docs/entrega/`)
- [ ] Evidencia semanal de sprints (`docs/sprints/`)
