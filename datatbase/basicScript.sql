USE master;
GO

-- drop database DEMO_QLNS
-- Tao co so du lieu
CREATE DATABASE DEMO_QLNS;
GO

-- Su dung co so du lieu vua tao
USE DEMO_QLNS;
GO

-- Tao bang thong tin nhan vien
CREATE TABLE NHANVIEN (
    MaNhanVien int IDENTITY(100000,1) PRIMARY KEY,
    HoTen NVARCHAR(100),
    GioiTinh NVARCHAR(3),
    NgaySinh DATE,
    SoDienThoai VARCHAR(15),
    Luong VARBINARY(max),
    PhuCap VARBINARY(max),
    MaSoThue VARCHAR(20),
	MaChucVu int,
    MaPhong int,
);
GO

-- tao bang tai khoan
CREATE TABLE TAIKHOAN(
	MaNhanVien int,
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
	MaChucVu INT PRIMARY KEY,
	TenChucVu NVARCHAR(100),
	TenRole NVARCHAR(100),
);
GO

-- Them rang buoc khoa ngoai
ALTER TABLE NHANVIEN ADD CONSTRAINT FK_NHANVIEN_PHONGBAN
FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong);
GO

ALTER TABLE NHANVIEN ADD CONSTRAINT NHANVIEN_CHUCVU
FOREIGN KEY (MaChucVu) REFERENCES CHUCVU(MaChucVu);
GO

ALTER TABLE PHONGBAN ADD CONSTRAINT PHONGBAN_NHANVIEN
FOREIGN KEY (TruongPhong) REFERENCES NHANVIEN(MaNhanVien);
GO

ALTER TABLE TAIKHOAN ADD CONSTRAINT FK_TAIKHOAN_NHANVIEN
FOREIGN KEY (MaNhanVien) REFERENCES NHANVIEN(MaNhanVien);
GO

insert into PHONGBAN(TenPhong) values
(N'Phòng nhân sự'),
(N'Phòng tài vụ'),
(N'Phòng giám đốc'),
(N'Phòng IT')
Go
-- select * from PHONGBAN

insert into CHUCVU(MaChucVu, TenChucVu, TenRole) values
(1, N'Nhân viên', 'NhanVienRole'),
(2, N'Trưởng Phòng', 'TruongPhongRole'),
(3, N'Nhân viên phòng nhân sự', 'NhanVienNhanSuRole'),
(4, N'Trưởng phòng nhân sự', 'TruongPhongNhanSuRole'),
(5, N'Nhân viên phòng tài vụ', 'NhanVienTaiVuRole'),
(6, N'Giám đốc', 'GiamDocRole')
Go

-- tao khóa cho NHANVIEN
	CREATE SYMMETRIC KEY SK_NHANVIEN
	WITH algorithm = AES_256
	ENCRYPTION BY PASSWORD = 'nhom6';
GO
--======================================================================================
--==========================          LoginRole          ===========================
--======================================================================================
-- dùng để kết nối với database

CREATE ROLE LoginRole;
Grant select on TAIKHOAN to LoginRole;
Grant select on NHANVIEN to LoginRole;
Grant select on CHUCVU to LoginRole;
Grant select on PHONGBAN to LoginRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO LoginRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO LoginRole;

create login QLNS_Login with password = 'QLNS_Login';
create user QLNS_Login for login QLNS_Login;
ALTER ROLE LoginRole ADD MEMBER [QLNS_Login];
use master 
go
GRANT IMPERSONATE ANY LOGIN TO QLNS_Login;
use DEMO_QLNS
go

