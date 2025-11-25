
USE master;
GO

ALTER DATABASE DB_KhachSan SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE DB_KhachSan;
GO


CREATE DATABASE DB_KhachSan
GO
USE DB_KhachSan
GO

-- KHÁCH HÀNG
CREATE TABLE KhachHang (
    MaKH INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    SoDienThoai NVARCHAR(15) UNIQUE,
    Email NVARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(200) NOT NULL
);

-- NHÂN VIÊN
CREATE TABLE NhanVien (
    MaNV INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10) CHECK(GioiTinh IN ('NAM','NỮ')),
    SoDienThoai NVARCHAR(15) UNIQUE,
    Email NVARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(200) NOT NULL
);

-- TÀI KHOẢN
CREATE TABLE TaiKhoan (
    MaTK INT PRIMARY KEY IDENTITY(1,1),
    TenDN NVARCHAR(50) UNIQUE NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL,
    QuyenHan NVARCHAR(50),
    LoaiTaiKhoan NVARCHAR(10) CHECK (LoaiTaiKhoan IN ('KH','NV')),
    MaKH INT NULL,
    MaNV INT NULL,
    CONSTRAINT FK_TK_KH FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    CONSTRAINT FK_TK_NV FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT CK_TaiKhoan CHECK (
        (LoaiTaiKhoan = 'KH' AND MaKH IS NOT NULL AND MaNV IS NULL) OR
        (LoaiTaiKhoan = 'NV' AND MaNV IS NOT NULL AND MaKH IS NULL)
    )
);

-- LOẠI PHÒNG
CREATE TABLE LoaiPhong (
    MaLP INT IDENTITY(1,1) PRIMARY KEY,
    TenLoai NVARCHAR(50) NOT NULL,
    MoTa NVARCHAR(200) NULL,
    DonGia DECIMAL(18,2) NOT NULL CHECK (DonGia > 0),
    SucChua INT NOT NULL CHECK (SucChua > 0),
    Anh NVARCHAR(200) NOT NULL
);

-- PHÒNG
CREATE TABLE Phong (
    MaPhong INT PRIMARY KEY IDENTITY(1,1),
    SoPhong NVARCHAR(10) UNIQUE,
    ViTri NVARCHAR(50),
    MoTa NVARCHAR(200),
    MaLP INT NOT NULL,
    TrangThai NVARCHAR(20),
    CONSTRAINT FK_Phong_LP FOREIGN KEY (MaLP) REFERENCES LoaiPhong(MaLP)
);

-- ĐẶT PHÒNG
CREATE TABLE DatPhong (
    MaDP INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    NgayDat DATE NOT NULL,
    ThoiGianNhanPhong DATETIME,
	ThoiGianNhanPhongThucTe DATETIME NULL,
    ThoiGianTraPhongDuKien DATETIME,
	ThoiGianTraPhongThucTe DATETIME NULL,
    TinhTrang NVARCHAR(50),
    TongTienDuKien DECIMAL(18,2) CHECK(TongTienDuKien > 0),
    TrangThaiCoc NVARCHAR(20),
    CONSTRAINT FK_DatPhong_KH FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);



-- CHI TIẾT ĐẶT PHÒNG
CREATE TABLE CT_DatPhong (
    MaDP INT NOT NULL,
    MaPhong INT NOT NULL,
    DonGia DECIMAL(18,2) CHECK(DonGia > 0),
    SoNgayO INT CHECK(SoNgayO > 0),
    ThanhTien DECIMAL(18,2) CHECK(ThanhTien > 0),
    PRIMARY KEY (MaDP, MaPhong),
    CONSTRAINT FK_CTDP_DP FOREIGN KEY (MaDP) REFERENCES DatPhong(MaDP),
    CONSTRAINT FK_CTDP_Phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong)
);

-- PHIẾU CỌC
CREATE TABLE PhieuCoc (
    MaPC INT PRIMARY KEY IDENTITY(1,1),
    MaDP INT NOT NULL,
    NgayCoc DATE,
    SoTienCoc DECIMAL(18,2) NOT NULL CHECK(SoTienCoc > 0),
    PTTT NVARCHAR(50),
    CONSTRAINT FK_PC_DP FOREIGN KEY (MaDP) REFERENCES DatPhong(MaDP)
);

-- DỊCH VỤ
CREATE TABLE DichVu (
    MaDV INT PRIMARY KEY IDENTITY(1,1),
    TenDV NVARCHAR(100) NOT NULL,
    DonGia DECIMAL(18,2) NOT NULL CHECK(DonGia > 0),
    MoTa NVARCHAR(200)
);

-- HÓA ĐƠN
CREATE TABLE HoaDon (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaDP INT NOT NULL,
    NgayLap DATETIME DEFAULT GETDATE(),
    PTTT NVARCHAR(50),
    TrangThai NVARCHAR(20),
	TongTienDuKien DECIMAL(18,2) CONSTRAINT DF_HoaDon_TongTienDuKien DEFAULT (0),
    CONSTRAINT FK_HD_DP FOREIGN KEY (MaDP) REFERENCES DatPhong(MaDP)
);

-- CHI TIẾT DỊCH VỤ
CREATE TABLE CT_DichVu (
    MaHD INT NOT NULL,
    MaPhong INT NOT NULL,
    MaDV INT NOT NULL,
    SoLuong INT NOT NULL CHECK(SoLuong > 0),
    DonGia DECIMAL(18,2) CHECK(DonGia > 0),
    TrangThai NVARCHAR(20),
    PRIMARY KEY (MaHD, MaPhong, MaDV),
    CONSTRAINT FK_CTDV_HD FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
    CONSTRAINT FK_CTDV_Phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    CONSTRAINT FK_CTDV_DV FOREIGN KEY (MaDV) REFERENCES DichVu(MaDV)
);

-----MẪU INSERT
INSERT INTO KhachHang (HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi) VALUES
(N'Nguyễn Văn An', '1990-05-12', 'NAM', '0901111001', 'an.nguyen@gmail.com', N'Hà Nội'),
(N'Lê Thị Hồng', '1995-08-20', 'NỮ', '0901111002', 'hong.le@gmail.com', N'Đà Nẵng'),
(N'Trần Quốc Bảo', '1988-03-10', 'NAM', '0901111003', 'bao.tran@gmail.com', N'Hồ Chí Minh'),
(N'Phạm Thu Trang', '1997-11-02', 'NỮ', '0901111004', 'trang.pham@gmail.com', N'Cần Thơ'),
(N'Hoàng Minh Đức', '1992-09-14', 'NAM', '0901111005', 'duc.hoang@gmail.com', N'Huế');

INSERT INTO NhanVien (HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi) VALUES
(N'Nguyễn Thị Lan', '1985-01-15', 'NỮ', '0912222001', 'lan.nguyen@hotel.com', N'Hồ Chí Minh'),
(N'Lê Văn Hùng', '1989-06-09', 'NAM', '0912222002', 'hung.le@hotel.com', N'Bình Dương'),
(N'Phan Thanh Tâm', '1991-02-21', 'NAM', '0912222003', 'tam.phan@hotel.com', N'Long An');

