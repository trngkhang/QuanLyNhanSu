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


CREATE OR ALTER PROCEDURE SP_SE_NHANVIENDANGNHAP
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

        SELECT @TruyVan AS TruyVan; select @ThongBao AS MaNV; -- Trả về kết quả

        COMMIT TRANSACTION; -- Áp dụng transaction
    END TRY
    BEGIN CATCH
            ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- Trả về lỗi
    END CATCH
END;
GO

-- execute SP_SE_NHANVIENDANGNHAP 100003, 'password100003'

CREATE ROLE NhanVienRole;
CREATE ROLE TruongPhongRole;
CREATE ROLE NhanVienNhanSuRole;
CREATE ROLE TruongPhongNhanSuRole;
CREATE ROLE NhanVienTaiVuRole;
CREATE ROLE GiamDocRole;

-- Nhân viên: xem nhưng không thêm, xóa, sửa thông tin nhân viên cùng phòng trừ lương, phụ cấp
GRANT SELECT ON NhanVien TO NhanVienRole;
DENY INSERT, UPDATE, DELETE ON NhanVien TO NhanVienRole;

-- Trưởng phòng: xem không giới hạn nhưng không thay đổi
GRANT SELECT ON NhanVien TO TruongPhongRole;
DENY INSERT, UPDATE, DELETE ON NhanVien TO TruongPhongRole;

-- Nhân viên phòng nhân sự: thêm, sửa thông tin nhân viên (trừ nhân sự)
GRANT SELECT, INSERT, UPDATE ON NhanVien TO NhanVienNhanSuRole;
DENY UPDATE ON NhanVien(Luong, PhuCap) TO NhanVienNhanSuRole;

-- Trưởng phòng nhân sự: xem và chỉnh sửa thông tin của mọi nhân viên
GRANT SELECT, INSERT, UPDATE ON NhanVien TO TruongPhongNhanSuRole;

-- Nhân viên phòng tài vụ: xem thông tin trong cùng phòng
GRANT SELECT ON NhanVien TO NhanVienTaiVuRole;

-- Giám đốc: xem tất cả thông tin nhưng chỉ sửa lương, phụ cấp
GRANT SELECT ON NhanVien TO GiamDocRole;
GRANT UPDATE ON NhanVien(Luong, PhuCap) TO GiamDocRole;
execute as login = 'nhanvien1'
SELECT 
    CURRENT_USER AS 'Tên đăng nhập hiện tại',
    USER_NAME() AS 'Vai trò hiện tại';

CREATE LOGIN nhanvien1 with password ='nhanvien1';
CREATE LOGIN truongphong1 with password ='truongphong1';
CREATE LOGIN nhansu1 with password ='nhansu1';
CREATE LOGIN truongphongnhansu with password ='truongphongnhansu';
CREATE LOGIN taivu1 with password ='taivu1';
CREATE LOGIN giamdoc with password ='giamdoc';

CREATE USER nhanvien1 FOR LOGIN nhanvien1;
CREATE USER truongphong1 FOR LOGIN truongphong1;
CREATE USER nhansu1 FOR LOGIN nhansu1;
CREATE USER truongphongnhansu FOR LOGIN truongphongnhansu;
CREATE USER taivu1 FOR LOGIN taivu1;
CREATE USER giamdoc FOR LOGIN giamdoc;

ALTER ROLE NhanVienRole ADD MEMBER nhanvien1;
ALTER ROLE TruongPhongRole ADD MEMBER truongphong1;
ALTER ROLE NhanVienNhanSuRole ADD MEMBER nhansu1;
ALTER ROLE TruongPhongNhanSuRole ADD MEMBER truongphongnhansu;
ALTER ROLE NhanVienTaiVuRole ADD MEMBER taivu1;
ALTER ROLE GiamDocRole ADD MEMBER giamdoc;

    DECLARE @UserRole NVARCHAR(100);
    DECLARE @CurrentUser NVARCHAR(100) = USER_NAME();
    SELECT @UserRole = dp.name
    FROM sys.database_principals dp
    JOIN sys.database_role_members drm ON dp.principal_id = drm.role_principal_id
    JOIN sys.database_principals up ON drm.member_principal_id = up.principal_id
    WHERE up.name = @CurrentUser;
	go
	print @UserRole;


CREATE OR ALTER PROCEDURE SP_SE_NHANVIEN
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

        -- Open the symmetric key
        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';

        -- Select the decrypted data
        SELECT 
            MaNV, 
            HoTen, 
            Phai, 
            NgaySinh, 
            SoDienThoai, 
            CAST(DECRYPTBYKEY(Luong) AS VARCHAR(20)) AS Luong,
            CAST(DECRYPTBYKEY(PhuCap) AS VARCHAR(20)) AS PhuCap,
            MaSoThue,
            MaChV,
            MaPhong
        FROM 
            NHANVIEN;

        -- Close the symmetric key
        CLOSE SYMMETRIC KEY SK_NHANVIEN;

        -- Indicate success
        SELECT 'ThanhCong' AS TruyVan;

        COMMIT TRANSACTION; -- Commit the transaction if no errors
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Roll back the transaction if an error occurs
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- Return the error message
    END CATCH
END;
GO


-- execute SP_SE_NHANVIEN