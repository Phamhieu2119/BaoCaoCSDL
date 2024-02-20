create database QuanLyPhongTro ;
go
use QuanLyPhongTro;
go
CREATE TABLE KHACHHANG
(
  id_khach_hang INT NOT NULL,
  so_dien_thoai VARCHAR(15) NOT NULL,
  dia_chi NVARCHAR(200) NOT NULL,
  email NVARCHAR(100) NOT NULL,
  ho_ten NVARCHAR(50) NOT NULL,
  PRIMARY KEY (id_khach_hang)
);
CREATE TABLE KHUTRO
(
  id_khu_tro INT NOT NULL,
  dia_chi NVARCHAR(200) NOT NULL,
  ten_khu_tro NVARCHAR(100) NOT NULL,
  so_dien_thoai INT NOT NULL,
  mo_ta NVARCHAR(500) NOT NULL,
  PRIMARY KEY (id_khu_tro)
);
CREATE TABLE DICHVU
(
  id_dich_vu INT NOT NULL,
  don_gia INT NOT NULL,
  ten_dich_vu NVARCHAR(100) NOT NULL,
  don_vi_tinh NVARCHAR(50) NOT NULL,
  mo_ta NVARCHAR(200) NOT NULL,
  trang_thai  bit NOT NULL,
  PRIMARY KEY (id_dich_vu)
);

CREATE TABLE PHANHOI
(
  id_phan_hoi INT NOT NULL,
  ngay_phan_hoi DATE NOT NULL,
  gmail_phan_hoi NVARCHAR(100) NOT NULL,
  mo_ta NVARCHAR(500) NOT NULL,
  id_khach_hang INT NOT NULL,
  PRIMARY KEY (id_phan_hoi),
  FOREIGN KEY (id_khach_hang) REFERENCES KHACHHANG(id_khach_hang)
);
CREATE TABLE thanh_toan
(
  id_thanh_toan INT NOT NULL,
  id_khach_hang INT  NULL,
  id_dich_vu INT  NULL,
  ngay_thanh_toan DATE NOT NULL,
  tong_tien INT NOT NULL,
  tien_da_thanh_toan int NOT NULL,
  trang_thai_thanh_toan  bit ,
  PRIMARY KEY (id_thanh_toan),
  FOREIGN KEY (id_dich_vu) REFERENCES DICHVU(id_dich_vu)  ,
  FOREIGN KEY (id_khach_hang) REFERENCES KHACHHANG(id_khach_hang) ,
);

CREATE TABLE PHONG
(
  id_phong INT NOT NULL,
  dien_tich NVARCHAR(20) NOT NULL,
  so_giuong INT NOT NULL,
  ten_phong NVARCHAR(50) NOT NULL,
  so_nguoi_toi_da INT NOT NULL,
  gia_thue INT NOT NULL,
  trang_thai_phong bit NOT NULL,
  id_chu_tro INT NOT NULL,
  id_khu_tro INT NOT NULL,
  PRIMARY KEY (id_phong),
  FOREIGN KEY (id_khu_tro) REFERENCES KHUTRO(id_khu_tro)
);
CREATE TABLE HOPDONGTHUE
(
  id_hop_dong INT NOT NULL,
  ngay_ket_thuc DATE NOT NULL,
  ngay_bat_dau DATE NOT NULL,
  trang_thai_thanh_toan  bit NOT NULL,
  gia_phong INT NOT NULL,
  id_phong INT NOT NULL,
  id_khach_hang INT NOT NULL,
  PRIMARY KEY (id_hop_dong),
  FOREIGN KEY (id_phong) REFERENCES PHONG(id_phong) ,
  FOREIGN KEY (id_khach_hang) REFERENCES KHACHHANG(id_khach_hang),
);
CREATE TABLE CHITIEU
(
  id_chi_tieu INT NOT NULL,
  so_tien_chi INT NOT NULL,
  ngay_chi DATE NOT NULL,
  mo_ta NVARCHAR(200) NOT NULL,
  id_phong INT NOT NULL,
  PRIMARY KEY (id_chi_tieu),
  FOREIGN KEY (id_phong) REFERENCES PHONG(id_phong)
);

-- rb 1;
ALTER TABLE HOPDONGTHUE
ADD CONSTRAINT chk_gia_phong
CHECK (gia_phong >= 2000000);

-- rb2;
ALTER TABLE HOPDONGTHUE
ADD CONSTRAINT chk_hop_dong_ngay_ket_thuc
CHECK (ngay_ket_thuc >= ngay_bat_dau);