INSERT INTO TaiKhoan (TenDN, MatKhau, QuyenHan, LoaiTaiKhoan, MaKH, MaNV) VALUES
(N'an_user', '123456', N'Khách hàng', 'KH', 1, NULL),
(N'hong_user', '123456', N'Khách hàng', 'KH', 2, NULL),
(N'bao_user', '123456', N'Khách hàng', 'KH', 3, NULL),
(N'trang_user', '123456', N'Khách hàng', 'KH', 4, NULL),
(N'duc_user', '123456', N'Khách hàng', 'KH', 5, NULL),
(N'lan_admin', 'admin123', N'Quản lý', 'NV', NULL, 1),
(N'hung_nv', '123456', N'Lễ tân', 'NV', NULL, 2),
(N'tam_nv', '123456', N'Dọn phòng', 'NV', NULL, 3);

INSERT INTO LoaiPhong (TenLoai, MoTa, DonGia, SucChua, Anh) VALUES
(N'Tiêu chuẩn', N'Phòng cơ bản 1 giường đôi', 400000, 2, N'standard.jpg'),
(N'Cao cấp', N'Phòng 2 giường, view thành phố', 700000, 4, N'deluxe.jpg'),
(N'Suite', N'Phòng VIP có phòng khách riêng', 1200000, 5, N'suite.jpg');

INSERT INTO Phong (SoPhong, ViTri, MoTa, MaLP, TrangThai)
VALUES
(N'101', N'Tầng 1', N'Phòng hướng sân vườn', 1, N'Trống'),
(N'102', N'Tầng 1', N'Phòng đơn nhỏ gọn', 1, N'Trống'),
(N'201', N'Tầng 2', N'View thành phố', 2, N'Trống'),
(N'202', N'Tầng 2', N'Phòng đôi cao cấp', 2, N'Đang dọn'),
(N'301', N'Tầng 3', N'Suite sang trọng', 3, N'Trống');

-- Thêm vài đặt phòng mẫu nữa
INSERT INTO DatPhong (
    MaKH, NgayDat, 
    ThoiGianNhanPhong, ThoiGianNhanPhongThucTe, 
    ThoiGianTraPhongDuKien, ThoiGianTraPhongThucTe, 
    TinhTrang, TongTienDuKien, TrangThaiCoc
)
VALUES
(4, '2025-10-06',
 '2025-10-20 13:00', NULL,
 '2025-10-23 12:00', NULL,
 N'Đã xác nhận', 1200000, N'Chưa cọc'),

(5, '2025-10-10',
 '2025-10-15 14:00', '2025-10-15 14:15',
 '2025-10-18 12:00', NULL,
 N'Đang ở', 1400000, N'Đã cọc'),

(2, '2025-10-12',
 '2025-10-18 15:00', NULL,
 '2025-10-20 11:00', NULL,
 N'Đã đặt', 700000, N'Chưa cọc'),

(3, '2025-09-25',
 '2025-09-28 14:00', '2025-09-28 14:05',
 '2025-09-29 12:00', '2025-09-29 11:30',
 N'Hoàn tất', 700000, N'Đã cọc');
GO

INSERT INTO CT_DatPhong (MaDP, MaPhong, DonGia, SoNgayO, ThanhTien) VALUES
(1, 2, 400000, 3, 1200000),
(2, 4, 700000, 2, 1400000),
(3, 3, 700000, 1, 700000),
(4, 3, 700000, 1, 700000);
GO

INSERT INTO PhieuCoc (MaDP, NgayCoc, SoTienCoc, PTTT) VALUES
(1, '2025-10-07', 1200000, N'Chuyển khoản'),
(2, '2025-10-11', 1400000, N'Tiền mặt'),
(3, '2025-10-13', 700000, N'Chuyển khoản'),
(4, '2025-09-26', 700000, N'Tiền mặt');
GO


INSERT INTO DichVu (TenDV, DonGia, MoTa) VALUES
(N'Giặt ủi', 50000, N'Dịch vụ giặt ủi quần áo'),
(N'Đưa đón sân bay', 200000, N'Xe 4 chỗ đón khách tận nơi'),
(N'Bữa sáng buffet', 100000, N'Buffet sáng đa dạng'),
(N'Massage thư giãn', 300000, N'Dịch vụ massage toàn thân');

INSERT INTO HoaDon (MaDP, PTTT, TrangThai) VALUES
(1, N'Tiền mặt', N'Đã thanh toán'),
(2, N'Chuyển khoản', N'Chưa thanh toán'),
(3, N'ATM', N'Đã thanh toán');

INSERT INTO CT_DichVu (MaHD, MaPhong, MaDV, SoLuong, DonGia, TrangThai) VALUES
(1, 1, 1, 2, 50000, N'Hoàn tất'),
(1, 1, 3, 2, 100000, N'Hoàn tất'),
(3, 5, 4, 1, 300000, N'Hoàn tất');
GO
------------------TRIGGER===============================
CREATE OR ALTER TRIGGER trg_Update_SoNgayO_CTDatPhong
ON DatPhong
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF (UPDATE(ThoiGianNhanPhong) OR UPDATE(ThoiGianTraPhongDuKien))
    BEGIN
        UPDATE c
        SET 
            c.SoNgayO = CASE 
                            WHEN DATEDIFF(DAY, d.ThoiGianNhanPhong, d.ThoiGianTraPhongDuKien) < 1 THEN 1
                            ELSE DATEDIFF(DAY, d.ThoiGianNhanPhong, d.ThoiGianTraPhongDuKien)
                        END,
            c.ThanhTien = c.DonGia * 
                          CASE 
                              WHEN DATEDIFF(DAY, d.ThoiGianNhanPhong, d.ThoiGianTraPhongDuKien) < 1 THEN 1
                              ELSE DATEDIFF(DAY, d.ThoiGianNhanPhong, d.ThoiGianTraPhongDuKien)
                          END
        FROM CT_DatPhong c
        INNER JOIN inserted d ON c.MaDP = d.MaDP
        WHERE d.ThoiGianNhanPhong IS NOT NULL 
          AND d.ThoiGianTraPhongDuKien IS NOT NULL;

        UPDATE dp
        SET dp.TongTienDuKien = t.TongTien
        FROM DatPhong dp
        INNER JOIN (
            SELECT MaDP, SUM(ThanhTien) AS TongTien
            FROM CT_DatPhong
            GROUP BY MaDP
        ) t ON dp.MaDP = t.MaDP
        INNER JOIN inserted d ON dp.MaDP = d.MaDP;
    END
END
GO

CREATE OR ALTER TRIGGER trg_Update_TongTienHoaDon_From_DatPhong
ON DatPhong
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE hd
    SET hd.TongTienDuKien = ISNULL(dp.TongTienDuKien, 0) 
                            + ISNULL(dv.TongTienDichVu, 0)
    FROM HoaDon hd
    INNER JOIN inserted i      ON hd.MaDP = i.MaDP
    INNER JOIN DatPhong dp     ON dp.MaDP = hd.MaDP
    OUTER APPLY (
        SELECT SUM(ctdv.SoLuong * ctdv.DonGia) AS TongTienDichVu
        FROM CT_DichVu ctdv
        WHERE ctdv.MaHD = hd.MaHD
    ) dv;