--đăng nhập (kiem tra MaNhanVien và MatKhau)
CREATE OR ALTER PROCEDURE SP_SEL_DANGNHAP
    @MaNhanVien int,
    @MatKhau VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

        DECLARE @TruyVan NVARCHAR(50);
        DECLARE @ThongBao NVARCHAR(100);

        IF EXISTS(SELECT MaNhanVien FROM TAIKHOAN WHERE MaNhanVien = @MaNhanVien AND MatKhau = HASHBYTES('SHA2_512', @MatKhau))
        BEGIN
            -- Lưu thông tin đăng nhập
            SET @TruyVan = 'ThanhCong';
            SET @ThongBao = @MaNhanVien;
        END
        ELSE
        BEGIN
            SET @TruyVan = 'ThatBai';
            SET @ThongBao = N'Sai tài khoản hoặc mật khẩu';
        END

        SELECT @TruyVan AS TruyVan; 
		-- tra ve thong tin nhanvien
		        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';
		SELECT 
			nv.MaNhanVien,
			nv.HoTen,
			nv.GioiTinh,
			nv.NgaySinh,
		nv.SoDienThoai,
		CAST(DECRYPTBYKEY(NV.Luong) AS VARCHAR(20)) AS Luong,
		CAST(DECRYPTBYKEY(NV.PhuCap) AS VARCHAR(20)) AS PhuCap,
    nv.MaSoThue,
    cv.TenChucVu,
    pb.TenPhong
FROM 
    NHANVIEN nv
JOIN 
    CHUCVU cv ON nv.MaChucVu = cv.MaChucVu
JOIN 
    PHONGBAN pb ON nv.MaPhong = pb.MaPhong
WHERE nv.MaNhanVien = @MaNhanVien
        CLOSE SYMMETRIC KEY SK_NHANVIEN;
        COMMIT TRANSACTION; -- Áp dụng transaction
    END TRY
    BEGIN CATCH
            ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- Trả về lỗi
    END CATCH
END;
GO

-- execute SP_SEL_DANGNHAP 100001, 'password100001'




GRANT EXECUTE ON OBJECT::SP_SEL_DANGNHAP TO LoginRole;


-- exec as login = 'QLNS_Login'


-- drop PROCEDURE SP_IN_NHANVIEN
CREATE OR ALTER PROCEDURE SP_INS_NHANVIEN
    @HoTen NVARCHAR(100),
    @GioiTinh NVARCHAR(3),
    @NgaySinh DATE,
    @SoDienThoai VARCHAR(15),
    @Luong INT,
    @PhuCap INT,
    @MaSoThue VARCHAR(20),
    @MaChucVu INT,
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

        INSERT INTO NHANVIEN (HoTen, GioiTinh, NgaySinh, SoDienThoai, Luong, PhuCap, MaSoThue, MaChucVu, MaPhong)
        VALUES (@HoTen, @GioiTinh, @NgaySinh, @SoDienThoai, @Luong_encrypted, @PhuCap_encrypted, @MaSoThue, @MaChucVu, @MaPhong);

        -- Lấy mã nhân viên vừa được tạo mới
        DECLARE @MaNhanVien INT;
        SET @MaNhanVien = SCOPE_IDENTITY();

        -- Tạo mới tài khoản cho nhân viên
        DECLARE @MatKhau_encrypted VARBINARY(max);
        SET @MatKhau_encrypted = HASHBYTES('SHA2_512', 'password' + CAST(@MaNhanVien AS VARCHAR(10)));

        INSERT INTO TAIKHOAN (MaNhanVien, MatKhau)
        VALUES (@MaNhanVien, @MatKhau_encrypted);

        SELECT 'ThanhCong' AS TruyVan; -- trả về

        COMMIT TRANSACTION; -- Áp dụng transaction nếu không có lỗi
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- trả về lỗi
    END CATCH
END;
GO

