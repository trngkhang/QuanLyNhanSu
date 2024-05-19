USE master;
GO

-- drop database QLNS
-- Tao co so du lieu
CREATE DATABASE QLNS;
GO

-- Su dung co so du lieu vua tao
USE QLNS;
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
(N'Phòng IT'),
(N'Phòng nhân sự'),
(N'Phòng tài vụ'),
(N'Phòng giám đốc')
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

--=================================================================================
--============================       KHóa        =================================
--=================================================================================
-- tao khóa cho NHANVIEN
	CREATE SYMMETRIC KEY SK_NHANVIEN
	WITH algorithm = AES_256
	ENCRYPTION BY PASSWORD = 'nhom6';
GO
--======================================================================================
--==========================          Tạo Role          ===========================
--======================================================================================
CREATE ROLE LoginRole;
CREATE ROLE NhanVienRole;
CREATE ROLE TruongPhongRole;
CREATE ROLE NhanVienNhanSuRole;
CREATE ROLE TruongPhongNhanSuRole;
CREATE ROLE NhanVienTaiVuRole;
CREATE ROLE GiamDocRole;
go

--=================================================================================
--============================       TRIGGER        =================================
--=================================================================================

-- trigger tao login, uer , role trên sql server sau khi tạo mới 1 nhân viên
CREATE OR ALTER TRIGGER trg_CreateLoginandUserandRole
ON NHANVIEN
AFTER INSERT
AS
BEGIN
    DECLARE @MaNhanVien INT;
    SELECT @MaNhanVien = MaNhanVien FROM inserted;

    DECLARE @Role NVARCHAR(100);

    -- Select the role from CHUCVU table based on MaChucVu
    SELECT @Role = TenRole
    FROM CHUCVU
    WHERE MaChucVu = (SELECT MaChucVu FROM inserted);

    -- Use dynamic SQL to create login and user
    DECLARE @DynamicSQL NVARCHAR(MAX);

    SET @DynamicSQL = 'CREATE LOGIN ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ' WITH PASSWORD = ''' + CAST(@MaNhanVien AS NVARCHAR(10)) + ''';';
    EXEC sp_executesql @DynamicSQL;

    SET @DynamicSQL = 'CREATE USER ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ' FOR LOGIN ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ';';
    EXEC sp_executesql @DynamicSQL;

    -- If a role is found, assign it to the user
    IF @Role IS NOT NULL
    BEGIN
        SET @DynamicSQL = 'ALTER ROLE ' + QUOTENAME(@Role) + ' ADD MEMBER ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ';';
        EXEC sp_executesql @DynamicSQL;
    END;
END;
go

-- trigger thay doi role nhanvien sau khi thay doi tong tin nhanvien
CREATE OR ALTER TRIGGER trg_UpdateUserRole
ON NHANVIEN
AFTER UPDATE
AS
BEGIN
    DECLARE @MaNhanVien INT;
    DECLARE @MaChucVu INT;
    DECLARE @TenRole NVARCHAR(100);
    DECLARE @DynamicSQL NVARCHAR(MAX);

    -- Get the updated MaNhanVien and MaChucVu from the inserted table
    SELECT @MaNhanVien = MaNhanVien, @MaChucVu = MaChucVu FROM inserted;

    -- Get the corresponding TenRole from the CHUCVU table
    SELECT @TenRole = TenRole FROM CHUCVU WHERE MaChucVu = @MaChucVu;

    -- Revoke all roles from the user
    SET @DynamicSQL = '
        DECLARE @Role NVARCHAR(100);
        DECLARE roles_cursor CURSOR FOR
        SELECT role.name
        FROM sys.database_principals user_principal
        JOIN sys.database_role_members role_members ON user_principal.principal_id = role_members.member_principal_id
        JOIN sys.database_principals role ON role.principal_id = role_members.role_principal_id
        WHERE user_principal.name = ''' + CAST(@MaNhanVien AS NVARCHAR(10)) + '''';

    SET @DynamicSQL = @DynamicSQL + '
        OPEN roles_cursor;
        FETCH NEXT FROM roles_cursor INTO @Role;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC sp_droprolemember @Role, ''' + CAST(@MaNhanVien AS NVARCHAR(10)) + ''';
            FETCH NEXT FROM roles_cursor INTO @Role;
        END;

        CLOSE roles_cursor;
        DEALLOCATE roles_cursor;
    ';

    EXEC sp_executesql @DynamicSQL;

    -- Add the new role to the user
    SET @DynamicSQL = 'EXEC sp_addrolemember ' + QUOTENAME(@TenRole) + ', ' + QUOTENAME(CAST(@MaNhanVien AS NVARCHAR(10))) + ';';
    EXEC sp_executesql @DynamicSQL;
END;
GO


--=================================================================================
--============================       PROCEDURE        =================================
--=================================================================================

