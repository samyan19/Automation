/*
--1. Create DBA_Admin database 
*/
create database DBA_Admin;
GO

/*
--2. Set DBA_Admin database to simple recovery mode
*/

USE [master]
GO
alter database DBA_Admin set recovery simple with no_wait;