-- ============================================================
-- Script  : 01_create_database.sql
-- Purpose : Create the PBDemoDB database
-- Run As  : SA or sysadmin role
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'PBDemoDB')
BEGIN
    ALTER DATABASE PBDemoDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PBDemoDB;
END
GO

CREATE DATABASE PBDemoDB
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

PRINT 'Database PBDemoDB created successfully.';
GO
