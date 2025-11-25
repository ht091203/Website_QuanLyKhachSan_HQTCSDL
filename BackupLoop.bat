@echo off
title Tu Dong Backup DB_KhachSan

echo Dang bat dau che do tu dong backup...
echo Se kiem tra moi 60 giay...
echo -----------------------------------------

:loop
sqlcmd -S .\MSSQLSERVER01 -E -Q "EXEC master.dbo.sp_TuDongBackup_DB_KhachSan;"
echo Da goi proc luc %time%
timeout /t 60 >nul
goto loop