-- rb3;
ALTER TABLE PHONG ADD CONSTRAINT UQ_PHONG_ten_phong UNIQUE (ten_phong);

--rb 5
GO
CREATE FUNCTION dbo.fn_CheckPhanHoi()
RETURNS int
AS
BEGIN
    DECLARE @result int;
    SELECT @result = COUNT(*)
    FROM PHANHOI p
    JOIN HOPDONGTHUE h ON p.id_khach_hang = h.id_khach_hang  AND DATEDIFF(day, h.ngay_bat_dau, p.ngay_phan_hoi) >= 0
	AND DATEDIFF(day, p.ngay_phan_hoi, h.ngay_ket_thuc) >= 0;
    
    RETURN @result;
END;
GO
ALTER TABLE PHANHOI
ADD CONSTRAINT CHK_PHANHOI_HOPDONG CHECK (dbo.fn_CheckPhanHoi() <> 0);
    

ALTER TABLE HOPDONGTHUE
DROP CONSTRAINT CHEK_NgayBDHD;

DROP FUNCTION  dbo.fn_CheckPhanHoi;

-- rb 8;
CREATE TRIGGER trg_thanh_toan_thanh_toan
ON thanh_toan
AFTER INSERT, UPDATE
AS
BEGIN
	IF UPDATE(tien_da_thanh_toan)
	BEGIN
		UPDATE thanh_toan SET thanh_toan.trang_thai_thanh_toan = 1
		WHERE id_khach_hang IN (SELECT id_khach_hang FROM inserted) AND thanh_toan.tien_da_thanh_toan >= thanh_toan.tong_tien;

		UPDATE thanh_toan SET thanh_toan.trang_thai_thanh_toan = 0
		WHERE id_khach_hang IN (SELECT id_khach_hang FROM inserted) AND thanh_toan.tien_da_thanh_toan < thanh_toan.tong_tien;
	END
END;

DROP TRIGGER trg_thanh_toan_thanh_toan;



-- RB BỔ SUNG 

ALTER TABLE thanh_toan
ADD CONSTRAINT check_so_tien_thanhtoan CHECK (tien_da_thanh_toan > 0)





INSERT INTO KHUTRO (id_khu_tro, dia_chi, ten_khu_tro, so_dien_thoai, mo_ta)
VALUES  (1, N'123/4 Nguyễn Văn Linh', N'Khu Trọ Minh Phú', 0123456789, N'Khu trọ cao cấp, đầy đủ tiện nghi'),
	(2, N'567 Lê Đại Hành', N'Khu Trọ Hạnh Phúc', 0987654321, N'Khu trọ gần trung tâm, an ninh tốt'),
	(3, N'321/5 Hoàng Diệu', N'Khu Trọ Đồng Tâm', 0367890123, N'Khu trọ giá rẻ, phòng sạch sẽ'),
	(4, N'789/3 Phạm Ngũ Lão', N'Khu Trọ Việt Anh', 0945678901, N'Khu trọ nhiều cây xanh, yên tĩnh'),
	(5, N'456 Lê Lợi', N'Khu Trọ Tâm Anh', 0356789012, N'Khu trọ mới xây, phòng đẹp, sạch sẽ');


INSERT INTO KHACHHANG (id_khach_hang, so_dien_thoai, dia_chi, email, ho_ten)
VALUES (201, '0987654321', N'Hà Nội', 'customer1@gmail.com', N'Nguyễn Văn An'),
(202, '0987654322', N'Nghệ An', 'customer2@gmail.com', N'Trần Thị Bình'),
(203, '0987654323', N'Cần Thơ', 'customer3@gmail.com', N'Lê Văn Chính'),
(204, '0987654324', N'Lào Cai', 'customer4@gmail.com', N'Phạm Thị Diệp'),
(205, '0987654325', N'Hồ Chí Minh', 'customer5@gmail.com', N'Đặng Văn Công'),
(206, '0987654327', N'Hải Phòng', 'customer7@gmail.com', N'Nguyễn Văn Dũng');


INSERT INTO DICHVU (id_dich_vu, don_gia, ten_dich_vu, don_vi_tinh, mo_ta, trang_thai)
VALUES (111, 100000, N'Giặt là', N'Kg', N'Giặt và là quần áo', 1),
       (112, 20000, N'Điện', N'Kw', N'Tiêu thụ điện', 1),
       (113, 50000, N'Nước', N'M3', N'Tiêu thụ nước', 1),
       (114, 300000, N'Wifi', N'Tháng', N'Sử dụng mạng Wifi', 1),
       (115, 500000, N'Dọn phòng', N'Lần', N'Dọn phòng hàng tuần', 1);