execute SP_INS_NHANVIEN  N'Nguyễn Văn Toản', N'Nam', '03-12-1999', '0123456789', 19000000, 2400000, '0123456789', 1, 100
execute SP_INS_NHANVIEN  N'Trần Đình Trọng', N'Nam', '03-27-1998', '0123456789', 25000000, 3000000, '0123456789', 2, 101
execute SP_INS_NHANVIEN  N'Đoàn Văn Hậu', N'Nam', '03-12-1999', '0123456789', 20000000,4000000, '0123456789', 1, 102
execute SP_INS_NHANVIEN  N'Bùi Tấn Trường', N'Nam', '01-16-1995', '0123456789', 16000000, 2000000, '0123456789', 3, 101
execute SP_INS_NHANVIEN  N'Mai Đức Chung', N'Nam', '06-21-1951', '0123456789', 50000000, 5500000, '0123456789', 6, 102
execute SP_INS_NHANVIEN  N'Trương Mỹ Linh', N'Nữ', '07-22-1986', '0123456789', 20000000, 1200000, '0123456789', 5, 101
execute SP_INS_NHANVIEN  N'Nguyễn Thanh Tùng', N'Nam', '07-05-1994', '0123456789', 22000000, 1400000, '0123456789', 4, 100
execute SP_INS_NHANVIEN  N'Nguyễn Công Vinh', N'Nam', '12-10-1985', '0123456789', 17000000, 800000, '0123456789', 1, 103
execute SP_INS_NHANVIEN  N'Nguyễn Thanh Nhàn', N'Nữ', '02-11-1995', '0123456789', 15500000, 500000, '0123456789', 1, 103

go




-- Tạo role và phân quyền

-- Phân quyền cho các role
--======================================================================================
--========================           NhanVienRole           ==========================
--======================================================================================
CREATE ROLE NhanVienRole;
GRANT SELECT ON NHANVIEN (MaNhanVien, HoTen, GioiTinh, NgaySinh, SoDienThoai, MaSoThue, MaChucVu, MaPhong ) TO NhanVienRole;
GRANT SELECT ON CHUCVU TO NhanVienRole;
GRANT SELECT ON PHONGBAN TO NhanVienRole;
GRANT SELECT ON TAIKHOAN TO NhanVienRole;
GRANT SELECT ON view_NHANVIEN_NhanVienRole TO NhanVienRole;
ALTER ROLE NhanVienRole ADD MEMBER [100003];

create or alter view view_NHANVIEN_NhanVienRole
AS
SELECT NV.MaNhanVien, NV.HoTen, NV.GioiTinh, NV.NgaySinh, NV.SoDienThoai, NV.MaSoThue, CV.TenChucVu, PB.TenPhong
FROM NHANVIEN NV
INNER JOIN CHUCVU CV ON NV.MaChucVu = CV.MaChucVu
INNER JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong
WHERE PB.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = CONVERT(INT,  USER_NAME()));
print USER_NAME()
select * from view_NHANVIEN_NhanVienRole


--======================================================================================
--========================           TruongPhongRole           ==========================
--======================================================================================
CREATE ROLE TruongPhongRole;
GRANT SELECT TO TruongPhongRole;
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_TruongPhongRole TO TruongPhongRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongRole;
ALTER ROLE TruongPhongRole ADD MEMBER [100001];
execute as login = '100001'

CREATE OR ALTER PROCEDURE SP_SEL_NHANVIEN_TruongPhongRole
AS
BEGIN
    OPEN SYMMETRIC KEY SK_NHANVIEN
    DECRYPTION BY PASSWORD = 'nhom6';

    SELECT NV.MaNhanVien, NV.HoTen, NV.GioiTinh, NV.NgaySinh, NV.SoDienThoai,
           CAST(DECRYPTBYKEY(NV.Luong) AS VARCHAR(20)) AS Luong,
           CAST(DECRYPTBYKEY(NV.PhuCap) AS VARCHAR(20)) AS PhuCap,
           NV.MaSoThue, CV.TenChucVu, PB.TenPhong
    FROM NHANVIEN NV
    INNER JOIN CHUCVU CV ON NV.MaChucVu = CV.MaChucVu
    INNER JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong
    WHERE PB.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = CONVERT(INT, USER_NAME()));

    CLOSE SYMMETRIC KEY SK_NHANVIEN;
END
execute SP_SEL_NHANVIEN_TruongPhongRole


--======================================================================================
--=======================          NhanVienNhanSuRole          =========================
--======================================================================================