---procedure thêm mới 1 nhân viên (role Nhan viên phòng nhân sự)
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

execute SP_INS_NHANVIEN  N'Nguyễn Văn Toản', N'Nam', '2024-05-08', '0123456789', 19000000, 2400000, '1225255529', 1, 100
execute SP_INS_NHANVIEN  N'Trần Đình Trọng', N'Nam', '03-27-1998', '0123456789', 25000000, 3000000, '8563489385', 2, 100
execute SP_INS_NHANVIEN  N'Đoàn Văn Hậu', N'Nam', '03-12-1999', '0123456789', 20000000,4000000, '9638284638', 1, 100
execute SP_INS_NHANVIEN  N'Bùi Tấn Trường', N'Nam', '01-16-1995', '0123456789', 16000000, 2000000, '0123456789', 3, 101
execute SP_INS_NHANVIEN  N'Mai Đức Chung', N'Nam', '06-21-1951', '0123456789', 50000000, 5500000, '0123456789', 3, 101
execute SP_INS_NHANVIEN  N'Trương Mỹ Linh', N'Nữ', '07-22-1986', '0123456789', 20000000, 1200000, '0932747277', 4, 101
execute SP_INS_NHANVIEN  N'Nguyễn Thanh Nhàn', N'Nam', '07-05-1994', '0123456789', 22000000, 1400000, '0123456789', 5, 102
execute SP_INS_NHANVIEN  N'Nguyễn Công Vinh', N'Nam', '12-10-1985', '0123456789', 17000000, 800000, '6282648484', 5, 102
execute SP_INS_NHANVIEN  N'Nguyễn Thanh Tùng', N'Nữ', '02-11-1995', '0123456789', 15500000, 500000, '3764910047', 6, 103
execute SP_INS_NHANVIEN  N'Nguyễn Thị Ánh VIên', N'Nữ', '02-11-1996', '0123456789', 35500000, 500000, '3647367744', 3, 101
execute SP_INS_NHANVIEN  N'Hồ Xuân Nga', N'Nữ', '02-01-1990', '0123456789', 25500000, 2800000, '3483748774', 1, 100
go


--truy van thong tin cua 1 nhan vien
CREATE OR ALTER PROCEDURE SP_SEL_motNHANVIEN
	@MaNhanVien INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu transaction

    OPEN SYMMETRIC KEY SK_NHANVIEN
    DECRYPTION BY PASSWORD = 'nhom6';

    SELECT NV.MaNhanVien, NV.HoTen, NV.GioiTinh, NV.NgaySinh, NV.SoDienThoai,
           CAST(DECRYPTBYKEY(NV.Luong) AS VARCHAR(20)) AS Luong,
           CAST(DECRYPTBYKEY(NV.PhuCap) AS VARCHAR(20)) AS PhuCap,
           NV.MaSoThue, NV.MaChucVu, NV.MaPhong
    FROM NHANVIEN NV
	where NV.MaNhanVien = @MaNhanVien;
    CLOSE SYMMETRIC KEY SK_NHANVIEN;
	        COMMIT TRANSACTION; -- Áp dụng transaction nếu không có lỗi
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Hủy bỏ transaction nếu có lỗi
        SELECT 'ThatBai' AS TruyVan, ERROR_MESSAGE() AS ThongBao; -- trả về lỗi
    END CATCH
END
go
-- execute SP_SEL_motNHANVIEN 1000066


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
    pb.TenPhong,
	cv.TenRole
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
-- execute SP_SEL_DANGNHAP 100000, 'password100000'

--dang xuất login user hiện tại
--revert

-- xem thông tin nhân viên với chức vụ nhân viên: xhir xem thông tin nhân viên cùng phòng ban, trừ trường lương và phụ cấp
create or alter proc SP_SEL_NHANVIEN_NhanVienRole
as
begin
	SELECT NV.MaNhanVien, NV.HoTen, NV.GioiTinh, NV.NgaySinh, NV.SoDienThoai, NV.MaSoThue, CV.TenChucVu, PB.TenPhong
	FROM NHANVIEN NV
	INNER JOIN CHUCVU CV ON NV.MaChucVu = CV.MaChucVu
	INNER JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong
	WHERE PB.MaPhong = (SELECT MaPhong FROM NHANVIEN WHERE MaNhanVien = CONVERT(INT,  USER_NAME()));
end
go
-- exec SP_SEL_NHANVIEN_NhanVienRole


-- xem thông tin nhân viên với chức vụ Trưởng phòng: tất cả thông tin của các nhân viên thuộc phòn ban mình làm trưởng phòng
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
go
-- execute SP_SEL_NHANVIEN_TruongPhongRole

