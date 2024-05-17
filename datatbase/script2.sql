USE master;
GO

-- drop database QuanLyNhanSu3
-- Tao co so du lieu
CREATE DATABASE QLNS;
GO

-- Su dung co so du lieu vua tao
USE QLNS;
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
-- select * from TAIKHOAN

insert into PHONGBAN(TenPhong) values
(N'Phòng nhân sự'),
(N'Phòng tài vụ'),
(N'Phòng giám đốc')
 
Go
-- select * from PHONGBAN

insert into CHUCVU(TenChV) values
(N'Nhân viên'),
(N'Trưởng phòng'),
(N'Giám đốc')

Go
-- select * from CHUCVU
--tao các Role

--role dung de dang nhap vao cac tai khoan
-- 1 login chỉ có 1 user
create login QLNS_login with password='QLNS_login';
go

CREATE USER QLNS_login FOR LOGIN QLNS_login
GO

-- gan quyen chi xem table TAIKHOAN cho viec dang nhap
GRANT SELECT ON TAIKHOAN TO QLNS_login
GO
-- Cấp quyền IMPERSONATE cho người dùng (login nguoi dung khac)
GRANT IMPERSONATE ANY LOGIN TO QLNS_login;
GRANT SELECT ON QuanLyNhanSu4.TAIKHOAN TO QLNS_login;
--GRANT EXECUTE ON dn TO QLNS_login;
-- execute as user = '100003' ;
-- execute as login = 'QLNS_login' ;

go
revert;
go

-- xem user dang dang nhap hien tai
SELECT * FROM sys.dm_exec_sessions WHERE is_user_process = 1;


-- dang nhap
-- drop proc SP_SE_NHANVIENDANGNHAP
CREATE PROCEDURE SP_SE_NHANVIENDANGNHAP
    @MaNV VARCHAR(10),
    @MatKhau VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

        DECLARE @TruyVan NVARCHAR(50);
        DECLARE @ThongBao NVARCHAR(100);

        IF EXISTS(SELECT MaNV FROM TAIKHOAN WHERE MaNV = @MaNV AND MatKhau = HASHBYTES('SHA2_512', @MatKhau))
        BEGIN
            -- Truy cập với quyền của nhân viên
            --EXECUTE AS USER = CAST(@MaNV AS VARCHAR);
            -- Lưu thông tin đăng nhập
            SET @TruyVan = 'ThanhCong';
            SET @ThongBao = @MaNV;
        END
        ELSE
        BEGIN
            SET @TruyVan = 'ThatBai';
            SET @ThongBao = N'Sai tài khoản hoặc mật khẩu';
        END

        SELECT @TruyVan AS TruyVan, @ThongBao AS MaNV; -- Trả về kết quả

        COMMIT TRANSACTION; -- Áp dụng transaction
    END TRY
    BEGIN CATCH
            ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- Trả về lỗi
    END CATCH
END;
GO

-- execute SP_SE_NHANVIENDANGNHAP 100003, 'password100003'

--dang xuat
-- drop proc SP_SE_NHANVIENDANGXUAT
create proc SP_SE_NHANVIENDANGXUAT
as
begin
		begin try
			BEGIN TRANSACTION; -- Bắt đầu transaction
				REVERT;
				execute as login = 'QLNS_login'
			COMMIT TRANSACTION; -- Áp dụng transaction
		end try
		begin catch
		ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
		select 'ThatBai' as TruyVan, ERROR_MESSAGE() as ThongBao --tra ve 
		end catch
end


execute SP_SE_NHANVIENDANGNHAP 100002, 'password100002'


-- tao khóa cho SP_IN_NHANVIEN
	CREATE SYMMETRIC KEY SK_NHANVIEN
	WITH algorithm = AES_256
	ENCRYPTION BY PASSWORD = 'nhom6';
GO
--tao NHANVIEN
-- drop PROCEDURE SP_IN_NHANVIEN
CREATE PROCEDURE SP_IN_NHANVIEN
    @HoTen NVARCHAR(100),
    @Phai NVARCHAR(3),
    @NgaySinh DATE,
    @SoDienThoai VARCHAR(15),
    @Luong INT,
    @PhuCap INT,
    @MaSoThue VARCHAR(20),
    @MaChV INT,
    @MaPhong INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

        DECLARE @Luong_encrypted VARBINARY(max);
        DECLARE @PhuCap_encrypted VARBINARY(max);

        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';
        SET @Luong_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@Luong AS VARCHAR));
        SET @PhuCap_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@PhuCap AS VARCHAR));
        CLOSE SYMMETRIC KEY SK_NHANVIEN;

        INSERT INTO NHANVIEN (HoTen, Phai, NgaySinh, SoDienThoai, Luong, PhuCap, MaSoThue, MaChV, MaPhong)
        VALUES (@HoTen, @Phai, @NgaySinh, @SoDienThoai, @Luong_encrypted, @PhuCap_encrypted, @MaSoThue, @MaChV, @MaPhong);

        -- Lấy mã nhân viên vừa được tạo mới
        DECLARE @MaNV INT;
        SET @MaNV = SCOPE_IDENTITY();

        -- Tạo mới tài khoản cho nhân viên
        DECLARE @MatKhau_encrypted VARBINARY(max);
        SET @MatKhau_encrypted = HASHBYTES('SHA2_512', 'password' + CAST(@MaNV AS VARCHAR(10)));

        INSERT INTO TAIKHOAN (MaNV, MatKhau)
        VALUES (@MaNV, @MatKhau_encrypted);

		--sử dụng dynamic SQL để tạo các đối tượng đăng nhập và người dùng
        --DECLARE @DynamicSQL NVARCHAR(MAX);
        --SET @DynamicSQL = 'CREATE LOGIN ' + QUOTENAME(CAST(@MaNV AS NVARCHAR(10))) + ' WITH PASSWORD = ''' + CAST(@MaNV AS NVARCHAR(10)) + ''';';
        EXEC sp_executesql @DynamicSQL;

        SET @DynamicSQL = 'CREATE USER ' + QUOTENAME(CAST(@MaNV AS NVARCHAR(10))) + ' FOR LOGIN ' + QUOTENAME(CAST(@MaNV AS NVARCHAR(10))) + ';';
        EXEC sp_executesql @DynamicSQL;

        SELECT 'ThanhCong' AS TruyVan; -- trả về

        COMMIT TRANSACTION; -- Áp dụng transaction nếu không có lỗi
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- trả về lỗi
    END CATCH
END;
GO


execute SP_IN_NHANVIEN  N'Nguyễn Văn Toản', N'Nam', '03-12-1999', '0123456789', 19000000, 2400000, '0123456789', 101, 101
execute SP_IN_NHANVIEN  N'Trần Đình Trọng', N'Nam', '03-27-1998', '0123456789', 25000000, 3000000, '0123456789', 102, 101
execute SP_IN_NHANVIEN  N'Đoàn Văn Hậu', N'Nam', '03-12-1999', '0123456789', 20000000,4000000, '0123456789', 101, 101
execute SP_IN_NHANVIEN  N'Bùi Tấn Trường', N'Nam', '01-16-1995', '0123456789', 16000000, 2000000, '0123456789', 102, 101

SELECT * FROM sys.dm_exec_sessions;

-- Tạo các role
CREATE ROLE NhanVienRole;
CREATE ROLE TruongPhongRole;
CREATE ROLE NhanVienNhanSuRole;
CREATE ROLE TruongPhongNhanSuRole;
CREATE ROLE NhanVienTaiVuRole;
CREATE ROLE GiamDocRole;
CREATE ROLE AdminROle;