
----Recovery======================================================
ALTER DATABASE DB_KhachSan
SET RECOVERY FULL;

--Backup full cho T2 và T5 vào 23:00
DECLARE @BackupDir NVARCHAR(260) = N'C:\Backup\DB_KhachSan\Full\';
DECLARE @FileName  NVARCHAR(260);

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DB_KhachSan')
BEGIN
    RAISERROR(N'Không tìm thấy database DB_KhachSan', 16, 1);
    RETURN;
END

SET @FileName = @BackupDir 
    + N'DB_KhachSan_FULL_' 
    + CONVERT(NVARCHAR(8), GETDATE(), 112)   
    + N'_' 
    + REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '') 
    + N'.bak';

PRINT N'Backup FULL vào file: ' + @FileName;

BACKUP DATABASE DB_KhachSan
TO DISK = @FileName
WITH INIT,
     COMPRESSION,
     STATS = 10;

--Backup Diff cho T3, T4, T6, T7, CN vào lúc 23:00
DECLARE @BackupDir NVARCHAR(260) = N'C:\Backup\DB_KhachSan\Diff\';
DECLARE @FileName  NVARCHAR(260);

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DB_KhachSan')
BEGIN
    RAISERROR(N'Không tìm thấy database DB_KhachSan', 16, 1);
    RETURN;
END

SET @FileName = @BackupDir 
    + N'DB_KhachSan_DIFF_' 
    + CONVERT(NVARCHAR(8), GETDATE(), 112) 
    + N'_' 
    + REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '') 
    + N'.bak';

PRINT N'Backup DIFFERENTIAL vào file: ' + @FileName;

BACKUP DATABASE DB_KhachSan
TO DISK = @FileName
WITH DIFFERENTIAL,
     INIT,
     COMPRESSION,
     STATS = 10;

--Backup log vào 12:00 mỗi ngày
DECLARE @BackupDir NVARCHAR(260) = N'C:\Backup\DB_KhachSan\Log\';
DECLARE @FileName  NVARCHAR(260);

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DB_KhachSan')
BEGIN
    RAISERROR(N'Không tìm thấy database DB_KhachSan', 16, 1);
    RETURN;
END

SET @FileName = @BackupDir 
    + N'DB_KhachSan_LOG_' 
    + CONVERT(NVARCHAR(8), GETDATE(), 112) 
    + N'_' 
    + REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '') 
    + N'.trn';

PRINT N'Backup LOG vào file: ' + @FileName;

BACKUP LOG DB_KhachSan
TO DISK = @FileName
WITH INIT,
     COMPRESSION,
     STATS = 10;


--test PHỤC HỒI===========================================
/* 1. GIẢ LẬP THÊM DỮ LIỆU TRƯỚC KHI SỰ CỐ */
USE DB_KhachSan;
GO

INSERT INTO KhachHang (HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi)
VALUES (N'Test Phuc Hoi', '2000-01-01', 'NAM', '0999999999', 'test.phuchoi@gmail.com', N'TP.HCM');

SELECT * FROM KhachHang WHERE SoDienThoai = '0999999999';

-- GIẢ LẬP SỰ CỐ: DROP DATABASE
USE master;
GO

ALTER DATABASE DB_KhachSan SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE DB_KhachSan;
GO

/* 2.1. RESTORE FULL BACKUP */
RESTORE DATABASE DB_KhachSan
FROM DISK = N'C:\Backup\DB_KhachSan\Full\DB_KhachSan_FULL_20251124_201558.bak'  
WITH 
    MOVE 'DB_KhachSan'     TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\DB_KhachSan.mdf',  
    MOVE 'DB_KhachSan_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\DB_KhachSan_log.ldf',
    NORECOVERY,   
    REPLACE,
    STATS = 10;
GO

/* 2.2. RESTORE DIFFERENTIAL BACKUP MỚI NHẤT */
RESTORE DATABASE DB_KhachSan
FROM DISK = N'C:\Backup\DB_KhachSan\Diff\DB_KhachSan_DIFF_20251124_201602.bak'  
WITH 
    NORECOVERY,
    STATS = 10;
GO

/* 2.3. RESTORE CÁC LOG BACKUP TỪ SAU BẢN DIFF ĐẾN TRƯỚC KHI SỰ CỐ */

RESTORE LOG DB_KhachSan
FROM DISK = N'C:\Backup\DB_KhachSan\Log\DB_KhachSan_LOG_20251124_201606.trn'  
WITH 
    NORECOVERY,
    STATS = 10;
GO

RESTORE DATABASE DB_KhachSan WITH RECOVERY;

USE DB_KhachSan;
GO

SELECT * FROM KhachHang WHERE SoDienThoai = '0999999999';