INSERT INTO thanh_toan (id_thanh_toan,id_dich_vu, id_khach_hang, ngay_thanh_toan, tong_tien, tien_da_thanh_toan)
VALUES (1,111, 201, '2023-02-15', 500000,500000),
	   (2,115, 201, '2023-02-20', 500000,500000),
       (3,112, 202, '2022-04-15', 1000000,900000),
       (4,113, 203, '2023-06-03', 750000,850000),
       (5,114, 204, '2022-02-02', 800000, 600000),
	   (6,111, 204, '2022-05-20', 400000, 400000),
       (7,115, 205, '2022-05-10', 900000, 900000),
	   (8,115, 203, '2023-02-03', 1000000,1000000),
       (9,111, 206, '2023-02-03', 750000,850000),
	   (10,113, 203, '2023-01-03', 1000000,1000000);

UPDATE thanh_toan
SET trang_thai_thanh_toan = 1
WHERE tien_da_thanh_toan >= tong_tien;

UPDATE thanh_toan
SET trang_thai_thanh_toan = 0
WHERE tien_da_thanh_toan < tong_tien;




INSERT INTO PHANHOI (id_phan_hoi,mo_ta, ngay_phan_hoi, gmail_phan_hoi, id_khach_hang)
VALUES
(1001, N'Phòng sạch sẽ, giá hợp lý', '2023-03-02', 'customer1@gmail.com', 201),
       (1002, N'Tiện nghi đầy đủ, nhân viên thân thiện', '2022-03-15', 'customer2@gmail.com', 202),
       (1003, N'Phòng rộng rãi, view đẹp', '2023-04-01', 'customer3@gmail.com', 203),
       (1004, N'Không gian yên tĩnh, an ninh tốt', '2023-04-20', 'customer4@gmail.com', 204),
       (1005, N'Giá cả phải chăng, dịch vụ tốt', '2022-05-10', 'customer5@gmail.com', 205),
	   (1006, N'Điện nước ổn định, internet nhanh', '2023-02-01', 'customer6@gmail.com', 201),
	   (1007, N'Phòng sạch sẽ, gần trung tâm', '2023-06-15', 'customer7@gmail.com', 203),
       (1008, N'Giá cả phải chăng, dịch vụ tốt', '2023-04-01', 'customer3@gmail.com', 202);


INSERT INTO PHONG (id_phong, dien_tich, so_giuong, ten_phong, so_nguoi_toi_da, gia_thue, trang_thai_phong, id_chu_tro, id_khu_tro)
VALUES (701,'20.5', 2, N'Phòng 101', 3, 3000000, 0, 101, 1),
       (702,'25.0', 3, N'Phòng 201A', 4, 3500000, 1, 102, 2),
       (703,'18.5', 1, N'Phòng 305', 2, 2000000, 0, 103, 3),
       (704,'22.0', 2, N'Phòng 408B', 3, 2500000, 1, 104, 4),
       (705,'24.0', 3, N'Phòng 512', 4, 4000000, 0, 105, 5),
       (706,'23.0', 3, N'Phòng 402', 2, 3000000, 0, 106, 1);


INSERT INTO CHITIEU (id_chi_tieu, mo_ta, so_tien_chi, ngay_chi, id_phong)
VALUES (336, N'Bảo trì thiết bị điện tử trong phòng', 800000, '2022-06-02', 701),
       (337, N'Sửa chữa tủ lạnh trong phòng', 1200000, '2022-06-10', 701),
       (338, N'Vệ sinh máy lạnh phòng', 600000, '2022-06-25', 701),
       (339, N'Bảo dưỡng đèn trong phòng', 500000, '2022-07-05', 701),
       (340, N'Sửa chữa cửa sổ trong phòng', 900000, '2022-07-20', 701),
       (341, N'Bảo trì tất cả các thiết bị trong phòng', 1500000, '2022-08-05', 702),
       (342, N'Vệ sinh quạt trần phòng', 300000, '2022-08-15', 702),
       (343, N'Sửa chữa bồn tắm phòng', 1000000, '2022-09-01', 703),
       (344, N'Bảo dưỡng máy lọc nước trong phòng', 700000, '2022-09-15', 704),
       (345, N'Sửa chữa ống thoát nước phòng', 800000, '2022-09-30', 705);