CREATE ROLE NhanVienNhanSuRole;
GRANT SELECT TO NhanVienNhanSuRole;
GRANT INSERT, UPDATE on NHANVIEN to NhanVienNhanSuRole;
GRANT INSERT, UPDATE on TAIKHOAN to NhanVienNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_INS_NHANVIEN TO NhanVienNhanSuRole;
use master
go
GRANT CREATE Login  to NhanVienNhanSuRole;
GRANT CREATE user to NhanVienNhanSuRole;
use DEMO_QLNS
go
GRANT EXECUTE ON OBJECT::SP_UPD_NHANVIEN_TruongPhongNhanSuRole TO NhanVienNhanSuRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienNhanSuRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienNhanSuRole;
ALTER ROLE NhanVienNhanSuRole ADD MEMBER [100007];
execute as login = '100007'
revert



--======================================================================================
--======================          TruongPhongNhanSuRole          ========================
--======================================================================================


CREATE ROLE TruongPhongNhanSuRole;
GRANT SELECT TO TruongPhongNhanSuRole;
GRANT UPDATE on NHANVIEN  to TruongPhongNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_UPD_NHANVIEN_TruongPhongNhanSuRole TO TruongPhongNhanSuRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongNhanSuRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongNhanSuRole;
ALTER ROLE TruongPhongNhanSuRole ADD MEMBER [100006];
execute as login = '100006'

create or alter proc SP_UPD_NHANVIEN_TruongPhongNhanSuRole
	@MaNhanVien INT,
	@HoTen NVARCHAR(100),
    @GioiTinh NVARCHAR(3),
    @NgaySinh DATE,
    @SoDienThoai VARCHAR(15),
    @Luong INT,
    @PhuCap INT,
    @MaSoThue VARCHAR(20),
    @MaChucVu INT,
    @MaPhong INT
as
begin
	    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

		--lay user hien tai dang login
		declare @current_MaNhanVien int;
		set @current_MaNhanVien = CONVERT(INT, USER_NAME());

        DECLARE @Luong_encrypted VARBINARY(max);
        DECLARE @PhuCap_encrypted VARBINARY(max);

        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';
        SET @Luong_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@Luong AS VARCHAR));
        SET @PhuCap_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@PhuCap AS VARCHAR));
        CLOSE SYMMETRIC KEY SK_NHANVIEN;

		if(@MaNhanVien = @current_MaNhanVien) --trường hợp chính đối tượng
		begin	-- khong thay dổi Lương và Phụ cấp
			UPDATE NHANVIEN
			SET HoTen = @HoTen, GioiTinh = @GioiTinh, NgaySinh = @NgaySinh, SoDienThoai = @SoDienThoai, 
			MaSoThue = @MaSoThue, MaChucVu = @MaChucVu, MaPhong = @MaPhong 
			WHERE MaNhanVien = @MaNhanVien;
		end		
		else	--truong hợp thay đổi cho đối tượng khác
		begin  -- được thay dổi Lương và Phụ cấp
			UPDATE NHANVIEN
			SET HoTen = @HoTen, GioiTinh = @GioiTinh, NgaySinh = @NgaySinh, SoDienThoai = @SoDienThoai, 
			MaSoThue = @MaSoThue, MaChucVu = @MaChucVu, MaPhong = @MaPhong ,
			Luong = @Luong_encrypted, PhuCap= @PhuCap_encrypted
			WHERE MaNhanVien = @MaNhanVien;
		end


        SELECT 'ThanhCong' AS TruyVan; -- trả về
        COMMIT TRANSACTION; -- Áp dụng transaction nếu không có lỗi
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- trả về lỗi
    END CATCH
end
-- execute  SP_UPD_NHANVIEN_TruongPhongNhanSuRole 100006, N'Nguyễn Thanh Tùng', N'Nam', '07-05-1994', '0123456789', 22000005, 1400000, '0123456789', 4, 100

--======================================================================================
--========================          NhanVienTaiVuRole         ========================
--======================================================================================
CREATE ROLE NhanVienTaiVuRole;
GRANT SELECT to NhanVienTaiVuRole;
ALTER ROLE NhanVienTaiVuRole ADD MEMBER [100005];
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_NhanVienTaiVuRole TO NhanVienTaiVuRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienTaiVuRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienTaiVuRole;

execute as login ='100005'
select * from NHANVIEN_VIEW