-- xem thông tin nhân viên với chức vụ Nhân viên phòng nhân sự: 
CREATE OR ALTER PROCEDURE SP_SEL_NHANVIEN_NhanVienNhanSuRole
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
    INNER JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong;

    CLOSE SYMMETRIC KEY SK_NHANVIEN;
END
go
-- execute SP_SEL_NHANVIEN_TruongPhongNhanSuRole

-- xem thông tin nhân viên với chức vụ Trưởng phòng nhân sự: xem tất cả thông tin của tất cả nhân viên
CREATE OR ALTER PROCEDURE SP_SEL_NHANVIEN_TruongPhongNhanSuRole
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
    INNER JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong;

    CLOSE SYMMETRIC KEY SK_NHANVIEN;
END
go
-- execute SP_SEL_NHANVIEN_TruongPhongNhanSuRole

-- xem thông tin nhân viên với chức vụ Nhân viên phòng tài vụ: xem thông tin của tất cả các nhân viên trong cùng phòng
-- phòng khác thì chỉ được xem mã nhân viên, lương, phụ cấp và mã số thuế.
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
go
-- execute SP_SEL_NHANVIEN_NhanVienTaiVuRole


-- xem thông tin nhân viên với chức vụ Giám dốc: xem tất cả thông tin của tất cả nhân viên
CREATE OR ALTER PROCEDURE SP_SEL_NHANVIEN_GiamDocRole
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
    INNER JOIN PHONGBAN PB ON NV.MaPhong = PB.MaPhong;

    CLOSE SYMMETRIC KEY SK_NHANVIEN;
END
go
-- execute SP_SEL_NHANVIEN_GiamDocRole

--chỉnh sửa thông tin của nhân viên, cả 3 trường hợp với chủ thể có role Nhân viên phong nhân sự, trưởng phong nhân sự , giám đốc
create or alter proc SP_UPD_NHANVIEN
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

		-- Truy vấn để lấy vai trò hiện tại của người dùng
		DECLARE @currentRole NVARCHAR(128);
		SELECT TOP 1 @currentRole = r.name
		FROM sys.database_role_members rm
		JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
		JOIN sys.database_principals p ON rm.member_principal_id = p.principal_id
		WHERE p.name = USER_NAME();

        DECLARE @Luong_encrypted VARBINARY(max);
        DECLARE @PhuCap_encrypted VARBINARY(max);

        OPEN SYMMETRIC KEY SK_NHANVIEN
        DECRYPTION BY PASSWORD = 'nhom6';
        SET @Luong_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@Luong AS VARCHAR));
        SET @PhuCap_encrypted = ENCRYPTBYKEY(KEY_GUID('SK_NHANVIEN'), CAST(@PhuCap AS VARCHAR));
        CLOSE SYMMETRIC KEY SK_NHANVIEN;

		if(@MaNhanVien != @current_MaNhanVien or @currentRole = 'TruongPhongNhanSuRole') -- trưởng phòng được thay đổi luong, phucap của mình, nhân viên khác 
		begin  -- được thay dổi Lương và Phụ cấp
			UPDATE NHANVIEN
			SET HoTen = @HoTen, GioiTinh = @GioiTinh, NgaySinh = @NgaySinh, SoDienThoai = @SoDienThoai, 
			MaSoThue = @MaSoThue, MaChucVu = @MaChucVu, MaPhong = @MaPhong ,
			Luong = @Luong_encrypted, PhuCap= @PhuCap_encrypted
			WHERE MaNhanVien = @MaNhanVien;
		end
		else if (@currentRole = 'GiamDocRole') -- giamdoc chi duoc sua luong va phu cap
		begin
			UPDATE NHANVIEN
			SET Luong = @Luong_encrypted, PhuCap= @PhuCap_encrypted
			WHERE MaNhanVien = @MaNhanVien;
		end
		else	--truong hợp thay đổi cho đối tượng khác
		begin	-- khong thay dổi Lương và Phụ cấp
			UPDATE NHANVIEN
			SET HoTen = @HoTen, GioiTinh = @GioiTinh, NgaySinh = @NgaySinh, SoDienThoai = @SoDienThoai, 
			MaSoThue = @MaSoThue, MaChucVu = @MaChucVu, MaPhong = @MaPhong 
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
go
-- execute  SP_UPD_NHANVIEN 100006, N'Nguyễn Thanh Tùng', N'Nam', '07-05-1994', '0123456789', 22000005, 1400000, '0123456789', 1, 100







--======================================================================================
--==========================          LoginRole          ===========================
--======================================================================================
-- dùng để kết nối với database và đăng nhập vài login nhân viên

