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

);

-- Tao bang thong tin phong ban
CREATE TABLE PhongBan (
    MaPhong VARCHAR(10) PRIMARY KEY,
    TenPhong NVARCHAR(100),
    TruongPhong VARCHAR(10)
);
GO

--Tao bang Users va Roles
CREATE TABLE TaiKhoan (
    TenDangNhap VARCHAR(10) PRIMARY KEY,
    MatKhau VARCHAR(50),
    Role VARCHAR(50),
	IsAdmin BIT NOT NULL DEFAULT 0,
);

-- Them rang buoc khoa ngoai
ALTER TABLE NhanVien ADD CONSTRAINT FK_NhanVIen_PhongBan
FOREIGN KEY (MaPhong) REFERENCES PhongBan(MaPhong);
GO
ALTER TABLE PhongBan ADD CONSTRAINT PhongBan_NhanVien
FOREIGN KEY (TruongPhong) REFERENCES NhanVien(MaNV);
GO
ALTER TABLE TaiKhoan ADD CONSTRAINT FK_TaiKhooan_NhanVien
FOREIGN KEY (TenDangNhap) REFERENCES NhanVien(MaNV);
GO