create or alter proc SP_SEL_NHANVIEN_NhanVienTaiVuRole
as
begin
  BEGIN TRY
	BEGIN TRANSACTION; -- Bắt đầu transaction
		
		--lay user hien tai dang login
		declare @current_MaNhanVien int;
		set @current_MaNhanVien = CONVERT(INT, USER_NAME());

        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';

		SELECT 
    NV.MaNhanVien,
    HoTen = CASE 
                WHEN NV.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = @current_MaNhanVien) THEN NV.HoTen
                ELSE NULL
            END,
    GioiTinh = CASE 
                WHEN NV.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = @current_MaNhanVien) THEN NV.GioiTinh
                ELSE NULL
            END,
    NgaySinh = CASE 
                WHEN NV.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = @current_MaNhanVien) THEN NV.NgaySinh
                ELSE NULL
            END,
    SoDienThoai = CASE 
                WHEN NV.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = @current_MaNhanVien) THEN NV.SoDienThoai
                ELSE NULL
            END,
    CAST(DECRYPTBYKEY(NV.Luong) AS VARCHAR(20)) AS Luong,
    CAST(DECRYPTBYKEY(NV.PhuCap) AS VARCHAR(20)) AS PhuCap,
    NV.MaSoThue,
    TenChucVu = CASE 
                WHEN NV.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = @current_MaNhanVien) THEN CV.TenChucVu
                ELSE NULL
            END, 
    TenPhong = CASE 
                WHEN NV.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = @current_MaNhanVien) THEN PB.TenPhong
                ELSE NULL
            END
FROM NHANVIEN NV
    INNER JOIN CHUCVU CV ON NV.MaChucVu = CV.MaChucVu
    INNER JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong;

        SELECT 'ThanhCong' AS TruyVan; -- trả về
        COMMIT TRANSACTION; -- Áp dụng transaction nếu không có lỗi
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- trả về lỗi
    END CATCH
end
-- execute SP_SEL_NHANVIEN_NhanVienTaiVuRole


--======================================================================================
--==========================          GiamDocRole          ===========================
--======================================================================================
CREATE ROLE GiamDocRole;
GRANT SELECT TO GiamDocRole;
GRANT UPDATE ON NHANVIEN (Luong, PhuCap) to GiamDocRole;
ALTER ROLE GiamDocRole ADD MEMBER [100004];
execute as login = '100004'

create or alter proc SP_UPD_NHANVIEN_TruongPhongRole
	@MaNhanVien INT,
	@Luong INT,
    @PhuCap INT
as
begin
	    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

        DECLARE @Luong_encrypted VARBINARY(max);
        DECLARE @PhuCap_encrypted VARBINARY(max);

        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';
        SET @Luong_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@Luong AS VARCHAR));
        SET @PhuCap_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@PhuCap AS VARCHAR));
        CLOSE SYMMETRIC KEY SK_NHANVIEN;

		UPDATE NHANVIEN
		SET Luong = @Luong_encrypted, PhuCap= @PhuCap_encrypted
		WHERE MaNhanVien = @MaNhanVien;

        SELECT 'ThanhCong' AS TruyVan; -- trả về
        COMMIT TRANSACTION; -- Áp dụng transaction nếu không có lỗi
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- trả về lỗi
    END CATCH
end

-- execute SP_UPD_NHANVIEN_TruongPhongRole 100000, 21000000, 1500000


-- Lấy danh sách các vai trò của người dùng hiện tại trong cơ sở dữ liệu
SELECT
    dp.name AS RoleName
FROM
    sys.database_role_members drm
JOIN
    sys.database_principals dp ON drm.role_principal_id = dp.principal_id
JOIN
    sys.database_principals up ON drm.member_principal_id = up.principal_id
WHERE
    up.name = USER_NAME()


create login 100 with password = 'nv03'
create user nv03 for login nv03
exec as login = '100004'
select * from TAIKHOAN
select * from NHANVIEN
select MaNhanVien, HoTen, GioiTinh, NgaySinh, SoDienThoai, MaSoThue, MaChucVu, MaPhong from NHANVIEN

revert
-- Phân quyền chi tiết cho mỗi role