END
GO

CREATE OR ALTER TRIGGER trg_Update_TongTienHoaDon_From_CTDichVu
ON CT_DichVu
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ChangedHD AS (
        SELECT DISTINCT MaHD FROM inserted
        UNION
        SELECT DISTINCT MaHD FROM deleted
    )
    UPDATE hd
    SET hd.TongTienDuKien = ISNULL(dp.TongTienDuKien, 0)
                            + ISNULL(dv.TongTienDichVu, 0)
    FROM HoaDon hd
    INNER JOIN ChangedHD ch ON hd.MaHD = ch.MaHD
    INNER JOIN DatPhong dp  ON dp.MaDP = hd.MaDP
    OUTER APPLY (
        SELECT SUM(ctdv.SoLuong * ctdv.DonGia) AS TongTienDichVu
        FROM CT_DichVu ctdv
        WHERE ctdv.MaHD = hd.MaHD
    ) dv;
END
GO

UPDATE hd
SET hd.TongTienDuKien = ISNULL(dp.TongTienDuKien, 0)
                        + ISNULL(dv.TongTienDichVu, 0)
FROM HoaDon hd
INNER JOIN DatPhong dp ON dp.MaDP = hd.MaDP
OUTER APPLY (
    SELECT SUM(ctdv.SoLuong * ctdv.DonGia) AS TongTienDichVu
    FROM CT_DichVu ctdv
    WHERE ctdv.MaHD = hd.MaHD
) dv;
GO
----=====================================================
--Function, Procedure
--LOẠI PHÒNG
CREATE OR ALTER FUNCTION fn_LayTatCaLoaiPhong()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        MaLP, 
        TenLoai, 
        MoTa, 
        DonGia, 
        SucChua, 
        Anh
    FROM LoaiPhong
);
GO

-- Gọi thử:
--SELECT * FROM dbo.fn_LayTatCaLoaiPhong();

CREATE OR ALTER FUNCTION fn_LayThongTinLoaiPhong(@MaLP INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        MaLP, 
        TenLoai, 
        MoTa, 
        DonGia, 
        SucChua, 
        Anh
    FROM LoaiPhong
    WHERE MaLP = @MaLP
);
GO


--Sử dụng
--SELECT * FROM dbo.fn_LayThongTinLoaiPhong(1);

CREATE OR ALTER PROCEDURE sp_ThemLoaiPhong
    @TenLoai NVARCHAR(50),
    @MoTa NVARCHAR(200) = NULL,
    @DonGia DECIMAL(18,2),
    @SucChua INT,
    @Anh NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO LoaiPhong (TenLoai, MoTa, DonGia, SucChua, Anh)
    VALUES (@TenLoai, @MoTa, @DonGia, @SucChua, @Anh);
END;
GO

CREATE OR ALTER PROCEDURE sp_ChinhSuaLoaiPhong
    @MaLP INT,
    @TenLoai NVARCHAR(50),
    @MoTa NVARCHAR(200) = NULL,
    @DonGia DECIMAL(18,2),
    @SucChua INT,
    @Anh NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE LoaiPhong
    SET 
        TenLoai = @TenLoai,
        MoTa = @MoTa,
        DonGia = @DonGia,
        SucChua = @SucChua,
        Anh = @Anh
    WHERE MaLP = @MaLP;

    IF @@ROWCOUNT = 0
        RAISERROR(N'Không tìm thấy loại phòng có mã này.', 16, 1);
END;
GO


CREATE OR ALTER PROCEDURE sp_XoaLoaiPhong
    @MaLP INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM LoaiPhong WHERE MaLP = @MaLP)
    BEGIN
        DELETE FROM LoaiPhong WHERE MaLP = @MaLP;
    END
    ELSE
    BEGIN
        RAISERROR(N'Không tìm thấy loại phòng có mã này.', 16, 1);
    END
END;
GO

--Phòng
CREATE FUNCTION dbo.fn_LayTatCaPhong()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.MaPhong,
        p.SoPhong,
        p.ViTri,
        p.MoTa AS MoTaPhong,
        p.MaLP,
        lp.TenLoai,
        lp.MoTa AS MoTaLoai,
        lp.DonGia,
        p.TrangThai
    FROM Phong p
    INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
);
GO

-- Sử dụng
--SELECT * FROM dbo.fn_LayTatCaPhong();

CREATE FUNCTION fn_LayPhongTheoMa(@MaPhong INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.MaPhong,
        p.SoPhong,
        p.ViTri,
        p.MoTa,
        p.MaLP,
        lp.TenLoai,
        lp.DonGia,
        p.TrangThai
    FROM Phong p
    INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
    WHERE p.MaPhong = @MaPhong
);
GO

--SELECT * FROM dbo.fn_LayPhongTheoMa(1);

CREATE PROCEDURE sp_ChinhSuaPhong
    @MaPhong INT,
    @SoPhong NVARCHAR(10),
    @ViTri NVARCHAR(50),
    @MoTa NVARCHAR(200),
    @MaLP INT,
    @TrangThai NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Phong
    SET 
        SoPhong = @SoPhong,
        ViTri = @ViTri,
        MoTa = @MoTa,
        MaLP = @MaLP,
        TrangThai = @TrangThai
    WHERE MaPhong = @MaPhong;
END;
GO

CREATE PROCEDURE sp_XoaPhong
    @MaPhong INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Phong
    WHERE MaPhong = @MaPhong;
END;
GO

--Khách hàng
CREATE FUNCTION fn_LayTatCaKhachHang()
RETURNS TABLE
AS
RETURN
(
    SELECT MaKH, HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi
    FROM KhachHang
);
GO

--SELECT * FROM dbo.fn_LayTatCaKhachHang();

CREATE FUNCTION fn_LayKhachHangTheoMa(@MaKH INT)
RETURNS TABLE
AS
RETURN
(
    SELECT MaKH, HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi
    FROM KhachHang
    WHERE MaKH = @MaKH
);
GO

--SELECT * FROM dbo.fn_LayKhachHangTheoMa(1);

CREATE PROCEDURE sp_ThemKhachHang
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @SoDienThoai NVARCHAR(15),
    @Email NVARCHAR(100),
    @DiaChi NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO KhachHang (HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi)
    VALUES (@HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi);
END;
GO

CREATE PROCEDURE sp_ChinhSuaKhachHang
    @MaKH INT,
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @SoDienThoai NVARCHAR(15),
    @Email NVARCHAR(100),
    @DiaChi NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE KhachHang
    SET 
        HoTen = @HoTen,
        NgaySinh = @NgaySinh,
        GioiTinh = @GioiTinh,
        SoDienThoai = @SoDienThoai,
        Email = @Email,
        DiaChi = @DiaChi
    WHERE MaKH = @MaKH;
END;
GO

