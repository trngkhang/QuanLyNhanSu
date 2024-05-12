USE master;
GO

-- drop database QuanLyNhanSu2
-- Tao co so du lieu
CREATE DATABASE QuanLyNhanSu2;
GO

-- Su dung co so du lieu vua tao
USE QuanLyNhanSu2;
GO

-- Tao bang thong tin nhan vien
CREATE TABLE NHANVIEN (
    MaNV int IDENTITY(100000,1) PRIMARY KEY,
    HoTen NVARCHAR(100),
    Phai NVARCHAR(3),
    NgaySinh DATE,
    SoDienThoai VARCHAR(15),
    Luong VARBINARY(max),
    PhuCap VARBINARY(max),
    MaSoThue VARCHAR(20),
	MaChV int,
    MaPhong int,
);
GO

-- tao bang tai khoan
CREATE TABLE TAIKHOAN(
	MaNV int,
	MatKhau VARBINARY(max),
);
GO

-- Tao bang thong tin phong ban
CREATE TABLE PHONGBAN (
    MaPhong int IDENTITY(100,1) PRIMARY KEY,
    TenPhong NVARCHAR(100),
    TruongPhong int
);
GO

-- tao bang chuc vu
CREATE TABLE CHUCVU(
	MaChV INT IDENTITY(100,1) PRIMARY KEY,
	TenChV NVARCHAR(100),
);
GO

-- Them rang buoc khoa ngoai
ALTER TABLE NHANVIEN ADD CONSTRAINT FK_NHANVIEN_PHONGBAN
FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong);
GO

ALTER TABLE NHANVIEN ADD CONSTRAINT NHANVIEN_CHUCVU
FOREIGN KEY (MaCHV) REFERENCES CHUCVU(MaCHV);
GO

ALTER TABLE PHONGBAN ADD CONSTRAINT PHONGBAN_NHANVIEN
FOREIGN KEY (TruongPhong) REFERENCES NHANVIEN(MaNV);
GO

ALTER TABLE TAIKHOAN ADD CONSTRAINT FK_TAIKHOAN_NHANVIEN
FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV);
GO

insert into NHANVIEN(HoTen, Phai, NgaySinh, SoDienThoai, MaSoThue) values
( N'Đoàn Văn Hậu', N'Nam', '03-12-1999', '0123456789', '0123456789'),
( N'Bùi Tấn Trường', N'Nam', '01-16-1995', '0123456789', '0123456789')

go
-- select * from NHANVIEN

insert into TAIKHOAN(MaNV) values
( 100000 ),
( 100001 )

go
--select * from TAIKHOAN

insert into PHONGBAN( TenPhong, TruongPhong) values
(N'Phòng giám đốc', null),
(N'Phòng nhân sự', null),
(N'Phòng Tài vụ', null),
(N'Phòng IT',null)

Go
-- select * from PHONGBAN

insert into CHUCVU(TenChV) values
(N'Giám đốc'),
(N'Trưởng phòng nhân sự'),
(N'Nhân viên phòng nhân sự')

Go
-- select * from CHUCVU
--tao các Role

--role dung de dang nhap vao cac tai khoan

create login QLNS_login with password='QLNS_login';
go

CREATE USER QLNS_login FOR LOGIN QLNS_login 
GO

-- gan quyen chi xem table TAIKHOAN cho viec dang nhap
GRANT SELECT ON TAIKHOAN TO QLNS_login
GO
-- Cấp quyền IMPERSONATE cho người dùng (login nguoi dung khac)
GRANT IMPERSONATE ANY LOGIN TO QLNS_login;

-- execute as login = 'QLNS_login' ;
go
revert;
go

-- xem user dang dang nhap hien tai
SELECT * FROM sys.dm_exec_sessions WHERE is_user_process = 1;


