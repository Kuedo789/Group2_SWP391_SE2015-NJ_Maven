-- Xóa bảng uservoucher (bảng nối cũ) và bảng Voucher cũ nếu có
DROP TABLE IF EXISTS `uservoucher`;
DROP TABLE IF EXISTS `Voucher`;

-- Tạo lại bảng Voucher mới với cấu trúc Nhập Mã Giảm Giá
CREATE TABLE `Voucher` (
  `Voucher_Code` varchar(50) NOT NULL,
  `Discount_Amount` decimal(10,2) NOT NULL,
  `Min_Order_Value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `Total_Quantity` int(11) NOT NULL DEFAULT '0',
  `Usage_Per_User` int(11) NOT NULL DEFAULT '1',
  `Required_Tier_ID` int(11) NOT NULL DEFAULT '1',
  `Start_Date` date NOT NULL,
  `End_Date` date NOT NULL,
  `Is_Active` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`Voucher_Code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Cập nhật bảng orders
-- Đảm bảo bạn đã có cột Discount_Amount từ trước, nếu lỡ xóa thì bỏ comment dòng dưới:
-- ALTER TABLE `orders` ADD COLUMN `Discount_Amount` decimal(10,2) DEFAULT '0.00';

-- Thêm cột Applied_Voucher_Code vào bảng orders để theo dõi lịch sử xài mã của khách
ALTER TABLE `orders` ADD COLUMN `Applied_Voucher_Code` varchar(50) DEFAULT NULL;

-- Thêm vài dữ liệu mẫu
INSERT INTO `Voucher` (`Voucher_Code`, `Discount_Amount`, `Min_Order_Value`, `Total_Quantity`, `Usage_Per_User`, `Required_Tier_ID`, `Start_Date`, `End_Date`, `Is_Active`) VALUES
('WELCOME100', 100000.00, 500000.00, 50, 1, 1, '2024-01-01', '2026-12-31', b'1'),
('GOLD50', 50000.00, 200000.00, 100, 2, 4, '2024-01-01', '2026-12-31', b'1');