INSERT INTO HOPDONGTHUE (id_hop_dong, ngay_bat_dau, ngay_ket_thuc, gia_phong, trang_thai_thanh_toan, id_phong, id_khach_hang)
VALUES (221, '2023-01-01', '2023-03-30', 4000000, 1, 701, 201),
       (222, '2022-02-15', '2023-07-03', 3500000, 0, 702, 202),
       (223, '2023-04-01', '2023-12-31', 2800000, 1, 703, 203),
       (224, '2022-02-15', '2022-07-31', 2200000, 1, 704, 204),
       (225, '2022-05-01', '2023-3-31', 2600000, 1, 705, 205),
       (226, '2022-02-15', '2023-04-03', 2700000, 0, 706, 206);


	  



select * from KHUTRO
select * from KHACHHANG
select * from thanh_toan
select * from PHANHOI
select * from PHONG
select * from CHITIEU
select * from HOPDONGTHUE
select * from DICHVU



DELETE FROM  thanh_toan;
DELETE FROM  HOPDONGTHUE;
DELETE FROM  PHANHOI;
DELETE FROM  KHACHHANG;


drop table thanh_toan;
drop table KHACHHANG;
drop table PHANHOI;
drop table HOPDONGTHUE;


-- sql

--1
select ho_ten,dia_chi,so_dien_thoai from KHACHHANG

--2 
select ho_ten from KHACHHANG where dia_chi = N'Hà Nội';

--3
select id_hop_dong,ngay_bat_dau from HOPDONGTHUE WHERE ngay_bat_dau >= '2023-01-01';

--4

SELECT ho_ten, dia_chi 
FROM KHACHHANG AS K 
INNER JOIN (
  SELECT id_khach_hang 
  FROM HOPDONGTHUE 
  WHERE MONTH(ngay_ket_thuc) = 3
) AS H ON K.id_khach_hang = H.id_khach_hang;


--5

SELECT K.id_khach_hang, ho_ten, COUNT (K.id_khach_hang) AS 'so lan thanh toan'
FROM KHACHHANG AS K
INNER JOIN thanh_toan AS T
ON K.id_khach_hang = T.id_khach_hang
WHERE MONTH(T.ngay_thanh_toan) = 2
GROUP BY K.id_khach_hang, ho_ten;




--6
SELECT SUM(tong_tien) AS tong_tien_2022
FROM thanh_toan
WHERE YEAR(thanh_toan.ngay_thanh_toan) = 2022

--7
SELECT KHACHHANG.id_khach_hang, ho_ten, SUM(tong_tien) AS tong_tien_thanh_toan
FROM KHACHHANG 
INNER JOIN thanh_toan ON KHACHHANG.id_khach_hang = thanh_toan.id_khach_hang
GROUP BY KHACHHANG.id_khach_hang, ho_ten
HAVING SUM(tong_tien) = (SELECT MAX(tong_tien_sum) FROM (SELECT  SUM(tong_tien) AS tong_tien_sum FROM thanh_toan 
						WHERE YEAR(ngay_thanh_toan) = 2023 AND MONTH(ngay_thanh_toan) = 2 
                        GROUP BY id_khach_hang) AS t);



SELECT KHACHHANG.id_khach_hang, ho_ten, tong_tien_thanh_toan
FROM KHACHHANG 
INNER JOIN  (
  SELECT id_khach_hang, MAX(tong_tien_sum) AS 'tong_tien_thanh_toan' 
  FROM (
    SELECT id_khach_hang, SUM(tong_tien) AS tong_tien_sum 
    FROM thanh_toan 
    WHERE YEAR(ngay_thanh_toan) = 2023 AND MONTH(ngay_thanh_toan) = 2 
    GROUP BY id_khach_hang
  ) AS tmp
  GROUP BY id_khach_hang
) AS max_thanh_toan ON KHACHHANG.id_khach_hang = max_thanh_toan.id_khach_hang;


--8
SELECT id_phong, SUM(so_tien_chi) AS tong_chi_phi
FROM CHITIEU
WHERE YEAR(ngay_chi) = 2022
GROUP BY id_phong;

--9
SELECT KHACHHANG.id_khach_hang, ho_ten, COUNT(PHANHOI.id_phan_hoi) AS so_luong_phan_hoi
FROM KHACHHANG INNER JOIN PHANHOI ON KHACHHANG.id_khach_hang = PHANHOI.id_khach_hang
GROUP BY KHACHHANG.id_khach_hang,  ho_ten 
HAVING COUNT(PHANHOI.id_phan_hoi) = (
    SELECT MAX(so_luong_phan_hoi) 
	FROM (SELECT  COUNT(PHANHOI.id_phan_hoi)
	AS so_luong_phan_hoi FROM PHANHOI
	GROUP BY id_khach_hang) as p) 

