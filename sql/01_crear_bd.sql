/* ============================================================
   01_crear_bd.sql
   Crea la base de datos del data warehouse de Invacom Inc S.A.
   Jira: DWI-33 · Responsable: Marco Andrey López Quesada
   Motor: SQL Server 2025 Developer
   ============================================================ */

USE master;
GO

IF DB_ID(N'DW_Invacom') IS NULL
    CREATE DATABASE DW_Invacom;
GO

USE DW_Invacom;
GO