CREATE PROCEDURE sp_XoaKhachHang
    @MaKH INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM KhachHang
    WHERE MaKH = @MaKH;
END;
GO

--Nhân viên
CREATE FUNCTION fn_LayTatCaNhanVien()
RETURNS TABLE
AS
RETURN
(
    SELECT MaNV, HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi
    FROM NhanVien
);
GO

--SELECT * FROM dbo.fn_LayTatCaNhanVien();

CREATE FUNCTION fn_LayNhanVienTheoMa(@MaNV INT)
RETURNS TABLE
AS
RETURN
(
    SELECT MaNV, HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi
    FROM NhanVien
    WHERE MaNV = @MaNV
);
GO

--SELECT * FROM dbo.fn_LayNhanVienTheoMa(1);

CREATE PROCEDURE sp_ThemNhanVien
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @SoDienThoai NVARCHAR(15),
    @Email NVARCHAR(100),
    @DiaChi NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO NhanVien (HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi)
    VALUES (@HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi);
END;
GO

CREATE PROCEDURE sp_ChinhSuaNhanVien
    @MaNV INT,
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @SoDienThoai NVARCHAR(15),
    @Email NVARCHAR(100),
    @DiaChi NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE NhanVien
    SET 
        HoTen = @HoTen,
        NgaySinh = @NgaySinh,
        GioiTinh = @GioiTinh,
        SoDienThoai = @SoDienThoai,
        Email = @Email,
        DiaChi = @DiaChi
    WHERE MaNV = @MaNV;
END;
GO

CREATE PROCEDURE sp_XoaNhanVien
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM NhanVien
    WHERE MaNV = @MaNV;
END;
GO

--Đặt phòng

CREATE OR ALTER FUNCTION fn_XemTatCaDatPhong()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        dp.MaDP,
        dp.MaKH,
        kh.HoTen AS TenKH,
        kh.Email,
        kh.SoDienThoai,
        dp.NgayDat,
        dp.ThoiGianNhanPhong,
        dp.ThoiGianNhanPhongThucTe,
        dp.ThoiGianTraPhongDuKien,
        dp.ThoiGianTraPhongThucTe,
        dp.TinhTrang,
        dp.TongTienDuKien,
        dp.TrangThaiCoc,
        p.MaPhong,
        p.SoPhong,
        lp.TenLoai,
        lp.DonGia,
        ct.SoNgayO,
        ct.ThanhTien
    FROM DatPhong dp
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
    INNER JOIN CT_DatPhong ct ON dp.MaDP = ct.MaDP
    INNER JOIN Phong p ON ct.MaPhong = p.MaPhong
    INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
);
GO

CREATE FUNCTION fn_XemDatPhongTheoKH(@MaKH INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        dp.MaDP,
        dp.MaKH,
        dp.NgayDat,
        dp.ThoiGianNhanPhong,
        dp.ThoiGianTraPhongDuKien,
        dp.TinhTrang,
        dp.TongTienDuKien,
        dp.TrangThaiCoc,
        ctp.MaPhong,
        ctp.DonGia,
        ctp.SoNgayO,
        ctp.ThanhTien
    FROM DatPhong dp
    INNER JOIN CT_DatPhong ctp ON dp.MaDP = ctp.MaDP
    WHERE dp.MaKH = @MaKH
);
GO

--SELECT * FROM fn_XemDatPhongTheoKH(1);

CREATE FUNCTION fn_XemDatPhongTheoMaDP(@MaDP INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        dp.MaDP,
        dp.MaKH,
        kh.HoTen AS TenKH,
        dp.NgayDat,
        dp.ThoiGianNhanPhong,
        dp.ThoiGianTraPhongDuKien,
        dp.TinhTrang,
        dp.TongTienDuKien,
        dp.TrangThaiCoc,
        ctp.MaPhong,
        p.SoPhong,
        lp.TenLoai,
        ctp.DonGia,
        ctp.SoNgayO,
        ctp.ThanhTien
    FROM DatPhong dp
    INNER JOIN CT_DatPhong ctp ON dp.MaDP = ctp.MaDP
    INNER JOIN Phong p ON ctp.MaPhong = p.MaPhong
    INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
    WHERE dp.MaDP = @MaDP
);
GO

--SELECT * FROM fn_XemDatPhongTheoMaDP(1);

CREATE PROCEDURE sp_ThemDatPhong
    @MaKH INT,
    @NgayDat DATE,
    @ThoiGianNhanPhong DATETIME,
    @ThoiGianTraPhongDuKien DATETIME,
    @TinhTrang NVARCHAR(50),
    @TongTienDuKien DECIMAL(18,2),
    @TrangThaiCoc NVARCHAR(20)
AS
BEGIN
    INSERT INTO DatPhong (MaKH, NgayDat, ThoiGianNhanPhong, ThoiGianTraPhongDuKien, TinhTrang, TongTienDuKien, TrangThaiCoc)
    VALUES (@MaKH, @NgayDat, @ThoiGianNhanPhong, @ThoiGianTraPhongDuKien, @TinhTrang, @TongTienDuKien, @TrangThaiCoc);

    SELECT SCOPE_IDENTITY() AS MaDPMoi; 
END
GO

CREATE OR ALTER PROCEDURE sp_ChinhSuaDatPhong
    @MaDP INT,
    @ThoiGianNhanPhong DATETIME2 = NULL,
    @ThoiGianTraPhongDuKien DATETIME2 = NULL,
    @TinhTrang NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE DatPhong
    SET 
        ThoiGianNhanPhong = ISNULL(@ThoiGianNhanPhong, ThoiGianNhanPhong),
        ThoiGianTraPhongDuKien = ISNULL(@ThoiGianTraPhongDuKien, ThoiGianTraPhongDuKien),
        TinhTrang = ISNULL(@TinhTrang, TinhTrang)
    WHERE MaDP = @MaDP;

    PRINT N'Cập nhật đặt phòng thành công!';
END
GO

CREATE PROCEDURE sp_XoaDatPhong
    @MaDP INT
AS
BEGIN
    DELETE FROM CT_DatPhong WHERE MaDP = @MaDP;

    DELETE FROM DatPhong WHERE MaDP = @MaDP;
END
GO

CREATE PROCEDURE sp_ThemCTDatPhong
    @MaDP INT,
    @MaPhong INT,
    @DonGia DECIMAL(18,2),
    @SoNgayO INT
AS
BEGIN
    DECLARE @ThanhTien DECIMAL(18,2);
    SET @ThanhTien = @DonGia * @SoNgayO;

    INSERT INTO CT_DatPhong (MaDP, MaPhong, DonGia, SoNgayO, ThanhTien)
    VALUES (@MaDP, @MaPhong, @DonGia, @SoNgayO, @ThanhTien);
END
GO

CREATE PROCEDURE sp_ChinhSuaCTDatPhong
    @MaDP INT,
    @MaPhong INT,
    @DonGia DECIMAL(18,2),
    @SoNgayO INT
AS
BEGIN
    UPDATE CT_DatPhong
    SET DonGia = @DonGia,
        SoNgayO = @SoNgayO,
        ThanhTien = @DonGia * @SoNgayO
    WHERE MaDP = @MaDP AND MaPhong = @MaPhong;
