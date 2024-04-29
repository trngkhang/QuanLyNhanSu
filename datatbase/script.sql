USE master;
GO
-- drop database QuanLyNhanVien
-- Tao co so du lieu
CREATE DATABASE QuanLyNhanVien;
GO

-- Su dung co so du lieu vua tao
USE QuanLyNhanVien;
GO

-- Tao bang thong tin nhan vien
CREATE TABLE NHANVIEN (
    MaNV VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100),
    Phai NVARCHAR(3),
    NgaySinh DATE,
    SoDienThoai VARCHAR(15),
    Luong VARBINARY(max),
    PhuCap VARBINARY(max),
    MaSoThue VARCHAR(20),
    MaPhong VARCHAR(10),
	MatKhau VARBINARY(max),
	ChucVu VARCHAR(50),
);

-- Tao bang thong tin phong ban
CREATE TABLE PHONGBAN (
    MaPhong VARCHAR(10) PRIMARY KEY,
    TenPhong NVARCHAR(100),
    TruongPhong VARCHAR(10)
);
GO

-- Them rang buoc khoa ngoai
ALTER TABLE NHANVIEN ADD CONSTRAINT FK_NHANVIEN_PHONGBAN
FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong);
GO
ALTER TABLE PHONGBAN ADD CONSTRAINT PHONGBAN_NHANVIEN
FOREIGN KEY (TruongPhong) REFERENCES NHANVIEN(MaNV);
GO

insert into PHONGBAN(MaPhong, TenPhong, TruongPhong)
values ('GiamDoc',N'Phòng giám đốc', null)


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
			SELECT 'Successful' AS message, @MaNV_dn as maNV
		END
		ELSE
		BEGIN
			SELECT 'Failure' AS message;
		END
END
GO

execute SP_DangNhapTaiKhoanQuanTri 'admin', '123456'
GO


-- drop proc SP_IN_NHANVIEN

create proc SP_IN_NHANVIEN
    @MaNV VARCHAR(10),
    @HoTen NVARCHAR(100),
    @Phai NVARCHAR(3),
    @NgaySinh DATE,
    @SoDienThoai VARCHAR(15),
    @Luong INT,
    @PhuCap INT,
    @MaSoThue VARCHAR(20),
    @MaPhong VARCHAR(10),
	@MatKhau VARCHAR(20),
	@ChucVu VARCHAR(50)
as
begin
	declare @MatKhau_encrypted  VARBINARY(max)
	declare @Luong_encrypted VARBINARY(max)
	declare @PhuCap_encrypted VARBINARY(max)

	set @MatKhau_encrypted  = HASHBYTES('SHA1',@MatKhau)

    CREATE SYMMETRIC KEY SK_NHANVIEN
    WITH algorithm = AES_256
    ENCRYPTION BY PASSWORD = 'nhom6';

    OPEN SYMMETRIC KEY SK_NHANVIEN
    DECRYPTION BY PASSWORD = 'nhom6';
		SET @Luong_encrypted= ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'),cast(@Luong as varchar))
		SET @PhuCap_encrypted= ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'),cast(@PhuCap as varchar))
    CLOSE SYMMETRIC KEY SK_NHANVIEN;

	INSERT INTO NHANVIEN(MaNV, HoTen, Phai, NgaySinh, SoDienThoai, Luong, PhuCap, MaSoThue, MaPhong, MatKhau, ChucVu)
	VALUES (@MaNV, @HoTen, @Phai, @NgaySinh, @SoDienThoai, @Luong_encrypted, @PhuCap_encrypted, @MaSoThue, @MaPhong, @MatKhau_encrypted, @ChucVu)
END
GO

execute SP_IN_NHANVIEN 'NV0001', N'Trần Nguyên Khang', N'Nam', '09-28-2003', '0123456789', 25000000, 3000000, '0123456789', 'GiamDoc', '123456','GiamDocRole'

--dang nhap
-- drop proc SP_SE_NHANVIENDANGNHAP
create proc SP_SE_NHANVIENDANGNHAP
	@MaNV VARCHAR(10),
	@MatKhau VARCHAR(20),
	@ChucVu VARCHAR(50)
as
begin
    if exists(select MaNV from NHANVIEN where MaNV=@MaNV and ChucVu=@ChucVu and MatKhau= HASHBYTES('SHA1',@MatKhau))
		begin
			--trả về MaNV và CHucVu
			SELECT 'ThanhCong' as DangNhap ;select @MaNV AS MaNV, @ChucVu AS ChucVu;
		end
		else
		begin
			select 'ThatBai' as Message;
		end
end

execute SP_SE_NHANVIENDANGNHAP 'NV0001', '123456', 'GiamDocRole'