--truy cập vào các bảng
Grant select on TAIKHOAN to LoginRole;
Grant select on NHANVIEN to LoginRole;
Grant select on CHUCVU to LoginRole;
Grant select on PHONGBAN to LoginRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO LoginRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO LoginRole;
go
-- tạo login và user và gán quyền
create login QLNS_Login with password = 'QLNS_Login';
create user QLNS_Login for login QLNS_Login;
ALTER ROLE LoginRole ADD MEMBER [QLNS_Login];
use master 
go
GRANT IMPERSONATE ANY LOGIN TO QLNS_Login; -- quyền thực hiện login
use QLNS
go

GRANT EXECUTE ON OBJECT::SP_SEL_DANGNHAP TO LoginRole; --proc dang nhập
GRANT EXECUTE ON OBJECT::SP_SEL_motNHANVIEN TO LoginRole; --truy vấn thông tin nhan viên vừa đăng nhập thành công
-- execute as login = 'QLNS_Login' revert
go

--======================================================================================
--========================           NhanVienRole           ==========================
--======================================================================================

GRANT SELECT ON NHANVIEN (MaNhanVien, HoTen, GioiTinh, NgaySinh, SoDienThoai, MaSoThue, MaChucVu, MaPhong ) TO NhanVienRole;
GRANT SELECT ON CHUCVU TO NhanVienRole;
GRANT SELECT ON PHONGBAN TO NhanVienRole; 
go
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_NhanVienRole TO NhanVienRole;
go

--======================================================================================
--========================           TruongPhongRole           ==========================
--======================================================================================

GRANT SELECT ON NHANVIEN TO TruongPhongRole;
GRANT SELECT ON CHUCVU TO TruongPhongRole;
GRANT SELECT ON PHONGBAN TO TruongPhongRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongRole;
go
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_TruongPhongRole TO TruongPhongRole;
go


--======================================================================================
--====================          NhanVienNhanSuRole          ========================
--======================================================================================

GRANT SELECT ON NHANVIEN TO NhanVienNhanSuRole;
GRANT SELECT ON CHUCVU TO NhanVienNhanSuRole;
GRANT SELECT ON PHONGBAN TO NhanVienNhanSuRole;
GRANT UPDATE on NHANVIEN  to NhanVienNhanSuRole;
GRANT INSERT on NHANVIEN  to NhanVienNhanSuRole;
GRANT ALTER ANY ROLE TO NhanVienNhanSuRole; -- user gán quyen cho uer khác
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienNhanSuRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienNhanSuRole;
go
GRANT EXECUTE ON OBJECT::SP_SEL_motNHANVIEN TO NhanVienNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_NhanVienNhanSuRole TO NhanVienNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_UPD_NHANVIEN TO NhanVienNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_INS_NHANVIEN TO NhanVienNhanSuRole;
go

--======================================================================================
--====================          TruongPhongNhanSuRole          ========================
--======================================================================================

GRANT SELECT ON NHANVIEN TO TruongPhongNhanSuRole;
GRANT SELECT ON CHUCVU TO TruongPhongNhanSuRole;
GRANT SELECT ON PHONGBAN TO TruongPhongNhanSuRole;
GRANT UPDATE on NHANVIEN  to TruongPhongNhanSuRole;
GRANT ALTER ANY ROLE TO TruongPhongNhanSuRole; -- user gán quyen cho uer khác
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongNhanSuRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO TruongPhongNhanSuRole;
go
GRANT EXECUTE ON OBJECT::SP_SEL_motNHANVIEN TO TruongPhongNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_TruongPhongNhanSuRole TO TruongPhongNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_UPD_NHANVIEN TO TruongPhongNhanSuRole;
GRANT EXECUTE ON OBJECT::SP_INS_NHANVIEN TO TruongPhongNhanSuRole;
go

--======================================================================================
--========================          NhanVienTaiVuRole         ========================
--======================================================================================

GRANT SELECT ON NHANVIEN TO NhanVienTaiVuRole;
GRANT SELECT ON CHUCVU TO NhanVienTaiVuRole;
GRANT SELECT ON PHONGBAN TO NhanVienTaiVuRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienTaiVuRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO NhanVienTaiVuRole;
go
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_NhanVienTaiVuRole TO NhanVienTaiVuRole;
go

--======================================================================================
--========================          GiamDocRole         ========================
--======================================================================================

GRANT SELECT ON NHANVIEN TO GiamDocRole;
GRANT SELECT ON CHUCVU TO GiamDocRole;
GRANT SELECT ON PHONGBAN TO GiamDocRole;
GRANT UPDATE on NHANVIEN  to GiamDocRole;
--cap quyen khoa key
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SK_NHANVIEN TO GiamDocRole;
GRANT CONTROL ON SYMMETRIC KEY::SK_NHANVIEN TO GiamDocRole;
go
GRANT EXECUTE ON OBJECT::SP_SEL_NHANVIEN_GiamDocRole TO GiamDocRole;
GRANT EXECUTE ON OBJECT::SP_UPD_NHANVIEN TO GiamDocRole;
go