END
GO

CREATE PROCEDURE sp_XoaCTDatPhong
    @MaDP INT,
    @MaPhong INT
AS
BEGIN
    DELETE FROM CT_DatPhong
    WHERE MaDP = @MaDP AND MaPhong = @MaPhong;
END
GO

--Dịch vụ
CREATE FUNCTION fn_LayTatCaDichVu()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        dv.MaDV,
        dv.TenDV,
        dv.DonGia AS DonGiaGoc,
        dv.MoTa,
        ct.MaHD,
        ct.MaPhong,
        ct.SoLuong,
        ct.DonGia AS DonGiaThucTe,
        ct.TrangThai
    FROM DichVu dv
    LEFT JOIN CT_DichVu ct ON dv.MaDV = ct.MaDV
);
GO

--Select * from fn_LayTatCaDichVu()

CREATE FUNCTION fn_LayDichVuTheoMa (@MaDV INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        dv.MaDV,
        dv.TenDV,
        dv.DonGia AS DonGiaGoc,
        dv.MoTa,
        ct.MaHD,
        ct.MaPhong,
        ct.SoLuong,
        ct.DonGia AS DonGiaThucTe,
        ct.TrangThai
    FROM DichVu dv
    LEFT JOIN CT_DichVu ct ON dv.MaDV = ct.MaDV
    WHERE dv.MaDV = @MaDV
);
GO

--Select * from fn_LayDichVuTheoMa(1)

CREATE PROCEDURE sp_ThemDichVu
    @TenDV NVARCHAR(100),
    @DonGia DECIMAL(18,2),
    @MoTa NVARCHAR(200) = NULL
AS
BEGIN
    INSERT INTO DichVu (TenDV, DonGia, MoTa)
    VALUES (@TenDV, @DonGia, @MoTa);
END;
GO

CREATE PROCEDURE sp_SuaDichVu
    @MaDV INT,
    @TenDV NVARCHAR(100),
    @DonGia DECIMAL(18,2),
    @MoTa NVARCHAR(200) = NULL
AS
BEGIN
    UPDATE DichVu
    SET TenDV = @TenDV,
        DonGia = @DonGia,
        MoTa = @MoTa
    WHERE MaDV = @MaDV;
END;
GO

CREATE PROCEDURE sp_XoaDichVu
    @MaDV INT
AS
BEGIN
    DELETE FROM CT_DichVu WHERE MaDV = @MaDV;
    DELETE FROM DichVu WHERE MaDV = @MaDV;
END;
GO

CREATE PROCEDURE sp_ThemCT_DichVu
    @MaHD INT,
    @MaPhong INT,
    @MaDV INT,
    @SoLuong INT,
    @DonGia DECIMAL(18,2),
    @TrangThai NVARCHAR(20)
AS
BEGIN
    INSERT INTO CT_DichVu (MaHD, MaPhong, MaDV, SoLuong, DonGia, TrangThai)
    VALUES (@MaHD, @MaPhong, @MaDV, @SoLuong, @DonGia, @TrangThai);
END;
GO

CREATE PROCEDURE sp_SuaCT_DichVu
    @MaHD INT,
    @MaPhong INT,
    @MaDV INT,
    @SoLuong INT,
    @DonGia DECIMAL(18,2),
    @TrangThai NVARCHAR(20)
AS
BEGIN
    UPDATE CT_DichVu
    SET SoLuong = @SoLuong,
        DonGia = @DonGia,
        TrangThai = @TrangThai
    WHERE MaHD = @MaHD AND MaPhong = @MaPhong AND MaDV = @MaDV;
END;
GO

CREATE PROCEDURE sp_XoaCT_DichVu
    @MaHD INT,
    @MaPhong INT,
    @MaDV INT
AS
BEGIN
    DELETE FROM CT_DichVu
    WHERE MaHD = @MaHD AND MaPhong = @MaPhong AND MaDV = @MaDV;
END;
GO

--Hoá đơn
CREATE OR ALTER FUNCTION dbo.fn_LayTatCaHoaDon()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        hd.MaHD,
        hd.MaDP,
        hd.NgayLap,
        hd.PTTT,
        hd.TrangThai,
        dp.MaKH,
        kh.HoTen,
        kh.SoDienThoai,
        hd.TongTienDuKien
    FROM HoaDon hd
    INNER JOIN DatPhong dp ON hd.MaDP = dp.MaDP
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
);
GO

CREATE OR ALTER PROCEDURE sp_LayHoaDonTheoMaHD
    @MaHD INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 🔹 Lấy thông tin hóa đơn, khách hàng, tổng tiền
    SELECT 
        hd.MaHD,
        hd.MaDP,
        hd.NgayLap,
        hd.PTTT,
        hd.TrangThai,
        kh.HoTen AS TenKhachHang,
        kh.SoDienThoai,
        dp.ThoiGianNhanPhongThucTe,
        dp.ThoiGianTraPhongThucTe,
        dp.TongTienDuKien AS TongTienPhong,
        ISNULL((
            SELECT SUM(SoLuong * DonGia)
            FROM CT_DichVu dv
            WHERE dv.MaHD = hd.MaHD
        ), 0) AS TongTienDichVu,
        dp.TongTienDuKien + ISNULL((
            SELECT SUM(SoLuong * DonGia)
            FROM CT_DichVu dv
            WHERE dv.MaHD = hd.MaHD
        ), 0) AS TongTienHoaDon
    FROM HoaDon hd
    INNER JOIN DatPhong dp ON hd.MaDP = dp.MaDP
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
    WHERE hd.MaHD = @MaHD;

    -- 🔹 Lấy chi tiết phòng
    SELECT 
        p.SoPhong,
        lp.TenLoai AS LoaiPhong,
        ct.SoNgayO,
        ct.DonGia,
        ct.ThanhTien
    FROM CT_DatPhong ct
    INNER JOIN Phong p ON ct.MaPhong = p.MaPhong
    INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
    INNER JOIN HoaDon hd ON hd.MaDP = ct.MaDP
    WHERE hd.MaHD = @MaHD;

    -- 🔹 Lấy chi tiết dịch vụ
    SELECT 
        dv.TenDV,
        ctdv.SoLuong,
        ctdv.DonGia,
        (ctdv.SoLuong * ctdv.DonGia) AS ThanhTien
    FROM CT_DichVu ctdv
    INNER JOIN DichVu dv ON ctdv.MaDV = dv.MaDV
    WHERE ctdv.MaHD = @MaHD;
END;
GO

