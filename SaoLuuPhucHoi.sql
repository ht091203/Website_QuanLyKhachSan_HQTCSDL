
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

--=====================================
CREATE OR ALTER PROCEDURE sp_TuDongBackup_DB_KhachSan
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra database tồn tại
    IF DB_ID('DB_KhachSan') IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy database DB_KhachSan', 16, 1);
        RETURN;
    END;

    -- Đảm bảo chế độ FULL
    ALTER DATABASE DB_KhachSan SET RECOVERY FULL;

    --------------------------------------------------------
    -- Lấy thời gian hiện tại
    --------------------------------------------------------
    DECLARE @Now       DATETIME = GETDATE();
    DECLARE @Thu       INT      = DATEPART(WEEKDAY, @Now);  -- 1=CN, 2=T2, ..., 7=T7 (nếu @@DATEFIRST = 7)
    DECLARE @Gio       INT      = DATEPART(HOUR,   @Now);
    DECLARE @Phut      INT      = DATEPART(MINUTE, @Now);

    --------------------------------------------------------
    -- Bảng lịch backup trong bộ nhớ
    --  BackupType: 'FULL' / 'DIFF' / 'LOG'
    --  ThuRun: 1=CN, 2=T2, 3=T3, 4=T4, 5=T5, 6=T6, 7=T7
    --  LOG: chạy mỗi ngày lúc 12:00 → ThuRun = NULL
    --------------------------------------------------------
    DECLARE @Schedule TABLE (
        BackupType NVARCHAR(10),
        ThuRun     INT NULL,
        GioRun     INT,
        PhutRun    INT
    );

    -- FULL: T2 & T5 lúc 23:00
    INSERT INTO @Schedule VALUES ('FULL', 2, 23, 0);  -- Thứ 2
    INSERT INTO @Schedule VALUES ('FULL', 5, 23, 0);  -- Thứ 5

    -- DIFF: T3, T4, T6, T7, CN lúc 23:00
    INSERT INTO @Schedule VALUES ('DIFF', 3, 23, 0);  -- Thứ 3
    INSERT INTO @Schedule VALUES ('DIFF', 4, 23, 0);  -- Thứ 4
    INSERT INTO @Schedule VALUES ('DIFF', 6, 23, 0);  -- Thứ 6
    INSERT INTO @Schedule VALUES ('DIFF', 7, 23, 0);  -- Thứ 7
    INSERT INTO @Schedule VALUES ('DIFF', 1, 23, 0);  -- Chủ nhật

    -- LOG: mỗi ngày lúc 12:00
    INSERT INTO @Schedule VALUES ('LOG', NULL, 12, 0);

    --------------------------------------------------------
    -- Cursor duyệt lịch
    --------------------------------------------------------
    DECLARE 
        @BackupType NVARCHAR(10),
        @ThuRun     INT,
        @GioRun     INT,
        @PhutRun    INT;

    DECLARE curBackup CURSOR FOR
        SELECT BackupType, ThuRun, GioRun, PhutRun
        FROM @Schedule;

    OPEN curBackup;
    FETCH NEXT FROM curBackup INTO @BackupType, @ThuRun, @GioRun, @PhutRun;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Kiểm tra xem lịch này có trùng thời gian hiện tại không
        DECLARE @IsMatch BIT = 0;

        IF @BackupType IN ('FULL', 'DIFF')
        BEGIN
            -- Có ràng buộc thứ trong tuần
            IF (@ThuRun = @Thu) 
               AND (@GioRun = @Gio) 
               AND (@PhutRun = @Phut)
            BEGIN
                SET @IsMatch = 1;
            END
        END
        ELSE IF @BackupType = 'LOG'
        BEGIN
            -- LOG chạy mỗi ngày, chỉ check giờ & phút
            IF (@GioRun = @Gio) AND (@PhutRun = @Phut)
            BEGIN
                SET @IsMatch = 1;
            END
        END

        IF @IsMatch = 1
        BEGIN
            DECLARE @BackupDir NVARCHAR(260);
            DECLARE @FileName  NVARCHAR(260);

            IF @BackupType = 'FULL'
            BEGIN
                SET @BackupDir = N'C:\Backup\DB_KhachSan\Full\';
                SET @FileName  = @BackupDir
                                + N'DB_KhachSan_FULL_'
                                + CONVERT(NVARCHAR(8), @Now, 112)
                                + N'_'
                                + REPLACE(CONVERT(NVARCHAR(8), @Now, 108), ':', '')
                                + N'.bak';

                PRINT N'>>> Đang thực hiện BACKUP FULL vào file: ' + @FileName;

                BACKUP DATABASE DB_KhachSan
                TO DISK = @FileName
                WITH INIT,
                     COMPRESSION,
                     STATS = 10;
            END
            ELSE IF @BackupType = 'DIFF'
            BEGIN
                SET @BackupDir = N'C:\Backup\DB_KhachSan\Diff\';
                SET @FileName  = @BackupDir
                                + N'DB_KhachSan_DIFF_'
                                + CONVERT(NVARCHAR(8), @Now, 112)
                                + N'_'
                                + REPLACE(CONVERT(NVARCHAR(8), @Now, 108), ':', '')
                                + N'.bak';

                PRINT N'>>> Đang thực hiện BACKUP DIFFERENTIAL vào file: ' + @FileName;

                BACKUP DATABASE DB_KhachSan
                TO DISK = @FileName
                WITH DIFFERENTIAL,
                     INIT,
                     COMPRESSION,
                     STATS = 10;
            END
            ELSE IF @BackupType = 'LOG'
            BEGIN
                SET @BackupDir = N'C:\Backup\DB_KhachSan\Log\';
                SET @FileName  = @BackupDir
                                + N'DB_KhachSan_LOG_'
                                + CONVERT(NVARCHAR(8), @Now, 112)
                                + N'_'
                                + REPLACE(CONVERT(NVARCHAR(8), @Now, 108), ':', '')
                                + N'.trn';

                PRINT N'>>> Đang thực hiện BACKUP LOG vào file: ' + @FileName;

                BACKUP LOG DB_KhachSan
                TO DISK = @FileName
                WITH INIT,
                     COMPRESSION,
                     STATS = 10;
            END
        END

        FETCH NEXT FROM curBackup INTO @BackupType, @ThuRun, @GioRun, @PhutRun;
    END

    CLOSE curBackup;
    DEALLOCATE curBackup;
END
GO

--sqlcmd -S .\MSSQLSERVER01 -E -Q "EXEC master.dbo.sp_TuDongBackup_DB_KhachSan;"

