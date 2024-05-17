USE master;
GO
-- CREATE LOGIN được sử dụng để tạo một người dùng mới (login) trên cấp đăng nhập của SQL Server.
CREATE LOGIN LOGIN_DB_QUANLYNHANSU WITH PASSWORD = '123456'

-- drop database QUANLYNHANSU
-- Tao co so du lieu
CREATE DATABASE QUANLYNHANSU;
GO

-- Su dung co so du lieu vua tao
USE QUANLYNHANSU;
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
GO
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

insert into PHONGBAN(MaPhong, TenPhong, TruongPhong) values
('GiamDoc',N'Phòng giám đốc', null),
('NhanSu',N'Phòng nhân sự', null),
('TaiVu',N'Phòng Tài vụ', null),
('IT', N'Phòng IT',null)

-- Tạo các role
CREATE ROLE NhanVienRole;
CREATE ROLE TruongPhongRole;
CREATE ROLE NhanVienNhanSuRole;
CREATE ROLE TruongPhongNhanSuRole;
CREATE ROLE NhanVienTaiVuRole;
CREATE ROLE GiamDocRole;

-- Gán các quyền cho các role

--NhanVienRole
create view ViewNhanVienRole as
	select 	NV.MaNV, NV.HoTen, NV.Phai, NV.NgaySinh, NV.SoDienThoai, NV.MaSoThue, NV.MaPhong, NV.MatKhau, NV.ChucVu
	from NHANVIEN NV JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong;
GO
GRANT SELECT ON ViewNhanVienRole TO NhanVienRole;

-- TruongPhongRole
--da xac dinh la truong phong truoc do moi gan quyen TruongPhongRole
CREATE VIEW ViewTruongPhongRole AS
SELECT *
FROM NHANVIEN NV
WHERE NOT EXISTS (
    SELECT 1
    FROM PHONGBAN PB
    WHERE NV.MaPhong = PB.MaPhong AND NV.MaNV = PB.TruongPhong
);
 GO
GRANT SELECT ON ViewNhanVienRole TO TruongPhongRole;

-- NhanVienNhanSuRole
create view ViewNhanVienNhanSuRole as
	select *
	from NHANVIEN NV where NV.MaPhong!= 
GRANT SELECT, INSERT, UPDATE, DELETE ON NHANSU TO NhanVienNhanSuRole;
GRANT SELECT, UPDATE (Luong, PhuCap) ON NHANSU TO TruongPhongNhanSuRole;
GRANT SELECT ON NHANSU (MaNV, Luong, PhuCap, MaSoThue) TO NhanVienTaiVuRole;
GRANT SELECT, UPDATE (Luong, PhuCap) ON NHANSU TO GiamDocRole;




--GRANT CONTROL TO LOGIN_DB_QUANLYNHANSU;

-- CREATE USER được sử dụng để tạo một người dùng mới trong một CƠ SỞ DỮ LIỆU cụ thể trong SQL Server.
create login NV0001 with password = '123456'
create user NV0001 for login NV0001
ALTER ROLE NhanVienRole ADD MEMBER NV0001;
-- ======================================================
-- ------------------Truy Van----------------------------
-- ======================================================


-- tao khoa cho SP_IN_NHANVIEN
CREATE SYMMETRIC KEY SK_NHANVIEN
WITH algorithm = AES_256
ENCRYPTION BY PASSWORD = 'nhom6';
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
	begin try
		BEGIN TRANSACTION; -- Bắt đầu transaction

		declare @MatKhau_encrypted  VARBINARY(max)
		declare @Luong_encrypted VARBINARY(max)
		declare @PhuCap_encrypted VARBINARY(max)
	
		set @MatKhau_encrypted  = HASHBYTES('SHA1',@MatKhau)

	    OPEN SYMMETRIC KEY SK_NHANVIEN
	    DECRYPTION BY PASSWORD = 'nhom6';
		SET @Luong_encrypted= ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'),cast(@Luong as varchar))
		SET @PhuCap_encrypted= ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'),cast(@PhuCap as varchar))
	    CLOSE SYMMETRIC KEY SK_NHANVIEN;

		INSERT INTO NHANVIEN(MaNV, HoTen, Phai, NgaySinh, SoDienThoai, Luong, PhuCap, MaSoThue, MaPhong, MatKhau, ChucVu)
		VALUES (@MaNV, @HoTen, @Phai, @NgaySinh, @SoDienThoai, @Luong_encrypted, @PhuCap_encrypted, @MaSoThue, @MaPhong, @MatKhau_encrypted, @ChucVu)

		select 'ThanhCong' as TruyVan -- tra ve

		COMMIT; -- Áp dụng transaction
	end try
	begin catch
		IF @@TRANCOUNT > 0
			ROLLBACK; -- Hủy bỏ transaction nếu có lỗi
		select 'ThatBai' as TruyVan, ERROR_MESSAGE() as ThongBao --tra ve 

	end catch
END
GO

execute SP_IN_NHANVIEN 'NV0001', N'Trần Nguyên Khang', N'Nam', '09-28-2003', '0123456789', 25000000, 3000000, '0123456789', 'GiamDoc', '123456','GiamDocRole'
execute SP_IN_NHANVIEN 'NV0002', N'Đoàn Văn Hậu', N'Nam', '03-12-1999', '0123456789',20000000,4000000, '0123456789', 'NhanSu', '123456','TruongPhongNhanSuRole'
execute SP_IN_NHANVIEN 'NV0003', N'Bùi Tấn Trường', N'Nam', '01-16-1995', '0123456789', 16000000, 2000000, '0123456789', 'TaiVu', '123456','NhanVienTaiVuRole'
execute SP_IN_NHANVIEN 'NV0004', N'Nguyễn Văn Toản', N'Nam', '03-12-1999', '0123456789', 19000000, 2400000, '0123456789', 'NhanSu', '123456','NhanVienNhanSuRole'
execute SP_IN_NHANVIEN 'NV0005', N'Đỗ Duy Mạnh', N'Nam', '06-05-1997', '0123456789', 18000000, 3000000, '0123456789', 'TaiVu', '123456','GiamDocRole'
execute SP_IN_NHANVIEN 'NV0006', N'Trần Đình Trọng', N'Nam', '03-27-1998', '0123456789', 25000000, 3000000, '0123456789', 'GiamDoc', '123456','TruongPhongRole'

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
			--trả về Thong tin nhan vien
			SELECT 'ThanhCong' as TruyVan ;select MaNV, HoTen, ChucVu from NHANVIEN where MaNV=@MaNV;
		end
		else
		begin
			select 'ThatBai' as TruyVan;
		end
end
GO
execute SP_SE_NHANVIENDANGNHAP 'NV0001', '123456', 'GiamDocRole'

--Dang xuat
-- drop proc SP_SE_NHANVIENDANGXUAT
create proc SP_SE_NHANVIENDANGXUAT
	MaNV VARCHAR(10)
as
begin
		begin try
			
		end try
		begin catch

		end catch
end