CREATE OR ALTER PROCEDURE sp_TaoHoaDon
    @MaDP INT,
    @PTTT NVARCHAR(50),
    @TrangThai NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Kiểm tra mã đặt phòng có tồn tại không
        IF NOT EXISTS (SELECT 1 FROM DatPhong WHERE MaDP = @MaDP)
        BEGIN
            RAISERROR(N'Mã đặt phòng không tồn tại.', 16, 1);
            RETURN;
        END

        INSERT INTO HoaDon (MaDP, NgayLap, PTTT, TrangThai)
        VALUES (@MaDP, GETDATE(), @PTTT, @TrangThai);

        DECLARE @MaHD INT = SCOPE_IDENTITY();

        PRINT N'Tạo hóa đơn thành công. Mã hóa đơn: ' + CAST(@MaHD AS NVARCHAR);
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END
GO
CREATE OR ALTER FUNCTION fn_LayHoaDonTheoMaDP (@MaDP INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        hd.MaHD,
        hd.MaDP,
        hd.NgayLap,
        hd.PTTT,
        hd.TrangThai,
        dp.MaKH,
        kh.HoTen,
        kh.SoDienThoai,
        dp.TongTienDuKien
    FROM HoaDon hd
    INNER JOIN DatPhong dp ON hd.MaDP = dp.MaDP
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
    WHERE hd.MaDP = @MaDP
);
GO

CREATE OR ALTER FUNCTION fn_LayHoaDonTheoMaKH (@MaKH INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        hd.MaHD,
        hd.MaDP,
        hd.NgayLap,
        hd.PTTT,
        hd.TrangThai,
        dp.TongTienDuKien,
        kh.HoTen,
        kh.SoDienThoai
    FROM HoaDon hd
    INNER JOIN DatPhong dp ON hd.MaDP = dp.MaDP
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
    WHERE kh.MaKH = @MaKH
);
GO


CREATE OR ALTER PROCEDURE sp_ChinhSuaHoaDon
    @MaHD INT,
    @PTTT NVARCHAR(50) = NULL,
    @TrangThai NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM HoaDon WHERE MaHD = @MaHD)
        BEGIN
            RAISERROR(N'Mã hóa đơn không tồn tại.', 16, 1);
            RETURN;
        END

        UPDATE HoaDon
        SET 
            PTTT = ISNULL(@PTTT, PTTT),
            TrangThai = ISNULL(@TrangThai, TrangThai)
        WHERE MaHD = @MaHD;

        PRINT N'Cập nhật hóa đơn thành công.';
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END
GO

--Phiếu cọc
CREATE OR ALTER FUNCTION dbo.fn_LayTatCaPhieuCoc()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        pc.MaPC,
        pc.MaDP,
        kh.HoTen,
        kh.SoDienThoai,
        pc.NgayCoc,
        pc.SoTienCoc,
        pc.PTTT,
        dp.TrangThaiCoc
    FROM PhieuCoc pc
    INNER JOIN DatPhong dp ON pc.MaDP = dp.MaDP
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
);
GO

CREATE FUNCTION dbo.fn_LayPhieuCocTheoMaDP(@MaDP INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        pc.MaPC,
        pc.MaDP,
        pc.NgayCoc,
        pc.SoTienCoc,
        pc.PTTT
    FROM PhieuCoc pc
    WHERE pc.MaDP = @MaDP
);
GO

CREATE PROCEDURE sp_ThemPhieuCoc
    @MaDP INT,
    @NgayCoc DATE,
    @SoTienCoc DECIMAL(18,2),
    @PTTT NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PhieuCoc (MaDP, NgayCoc, SoTienCoc, PTTT)
    VALUES (@MaDP, @NgayCoc, @SoTienCoc, @PTTT);

    UPDATE DatPhong
    SET TrangThaiCoc = N'Đã cọc'
    WHERE MaDP = @MaDP;
END;
GO
--select * from phong

--Phục vụ
CREATE OR ALTER FUNCTION fn_LayThongTinPhucVuPhong
(
    @MaDP INT,
    @MaPhong INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        dp.MaDP,
        p.MaPhong,
        p.SoPhong,
        lp.TenLoai,
        kh.HoTen AS TenKH,
        kh.SoDienThoai,
        dp.ThoiGianNhanPhongThucTe,
        dp.ThoiGianTraPhongDuKien
    FROM DatPhong dp
    INNER JOIN CT_DatPhong ct ON dp.MaDP = ct.MaDP
    INNER JOIN Phong p ON ct.MaPhong = p.MaPhong
    INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
    INNER JOIN KhachHang kh ON dp.MaKH = kh.MaKH
    WHERE dp.MaDP = @MaDP AND p.MaPhong = @MaPhong
);
GO

-- Test:
-- SELECT * FROM fn_LayThongTinPhucVuPhong(1, 1);

CREATE OR ALTER FUNCTION fn_LayCT_DichVuTheoHoaDonPhong
(
    @MaHD INT,
    @MaPhong INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ctdv.MaHD,
        ctdv.MaPhong,
        ctdv.MaDV,
        dv.TenDV,
        ctdv.SoLuong,
        ctdv.DonGia,
        ctdv.TrangThai
    FROM CT_DichVu ctdv
    INNER JOIN DichVu dv ON ctdv.MaDV = dv.MaDV
    WHERE ctdv.MaHD = @MaHD
      AND ctdv.MaPhong = @MaPhong
);
GO

-- Test:
-- SELECT * FROM fn_LayCT_DichVuTheoHoaDonPhong(1, 1);

--------====================================================
--TRANG KHÁCH HÀNG
CREATE FUNCTION fn_LoaiPhongConPhongTrong
(
    @NgayBatDau DATETIME,
    @NgayTra DATETIME,
    @SoKhach INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT 
        lp.MaLP,
        lp.TenLoai,
        lp.MoTa,
        lp.DonGia,
        lp.SucChua,
        lp.Anh,
        COUNT(p.MaPhong) AS SoPhongTrong
    FROM LoaiPhong lp
    INNER JOIN Phong p ON lp.MaLP = p.MaLP
    WHERE 
        lp.SucChua >= @SoKhach
        AND p.TrangThai = N'Trống'
        AND NOT EXISTS (
            SELECT 1
            FROM DatPhong dp
            INNER JOIN CT_DatPhong ctdp ON dp.MaDP = ctdp.MaDP
            WHERE ctdp.MaPhong = p.MaPhong
              AND dp.TinhTrang NOT IN (N'Đã hủy', N'Hoàn tất')
              AND (
                    (@NgayBatDau BETWEEN dp.ThoiGianNhanPhong AND dp.ThoiGianTraPhongDuKien)
                    OR (@NgayTra BETWEEN dp.ThoiGianNhanPhong AND dp.ThoiGianTraPhongDuKien)
                    OR (dp.ThoiGianNhanPhong BETWEEN @NgayBatDau AND @NgayTra)
                    OR (dp.ThoiGianTraPhongDuKien BETWEEN @NgayBatDau AND @NgayTra)
                 )
        )
    GROUP BY 
        lp.MaLP, lp.TenLoai, lp.MoTa, lp.DonGia, lp.SucChua, lp.Anh
);
GO