ALTER ROLE NhanVienNhanSuRole ADD MEMBER [Tên người dùng];
ALTER ROLE TruongPhongNhanSuRole ADD MEMBER [Tên người dùng];

select USER_NAME()
exec as login = '100000'
SELECT 
    CURRENT_USER AS 'Tên đăng nhập hiện tại',
    USER_NAME() AS 'Vai trò hiện tại';

	    DECLARE @UserRole NVARCHAR(100);
    DECLARE @CurrentUser NVARCHAR(100) = USER_NAME();
    SELECT  dp.name
    FROM sys.database_principals dp
    JOIN sys.database_role_members drm ON dp.principal_id = drm.role_principal_id
    JOIN sys.database_principals up ON drm.member_principal_id = up.principal_id
    WHERE up.name = USER_NAME();
	go
	print @UserRole;


	--tạo role 
CREATE OR ALTER TRIGGER trg_CreateLoginandUserandRole
ON NHANVIEN
AFTER INSERT
AS
BEGIN
    DECLARE @MaNhanVien INT;
    SELECT @MaNhanVien = MaNhanVien FROM inserted;
	declare @Role varchar(20);
	set @Role = (select 1 from inserted ư

		--sử dụng dynamic SQL để tạo các đối tượng đăng nhập và người dùng
        DECLARE @DynamicSQL NVARCHAR(MAX);
        SET @DynamicSQL = 'CREATE LOGIN ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ' WITH PASSWORD = ''' + CAST(@MaNhanVien AS NVARCHAR(10)) + ''';';
        EXEC sp_executesql @DynamicSQL;

        SET @DynamicSQL = 'CREATE USER ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ' FOR LOGIN ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ';';
        EXEC sp_executesql @DynamicSQL;
END;

	--tạo login và user trên sql server sau khi tạo bảng Tài khoản từ nhân viên
CREATE OR ALTER TRIGGER trg_CreateLoginAndUser
ON TAIKHOAN
AFTER INSERT
AS
BEGIN
    DECLARE @MaNhanVien INT;
	DECLARE @MaChucVu INT;
    SELECT @MaNhanVien = MaNhanVien FROM inserted;
	SELECT @MaChucVu = MaChucVu FROM inserted;
		--sử dụng dynamic SQL để tạo các đối tượng đăng nhập và người dùng
        DECLARE @DynamicSQL NVARCHAR(MAX);
        SET @DynamicSQL = 'CREATE LOGIN ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ' WITH PASSWORD = ''' + CAST(@MaNhanVien AS NVARCHAR(10)) + ''';';
        EXEC sp_executesql @DynamicSQL;

        SET @DynamicSQL = 'CREATE USER ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ' FOR LOGIN ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ';';
        EXEC sp_executesql @DynamicSQL;
END;
go




-- Lấy dữ liệu của nhân viên khi đăng nhập thành công
create or alter procedure SP_SEL_NHANVIEN
	    @MaNhanVien INT
as

begin
	BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

        DECLARE @Luong_encrypted VARBINARY(max);
        DECLARE @PhuCap_encrypted VARBINARY(max);

        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';
SELECT 
    nv.MaNhanVien,
    nv.HoTen,
    nv.GioiTinh,
    nv.NgaySinh,
    nv.SoDienThoai,
    CAST(DECRYPTBYKEY(NV.Luong) AS VARCHAR(20)) AS Luong,
    CAST(DECRYPTBYKEY(NV.PhuCap) AS VARCHAR(20)) AS PhuCap,
    nv.MaSoThue,
    cv.TenChucVu,
    pb.TenPhong
FROM 
    NHANVIEN nv
JOIN 
    CHUCVU cv ON nv.MaChucVu = cv.MaChucVu
JOIN 
    PHONGBAN pb ON nv.MaPhong = pb.MaPhong
WHERE nv.MaNhanVien = @MaNhanVien
        CLOSE SYMMETRIC KEY SK_NHANVIEN;



        COMMIT TRANSACTION; -- Áp dụng transaction nếu không có lỗi
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- trả về lỗi
    END CATCH
end;
go
-- exec SP_SEL_NHANVIEN 100000