--10

SELECT KHUTRO.id_khu_tro, COUNT(KHUTRO.id_khu_tro) AS so_luong_phan_hoi
FROM KHUTRO
INNER JOIN PHONG ON PHONG.id_khu_tro = KHUTRO.id_khu_tro
INNER JOIN HOPDONGTHUE ON HOPDONGTHUE.id_phong = PHONG.id_phong
INNER JOIN PHANHOI ON PHANHOI.id_khach_hang = HOPDONGTHUE.id_khach_hang
GROUP BY KHUTRO.id_khu_tro
HAVING COUNT(KHUTRO.id_khu_tro) = (
  SELECT MAX(so_luong_phan_hoi) 
  FROM (
    SELECT COUNT(KHUTRO.id_khu_tro) AS so_luong_phan_hoi 
    FROM KHUTRO INNER JOIN PHONG ON PHONG.id_khu_tro = KHUTRO.id_khu_tro 
    INNER JOIN HOPDONGTHUE ON HOPDONGTHUE.id_phong = PHONG.id_phong 
    INNER JOIN PHANHOI ON PHANHOI.id_khach_hang = HOPDONGTHUE.id_khach_hang 
    GROUP BY KHUTRO.id_khu_tro
  ) AS k
);


--11

select id_khach_hang, ngay_ket_thuc, trang_thai_thanh_toan 
FROM HOPDONGTHUE 
WHERE DATEDIFF(day,ngay_ket_thuc,GETDATE()) > 0 AND trang_thai_thanh_toan =0 ;

--12 Giảm 5% tiền hợp đồng thuê cho khác hàng có phản hồi nhiều nhất nếu hợp đồng còn hiệu lực

select * from  HOPDONGTHUE

UPDATE HOPDONGTHUE
SET gia_phong = gia_phong * 0.95
FROM (
  SELECT id_khach_hang
  FROM PHANHOI
  GROUP BY id_khach_hang
  HAVING COUNT(id_khach_hang) = (
    SELECT MAX(so_luong_phan_hoi_max) 
    FROM (
      SELECT COUNT(id_khach_hang) as so_luong_phan_hoi_max
      FROM PHANHOI
      GROUP BY id_khach_hang
    ) as phanhoi
  )
) AS khachhang
INNER JOIN HOPDONGTHUE ON HOPDONGTHUE.id_khach_hang = khachhang.id_khach_hang
WHERE DATEDIFF(day, GETDATE(), HOPDONGTHUE.ngay_ket_thuc) >= 0;	
select * from  HOPDONGTHUE

--13
SELECT khutro.id_khu_tro, COUNT(khutro.id_khu_tro) as so_luong_dich_vu
FROM khutro
JOIN phong ON phong.id_khu_tro = khutro.id_khu_tro
JOIN hopdongthue ON hopdongthue.id_phong = phong.id_phong
JOIN thanh_toan ON thanh_toan.id_khach_hang = hopdongthue.id_khach_hang
JOIN dichvu ON dichvu.id_dich_vu = thanh_toan.id_dich_vu
GROUP BY khutro.id_khu_tro
HAVING COUNT(khutro.id_khu_tro) = (
  SELECT MAX(max_dv)
  FROM (
    SELECT COUNT(khutro.id_khu_tro) as max_dv
    FROM khutro JOIN phong ON phong.id_khu_tro = khutro.id_khu_tro
    JOIN hopdongthue ON hopdongthue.id_phong = phong.id_phong
    JOIN thanh_toan ON thanh_toan.id_khach_hang = hopdongthue.id_khach_hang
    JOIN dichvu ON dichvu.id_dich_vu = thanh_toan.id_dich_vu
    GROUP BY khutro.id_khu_tro
  ) as counts
);

--14
SELECT id_phong, DATEDIFF(day, ngay_bat_dau, ngay_ket_thuc) as thoi_gian_thue
FROM HOPDONGTHUE
GROUP BY id_phong, ngay_bat_dau, ngay_ket_thuc
HAVING DATEDIFF(day, ngay_bat_dau, ngay_ket_thuc) =
(
   SELECT MAX(DATEDIFF(day, ngay_bat_dau, ngay_ket_thuc)) 
   FROM HOPDONGTHUE
)




--15 xóa dịch vụ có id  = 114;


DELETE thanh_toan WHERE id_dich_vu = 114
DELETE  DICHVU    WHERE id_dich_vu = 114