CREATE FUNCTION dbo.fn_TimCacPhongTrongTheoMaLoai
(
    @MaLP INT,
    @NgayBatDau DATETIME,
    @NgayTra DATETIME
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.MaPhong,
        p.SoPhong,
        p.ViTri,
        p.MoTa AS MoTaPhong,
        p.MaLP,
        lp.TenLoai,
        lp.MoTa AS MoTaLoai,
        lp.DonGia,
        p.TrangThai
    FROM Phong p
    INNER JOIN LoaiPhong lp ON p.MaLP = lp.MaLP
    WHERE p.MaLP = @MaLP
      AND p.TrangThai = N'Trống'
      AND NOT EXISTS (
            SELECT 1
            FROM DatPhong dp
            INNER JOIN CT_DatPhong ctdp ON dp.MaDP = ctdp.MaDP
            WHERE ctdp.MaPhong = p.MaPhong
              AND dp.TrangThaiCoc = N'Đã cọc'   -- Sửa cột ở đây
              AND (
                    (@NgayBatDau BETWEEN dp.ThoiGianNhanPhong AND dp.ThoiGianTraPhongDuKien)
                 OR (@NgayTra BETWEEN dp.ThoiGianNhanPhong AND dp.ThoiGianTraPhongDuKien)
                 OR (dp.ThoiGianNhanPhong BETWEEN @NgayBatDau AND @NgayTra)
                 OR (dp.ThoiGianTraPhongDuKien BETWEEN @NgayBatDau AND @NgayTra)
              )
      )
);
GO
--select * from phong

CREATE PROCEDURE sp_LayLichSuDatPhong
    @MaKH INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        dp.MaDP,
        dp.NgayDat,
        dp.ThoiGianNhanPhong,
        dp.ThoiGianTraPhongDuKien,
        dp.TinhTrang,
        dp.TongTienDuKien,
        dp.TrangThaiCoc,
        ctdp.MaPhong,
        ctdp.DonGia,
        ctdp.SoNgayO,
        ctdp.ThanhTien,
        pc.MaPC,
        pc.NgayCoc,
        pc.SoTienCoc,
        pc.PTTT
    FROM DatPhong dp
    LEFT JOIN CT_DatPhong ctdp ON dp.MaDP = ctdp.MaDP
    LEFT JOIN PhieuCoc pc ON dp.MaDP = pc.MaDP
    WHERE dp.MaKH = @MaKH
    ORDER BY dp.NgayDat DESC, dp.MaDP DESC, ctdp.MaPhong;
END
GO

CREATE OR ALTER PROCEDURE sp_XacNhanCheckIn
    @MaDP INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DatPhong WHERE MaDP = @MaDP)
        BEGIN
            RAISERROR(N'Mã đặt phòng không tồn tại.', 16, 1);
            RETURN;
        END

        UPDATE DatPhong
        SET 
            TinhTrang = N'Đang ở',
            ThoiGianNhanPhongThucTe = GETDATE()
        WHERE MaDP = @MaDP;

        UPDATE p
        SET p.TrangThai = N'Đang sử dụng'
        FROM Phong p
        INNER JOIN CT_DatPhong ct ON p.MaPhong = ct.MaPhong
        WHERE ct.MaDP = @MaDP;

        IF NOT EXISTS (SELECT 1 FROM HoaDon WHERE MaDP = @MaDP)
        BEGIN
            INSERT INTO HoaDon (MaDP, NgayLap, PTTT, TrangThai)
            VALUES (@MaDP, GETDATE(), N'Tiền mặt', N'Đang ở');  
        END

        PRINT N'Check-in thành công cho đặt phòng ' + CAST(@MaDP AS NVARCHAR);
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_XacNhanCheckOut
    @MaDP INT,
    @PTTT NVARCHAR(50) = N'Tiền mặt'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DatPhong WHERE MaDP = @MaDP)
        BEGIN
            RAISERROR(N'Mã đặt phòng không tồn tại.', 16, 1);
            RETURN;
        END

        DECLARE 
            @TongTienPhong DECIMAL(18,2),
            @TongTienDichVu DECIMAL(18,2),
            @TongCoc DECIMAL(18,2),
            @TongHoaDon DECIMAL(18,2),
            @ConPhaiTra DECIMAL(18,2);

        SELECT @TongTienPhong = ISNULL(SUM(ThanhTien), 0)
        FROM CT_DatPhong
        WHERE MaDP = @MaDP;

        IF @TongTienPhong IS NULL OR @TongTienPhong = 0
        BEGIN
            SELECT @TongTienPhong = ISNULL(TongTienDuKien, 0)
            FROM DatPhong
            WHERE MaDP = @MaDP;
        END

        SELECT @TongTienDichVu = ISNULL(SUM(ctdv.SoLuong * ctdv.DonGia), 0)
        FROM CT_DichVu ctdv
        INNER JOIN HoaDon hd ON ctdv.MaHD = hd.MaHD
        WHERE hd.MaDP = @MaDP;

        SELECT @TongCoc = ISNULL(SUM(SoTienCoc), 0)
        FROM PhieuCoc
        WHERE MaDP = @MaDP;

        SET @TongHoaDon = ISNULL(@TongTienPhong,0) + ISNULL(@TongTienDichVu,0);
        SET @ConPhaiTra  = @TongHoaDon - ISNULL(@TongCoc,0);
        IF @ConPhaiTra < 0 SET @ConPhaiTra = 0;

        UPDATE DatPhong
        SET 
            TinhTrang = N'Hoàn tất',
            ThoiGianTraPhongThucTe = GETDATE(),
            TongTienDuKien = @TongTienPhong 
        WHERE MaDP = @MaDP;

        UPDATE p
        SET p.TrangThai = N'Trống'
        FROM Phong p
        INNER JOIN CT_DatPhong ct ON p.MaPhong = ct.MaPhong
        WHERE ct.MaDP = @MaDP;

        UPDATE HoaDon
        SET 
            PTTT = @PTTT,
            TrangThai = N'Đã thanh toán'
        WHERE MaDP = @MaDP;

        PRINT N'Check-out thành công. Tổng phòng: ' + CAST(@TongTienPhong AS NVARCHAR(20)) +
              N', DV: ' + CAST(@TongTienDichVu AS NVARCHAR(20)) +
              N', Đã cọc: ' + CAST(@TongCoc AS NVARCHAR(20)) +
              N', Còn phải trả: ' + CAST(@ConPhaiTra AS NVARCHAR(20));
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END
GO
--=============================================================================
-- 1. Tạo ROLE 
USE DB_KhachSan;
GO

USE DB_KhachSan;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rl_KhachHang')
    CREATE ROLE rl_KhachHang;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rl_NhanVien')
    CREATE ROLE rl_NhanVien;
GO

REVOKE SELECT, INSERT, UPDATE, DELETE ON DATABASE::DB_KhachSan FROM rl_KhachHang;
REVOKE CONTROL, ALTER, TAKE OWNERSHIP FROM rl_KhachHang;
REVOKE EXECUTE TO rl_KhachHang;

REVOKE SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo FROM rl_KhachHang;
GO
--------------------------------------------------
-- 2. PHÂN QUYỀN CHO ROLE KHÁCH HÀNG
--------------------------------------------------
USE DB_KhachSan;
GO

GRANT SELECT ON dbo.LoaiPhong TO rl_KhachHang;
GRANT SELECT ON dbo.Phong     TO rl_KhachHang;
GRANT SELECT ON dbo.DichVu    TO rl_KhachHang;

