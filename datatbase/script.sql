USE master;
GO

-- Tao co so du lieu
CREATE DATABASE QuanLyNhanVien;
GO

-- Su dung co so du lieu vua tao
USE QuanLyNhanVien;
GO

-- Tao bang thong tin nhan vien
CREATE TABLE NhanVien (
    MaNV VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100),
    Phai NVARCHAR(3),
    NgaySinh DATE,
    SoDienThoai VARCHAR(15),
    Luong INT,
    PhuCap INT,
    MaSoThue VARCHAR(20),
    MaPhong VARCHAR(10),
	MatKhau VARBINARY(max) not null,
	Role VARCHAR(50),
);

-- Tao bang thong tin phong ban
CREATE TABLE PhongBan (
    MaPhong VARCHAR(10) PRIMARY KEY,
    TenPhong NVARCHAR(100),
    TruongPhong VARCHAR(10)
);
GO
CREATE TABLE TaiKhoanQuanTri (
    MaNV VARCHAR(10) PRIMARY KEY,
	MatKhau VARCHAR(50),
	Role VARCHAR(50),
);
GO

--Tao bang Users va Roles
-- CREATE TABLE TaiKhoan (
--     TenDangNhap VARCHAR(10) PRIMARY KEY,
--     MatKhau VARCHAR(50),
--     Role VARCHAR(50),
-- 	IsAdmin BIT NOT NULL DEFAULT 0,
-- );

-- Them rang buoc khoa ngoai
ALTER TABLE NhanVien ADD CONSTRAINT FK_NhanVIen_PhongBan
FOREIGN KEY (MaPhong) REFERENCES PhongBan(MaPhong);
GO
ALTER TABLE PhongBan ADD CONSTRAINT PhongBan_NhanVien
FOREIGN KEY (TruongPhong) REFERENCES NhanVien(MaNV);
GO
-- ALTER TABLE TaiKhoan ADD CONSTRAINT FK_TaiKhooan_NhanVien
-- FOREIGN KEY (TenDangNhap) REFERENCES NhanVien(MaNV);
-- GO

insert NhanVien(MaNV) values ('admin')


-- ======================================================
-- ------------------Truy Van----------------------------
-- ======================================================

--tao tai khoan admin(quan tri he thong)
CREATE PROC SP_IN_QuanTriTaiKhoan
	@MaNV varchar(10),
	@MatKhau varchar(20)
as
begin
	declare @encore_MatKhau varbinary(max)

	set @encore_MatKhau = HASHBYTES('SHA1',@MatKhau)

	insert into TaiKhoanQuanTri(MaNV,MatKhau, Role)
	values (@MaNV, @encore_MatKhau,'QuanTriTaiKhoanRole')
end

execute SP_IN_QuanTriTaiKhoan 'admin', '123456'


-- dang nhap tai khoan quan tri
-- drop PROCEDURE SP_DangNhapTaiKhoanQuanTri
CREATE PROCEDURE SP_DangNhapTaiKhoanQuanTri
	@MaNV_dn varchar(10),
	@MatKhau_dn varchar(20)
AS
BEGIN
    DECLARE @MaNV_kq varchar(10);
    -- Kiểm tra xem thông tin đăng nhập có hợp lệ không
    if exists(SELECT MaNV
    FROM TaiKhoanQuanTri
    WHERE MaNV = @MaNV_dn AND MatKhau = HASHBYTES('SHA1',@MatKhau_dn))
		BEGIN
			SELECT 'Successful' AS message
		END
		ELSE
		BEGIN
			SELECT 'Failure' AS message;
		END
END
GO

execute SP_DangNhapTaiKhoanQuanTri 'admin', '123456'
GO