GRANT SELECT ON OBJECT::dbo.fn_LoaiPhongConPhongTrong TO rl_KhachHang;
GRANT SELECT ON OBJECT::dbo.fn_TimCacPhongTrongTheoMaLoai TO rl_KhachHang;

GRANT SELECT ON OBJECT::dbo.fn_XemDatPhongTheoKH TO rl_KhachHang;
GRANT EXEC   ON dbo.sp_LayLichSuDatPhong         TO rl_KhachHang;

GRANT EXEC ON dbo.sp_ThemDatPhong   TO rl_KhachHang;
GRANT EXEC ON dbo.sp_ThemCTDatPhong TO rl_KhachHang;

DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rl_KhachHang;
GO
--------------------------------------------------
-- 3. PHÂN QUYỀN CHO ROLE NHÂN VIÊN
--------------------------------------------------
USE DB_KhachSan;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rl_NhanVien;

GRANT EXEC ON SCHEMA::dbo TO rl_NhanVien;
GO

--------------------------------------------------
-- 4. GÁN USER THỰC TẾ VÀO ROLE (ví dụ minh họa)
--------------------------------------------------
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'an_user')
    CREATE LOGIN [an_user] WITH PASSWORD = '123456';

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'lan_admin')
    CREATE LOGIN [lan_admin] WITH PASSWORD = 'admin123';
GO

USE DB_KhachSan;
GO

CREATE USER [an_user] FOR LOGIN [an_user];
CREATE USER [lan_admin] FOR LOGIN [lan_admin];

EXEC sp_addrolemember 'rl_KhachHang', 'an_user';
EXEC sp_addrolemember 'rl_NhanVien',  'lan_admin';
GO
--=============================================================================
--Đăng ký tài khoản
CREATE OR ALTER PROCEDURE sp_DangKyTaiKhoanSQL
    @HoTen NVARCHAR(100),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @SoDienThoai NVARCHAR(15),
    @Email NVARCHAR(100),
    @DiaChi NVARCHAR(200),
    @TenDN NVARCHAR(50),
    @MatKhau NVARCHAR(255),
    @LoaiTaiKhoan NVARCHAR(10) = 'KH',  
    @MaTKMoi INT OUTPUT,
    @ErrorMessage NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @ErrorMessage = NULL;
    SET @MaTKMoi = NULL;

    DECLARE @LoginCreated BIT = 0;
    DECLARE @UserCreated BIT = 0;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Kiểm tra tên đăng nhập
        IF EXISTS (SELECT 1 FROM TaiKhoan WHERE TenDN = @TenDN)
        BEGIN
            SET @ErrorMessage = 'Tên đăng nhập đã tồn tại trong hệ thống.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Kiểm tra login SQL server
        IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @TenDN)
        BEGIN
            SET @ErrorMessage = 'Login SQL Server đã tồn tại.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Kiểm tra trùng email / SĐT
        IF EXISTS (SELECT 1 FROM KhachHang WHERE Email = @Email)
        BEGIN
            SET @ErrorMessage = 'Email đã được sử dụng.';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM KhachHang WHERE SoDienThoai = @SoDienThoai)
        BEGIN
            SET @ErrorMessage = 'Số điện thoại đã được sử dụng.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @MaKH INT = NULL;

        -- Nếu là khách hàng → thêm vào bảng KhachHang
        IF @LoaiTaiKhoan = 'KH'
        BEGIN
            INSERT INTO KhachHang (HoTen, NgaySinh, GioiTinh, SoDienThoai, Email, DiaChi)
            VALUES (@HoTen, @NgaySinh, @GioiTinh, @SoDienThoai, @Email, @DiaChi);

            SET @MaKH = SCOPE_IDENTITY();
        END

        -- Tạo login SQL
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = N'CREATE LOGIN [' + @TenDN + '] 
                     WITH PASSWORD = N''' + @MatKhau + ''';';
        EXEC (@SQL);
        SET @LoginCreated = 1;


        -- Tạo user trong database hiện tại
        SET @SQL = N'CREATE USER [' + @TenDN + '] FOR LOGIN [' + @TenDN + '];';
        EXEC (@SQL);
        SET @UserCreated = 1;


        -- Gán role nếu là KH
        IF @LoaiTaiKhoan = 'KH'
        BEGIN
            EXEC sp_addrolemember 'rl_KhachHang', @TenDN;
        END


        -- Thêm vào bảng TaiKhoan
        INSERT INTO TaiKhoan (TenDN, MatKhau, QuyenHan, LoaiTaiKhoan, MaKH)
        VALUES (@TenDN, @MatKhau, 'USER', @LoaiTaiKhoan, @MaKH);

        SET @MaTKMoi = SCOPE_IDENTITY();


        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        SET @ErrorMessage = ERROR_MESSAGE();

        -- ROLLBACK
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Xóa login nếu đã tạo
        IF @LoginCreated = 1
        BEGIN
            DECLARE @SQL2 NVARCHAR(MAX);
            SET @SQL2 = N'DROP LOGIN [' + @TenDN + '];';
            EXEC (@SQL2);
        END

        -- Xóa user DB nếu đã tạo
        IF @UserCreated = 1
        BEGIN
            DECLARE @SQL3 NVARCHAR(MAX);
            SET @SQL3 = N'DROP USER [' + @TenDN + '];';
            EXEC (@SQL3);
        END

    END CATCH
END
GO

--Mẫu test
INSERT INTO DatPhong (
    MaKH, NgayDat, 
    ThoiGianNhanPhong, ThoiGianNhanPhongThucTe, 
    ThoiGianTraPhongDuKien, ThoiGianTraPhongThucTe, 
    TinhTrang, TongTienDuKien, TrangThaiCoc
)
VALUES
(1, '2025-11-01', '2025-11-05 14:00', NULL, '2025-11-07 12:00', NULL, N'Chờ xác nhận', 800000, N'Đã cọc'),
(2, '2025-11-02', '2025-11-06 15:00', NULL, '2025-11-08 11:00', NULL, N'Chờ xác nhận', 1400000, N'Đã cọc'),
(3, '2025-11-03', '2025-11-10 14:00', NULL, '2025-11-12 12:00', NULL, N'Chờ xác nhận', 2400000, N'Đã cọc'),
(4, '2025-11-04', '2025-11-15 13:00', NULL, '2025-11-18 11:00', NULL, N'Chờ xác nhận', 1200000, N'Đã cọc'),
(5, '2025-11-05', '2025-11-20 16:00', NULL, '2025-11-22 12:00', NULL, N'Chờ xác nhận', 700000, N'Đã cọc');
GO

INSERT INTO CT_DatPhong (MaDP, MaPhong, DonGia, SoNgayO, ThanhTien) VALUES
(5, 1, 400000, 2, 800000),
(6, 3, 700000, 2, 1400000),
(7, 5, 1200000, 2, 2400000),
(8, 2, 400000, 3, 1200000),
(9, 3, 700000, 1, 700000);
GO


select * from DatPhong