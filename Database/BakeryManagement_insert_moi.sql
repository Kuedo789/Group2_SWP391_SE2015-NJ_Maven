-- ===========================================================================
-- DATA INTEGRATION SCRIPT FOR BAKERY MANAGEMENT SYSTEM (SEPARATED PROFILE SCHEMA)
-- Aligned with the 'bakery' database where Full_Name and Phone are in customer/staff
-- ===========================================================================

USE `bakery`;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `product_review`;
TRUNCATE TABLE `delivery_evidence`;
TRUNCATE TABLE `production_schedule`;
TRUNCATE TABLE `order_item`;
TRUNCATE TABLE `orders`;
TRUNCATE TABLE `delivery_trip`;
TRUNCATE TABLE `cake_layer_detail`;
TRUNCATE TABLE `custom_cake`;
TRUNCATE TABLE `template_ingredient_detail`;
TRUNCATE TABLE `cake_recipe`;
TRUNCATE TABLE `category_accessory`;
TRUNCATE TABLE `accessory`;
TRUNCATE TABLE `product_image`;
TRUNCATE TABLE `cake_template`;
TRUNCATE TABLE `ingredients`;
TRUNCATE TABLE `ingredient_category`;
TRUNCATE TABLE `product_category`;
TRUNCATE TABLE `customer`;
TRUNCATE TABLE `staff`;
TRUNCATE TABLE `user`;
TRUNCATE TABLE `role_permission`;
TRUNCATE TABLE `screen_permission`;
TRUNCATE TABLE `role`;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- IAM & SECURITY
-- =========================================================

INSERT INTO `role` (`Role_ID`, `Role_Name`) VALUES
('ADMIN', 'Quản trị viên'),
('CUSTOMER', 'Khách hàng'),
('STAFF', 'Nhân viên làm bánh'),
('SHIPPER', 'Nhân viên giao hàng');

INSERT INTO `screen_permission` (`Screen_ID`, `Screen_Name`, `Endpoint_URL`) VALUES
('SCR_HOME', 'Trang chủ', '/home'),
('SCR_PRODUCT', 'Quản lý sản phẩm', '/admin/products'),
('SCR_CATEGORY', 'Quản lý danh mục', '/admin/categories'),
('SCR_ORDER', 'Quản lý đơn hàng', '/admin/orders'),
('SCR_DELIVERY', 'Quản lý giao hàng', '/shipper/orders'),
('SCR_USER', 'Quản lý người dùng', '/admin/users'),
('SCR_CUSTOMER', 'Quản lý khách hàng', '/admin/customers'),
('SCR_REVIEW', 'Quản lý đánh giá', '/admin/reviews'),
('SCR_DASHBOARD', 'Thống kê', '/admin/dashboard');

INSERT INTO `role_permission` (`Role_ID`, `Screen_ID`) VALUES
('ADMIN', 'SCR_HOME'), ('ADMIN', 'SCR_PRODUCT'), ('ADMIN', 'SCR_CATEGORY'),
('ADMIN', 'SCR_ORDER'), ('ADMIN', 'SCR_DELIVERY'), ('ADMIN', 'SCR_USER'),
('ADMIN', 'SCR_CUSTOMER'), ('ADMIN', 'SCR_REVIEW'), ('ADMIN', 'SCR_DASHBOARD'),
('STAFF', 'SCR_HOME'), ('STAFF', 'SCR_PRODUCT'), ('STAFF', 'SCR_CATEGORY'), ('STAFF', 'SCR_ORDER'),
('SHIPPER', 'SCR_HOME'), ('SHIPPER', 'SCR_DELIVERY'),
('CUSTOMER', 'SCR_HOME');

-- =========================================================
-- USERS, CUSTOMERS & STAFF
-- =========================================================

INSERT INTO `user` (`User_ID`, `Email`, `Password`, `Role_ID`, `Is_Verified`, `Account_Status`, `Created_At`) VALUES
('ADMIN_0001', 'admin@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'ADMIN', 1, 'Active', NOW()),
('ADMIN_0002', 'admin2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'ADMIN', 1, 'Active', NOW()),
('STAFF_0001', 'staff1@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('STAFF_0002', 'staff2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('STAFF_0003', 'staff3@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('SHIP_0001', 'shipper1@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'SHIPPER', 1, 'Active', NOW()),
('SHIP_0002', 'shipper2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'SHIPPER', 1, 'Active', NOW()),
('CUS_0001', 'customer1@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0002', 'customer2@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0003', 'customer3@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0004', 'customer4@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0005', 'customer5@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0006', 'customer6@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0007', 'customer7@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0008', 'customer8@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 0, 'Active', NOW());

INSERT INTO `customer` (`Customer_ID`, `User_ID`, `Full_Name`, `Phone`, `Default_Address`, `Created_At`) VALUES
('CUS_0001', 'CUS_0001', 'Nguyễn Minh Anh', '0901000001', '12 Nguyễn Trãi, Hà Nội', NOW()),
('CUS_0002', 'CUS_0002', 'Trần Hoàng Nam', '0901000002', '25 Lê Lợi, Hà Nội', NOW()),
('CUS_0003', 'CUS_0003', 'Phạm Thu Hà', '0901000003', '48 Kim Mã, Hà Nội', NOW()),
('CUS_0004', 'CUS_0004', 'Lê Bảo Ngọc', '0901000004', '88 Cầu Giấy, Hà Nội', NOW()),
('CUS_0005', 'CUS_0005', 'Đỗ Quang Huy', '0901000005', '19 Hai Bà Trưng, Hà Nội', NOW()),
('CUS_0006', 'CUS_0006', 'Vũ Lan Anh', '0901000006', '36 Đội Cấn, Hà Nội', NOW()),
('CUS_0007', 'CUS_0007', 'Ngô Đức Trí', '0901000007', '72 Trần Duy Hưng, Hà Nội', NOW()),
('CUS_0008', 'CUS_0008', 'Khách Chưa Xác Thực', '0901000008', '10 Phạm Văn Đồng, Hà Nội', NOW());

INSERT INTO `staff` (`Staff_ID`, `User_ID`, `Full_Name`, `Phone`, `Position`, `Is_Active_Staff`, `Created_At`) VALUES
('ADMIN_0001', 'ADMIN_0001', 'Admin', '0910000001', 'Quản trị viên', 1, NOW()),
('ADMIN_0002', 'ADMIN_0002', 'Admin Phụ', '0910000002', 'Quản trị viên', 1, NOW()),
('STAFF_0001', 'STAFF_0001', 'Nguyễn Nhân Viên Một', '0910000003', 'Nhân viên làm bánh', 1, NOW()),
('STAFF_0002', 'STAFF_0002', 'Trần Nhân Viên Hai', '0910000004', 'Nhân viên làm bánh', 1, NOW()),
('STAFF_0003', 'STAFF_0003', 'Phạm Nhân Viên Ba', '0910000005', 'Nhân viên đóng gói', 1, NOW()),
('SHIP_0001', 'SHIP_0001', 'Lê Shipper Một', '0910000006', 'Nhân viên giao hàng', 1, NOW()),
('SHIP_0002', 'SHIP_0002', 'Đỗ Shipper Hai', '0910000007', 'Nhân viên giao hàng', 1, NOW());

-- =========================================================
-- PRODUCTS & INGREDIENTS
-- =========================================================

INSERT INTO `product_category` (`Category_ID`, `Category_Name`, `Description`, `Sort_Order`, `Icon_URL`) VALUES
('CAT_FLAN', 'Bánh Flan Gato', 'Bánh flan gato mềm mịn, béo nhẹ, phù hợp sinh nhật và tiệc gia đình.', 1, 'assets/images/categories/icons/flan-gato.png'),
('CAT_MOUSSE', 'Bánh Mousse', 'Bánh mousse mát lạnh, vị trái cây hoặc chocolate.', 2, 'assets/images/categories/icons/banh-mousse.png'),
('CAT_CREAM', 'Bánh Kem', 'Bánh kem sinh nhật, bánh kem bắp, bánh kem trang trí.', 3, 'assets/images/categories/icons/kem-bap.png'),
('CAT_BAKED', 'Bánh Nướng', 'Croissant, pain au chocolat và các loại bánh nướng bơ.', 4, 'assets/images/categories/icons/banh-my.png'),
('CAT_PREMIUM', 'Sweetbox Premium', 'Hộp bánh cao cấp dùng làm quà tặng hoặc tiệc sang trọng.', 5, 'assets/images/categories/icons/sweetbox-premium.png'),
('CAT_SWEETIN', 'Sweetin Tiramisu', 'Các dòng tiramisu mềm mịn, vị cà phê hoặc matcha.', 6, 'assets/images/categories/icons/sweetin.png'),
('CAT_ENTREMET', 'Entremet', 'Bánh entremet nhiều lớp, thiết kế hiện đại.', 7, 'assets/images/categories/icons/entremet.png'),
('CAT_HEALTHY', 'Bánh Healthy', 'Bánh ít ngọt, nhẹ vị, phù hợp khách thích lựa chọn cân bằng.', 8, 'assets/images/categories/icons/healthy.png'),
('CAT_COMBO', 'Combo Mini Cake', 'Combo bánh mini nhiều vị, phù hợp dùng thử và tiệc nhỏ.', 9, 'assets/images/categories/icons/combo.png'),
('CAT_SIGNATURE', 'Signature Cake', 'Các mẫu bánh đặc trưng của Bakery Zone.', 10, 'assets/images/categories/icons/signature-cake.png');

INSERT INTO `ingredient_category` (`Category_ID`, `Category_Name`) VALUES
('ICAT_FLOUR', 'Bột'), ('ICAT_SUGAR', 'Đường'), ('ICAT_DAIRY', 'Sữa và kem'), ('ICAT_FRUIT', 'Trái cây'),
('ICAT_TOPPING', 'Topping'), ('ICAT_CHOCOLATE', 'Socola'), ('ICAT_TEA', 'Trà và cà phê'), ('ICAT_NUT', 'Hạt và ngũ cốc');

INSERT INTO `ingredients` (`Ingredient_ID`, `Ingredient_Name`, `Category_ID`, `Price_Per_Unit`) VALUES
('ING_FLOUR', 'Bột mì', 'ICAT_FLOUR', 250), ('ING_CAKE_FLOUR', 'Bột bánh bông lan', 'ICAT_FLOUR', 320),
('ING_SUGAR', 'Đường', 'ICAT_SUGAR', 150), ('ING_CARAMEL', 'Caramel', 'ICAT_SUGAR', 500),
('ING_CREAM', 'Whipping cream', 'ICAT_DAIRY', 1200), ('ING_MASCARPONE', 'Mascarpone', 'ICAT_DAIRY', 2600),
('ING_MILK', 'Sữa tươi', 'ICAT_DAIRY', 450), ('ING_BUTTER', 'Bơ lạt', 'ICAT_DAIRY', 2200),
('ING_STRAWBERRY', 'Dâu tây', 'ICAT_FRUIT', 1800), ('ING_BLUEBERRY', 'Việt quất', 'ICAT_FRUIT', 2400),
('ING_PASSION', 'Chanh dây', 'ICAT_FRUIT', 1500), ('ING_CORN', 'Bắp ngọt', 'ICAT_FRUIT', 700),
('ING_CHOCOLATE', 'Socola', 'ICAT_CHOCOLATE', 1600), ('ING_COCOA', 'Bột cacao', 'ICAT_CHOCOLATE', 900),
('ING_MATCHA', 'Bột matcha', 'ICAT_TEA', 1900), ('ING_COFFEE', 'Cà phê', 'ICAT_TEA', 800),
('ING_OAT', 'Yến mạch', 'ICAT_NUT', 650), ('ING_ALMOND', 'Hạnh nhân', 'ICAT_NUT', 2100);

INSERT INTO `cake_template` (`Template_ID`, `Category_ID`, `Template_Name`, `Base_Price`, `Estimated_Labor_Hours`, `Allows_Greeting`, `Image_URL`, `Status`, `Is_Featured`, `Full_Description`) VALUES
('TPL_0001', 'CAT_FLAN', 'Flan Gato Dâu', 350000, 2.00, 1, 'assets/images/cakeproducts/flan1.png', 'Active', 1, 'Bánh flan gato dâu mềm mịn, vị dâu thơm nhẹ, phù hợp sinh nhật.'),
('TPL_0002', 'CAT_FLAN', 'Flan Gato Truyền Thống', 330000, 2.00, 1, 'assets/images/cakeproducts/flan2.jpg', 'Active', 0, 'Bánh flan gato truyền thống với lớp caramel thơm và cốt bánh mềm.'),
('TPL_0003', 'CAT_FLAN', 'Flan Gato Socola', 360000, 2.10, 1, 'assets/images/cakeproducts/flan3.jpg', 'Active', 0, 'Bánh flan gato socola đậm vị, mềm mịn và dễ ăn.'),
('TPL_0004', 'CAT_FLAN', 'Flan Gato Matcha', 370000, 2.20, 1, 'assets/images/cakeproducts/flan4.jpg', 'Active', 1, 'Bánh flan gato matcha thanh nhẹ, hợp khách thích trà xanh.'),
('TPL_0005', 'CAT_MOUSSE', 'Mousse Dâu Tây', 380000, 1.50, 1, 'assets/images/cakeproducts/mousse1.jpg', 'Active', 1, 'Bánh mousse dâu tươi mát lạnh, vị chua ngọt cân bằng.'),
('TPL_0006', 'CAT_MOUSSE', 'Mousse Chanh Dây', 390000, 1.70, 1, 'assets/images/cakeproducts/mousse2.jpg', 'Active', 0, 'Bánh mousse chanh dây mát lạnh, phù hợp tiệc nhẹ.'),
('TPL_0007', 'CAT_MOUSSE', 'Mousse Việt Quất', 410000, 1.80, 1, 'assets/images/cakeproducts/mousse3.jpg', 'Active', 0, 'Bánh mousse việt quất mềm mịn, hương trái cây nổi bật.'),
('TPL_0008', 'CAT_MOUSSE', 'Mousse Chocolate', 430000, 1.80, 1, 'assets/images/cakeproducts/mousse4.jpg', 'Active', 1, 'Bánh mousse chocolate thơm béo, phù hợp khách thích socola.'),
('TPL_0009', 'CAT_CREAM', 'Bánh Kem Bắp', 420000, 2.50, 1, 'assets/images/cakeproducts/bap1.jpg', 'Active', 1, 'Bánh kem bắp truyền thống, kem mềm và bắp ngọt.'),
('TPL_0010', 'CAT_CREAM', 'Bánh Kem Bắp Đặc Biệt', 450000, 2.50, 1, 'assets/images/cakeproducts/bap2.jpg', 'Active', 0, 'Bánh kem bắp đặc biệt, trang trí đẹp và vị ngọt nhẹ.'),
('TPL_0011', 'CAT_BAKED', 'Croissant Bơ', 45000, 1.00, 0, 'assets/images/cakeproducts/plain-croissant.jpg', 'Active', 0, 'Croissant bơ kiểu Pháp, vỏ giòn thơm bơ.'),
('TPL_0012', 'CAT_BAKED', 'Pain Au Chocolat', 55000, 1.00, 0, 'assets/images/cakeproducts/pain-au-choco.jpg', 'Active', 0, 'Bánh nướng kiểu Pháp nhân socola, vỏ giòn thơm.'),
('TPL_0013', 'CAT_PREMIUM', 'Sweetbox Garden', 650000, 2.00, 1, 'assets/images/cakeproducts/sweetbox1.jpg', 'Active', 1, 'Hộp bánh cao cấp nhiều vị, phù hợp làm quà tặng.'),
('TPL_0014', 'CAT_PREMIUM', 'Sweetbox Premium Mix', 720000, 2.30, 1, 'assets/images/cakeproducts/sweetbox2.jpg', 'Active', 0, 'Hộp bánh premium nhiều vị, trình bày tinh tế.'),
('TPL_0015', 'CAT_PREMIUM', 'Sweetbox Signature 16 Vị', 790000, 2.50, 1, 'assets/images/cakeproducts/sweetbox-signature-hong-16.jpg', 'Active', 1, 'Hộp bánh signature tone hồng gồm 16 vị nhỏ.'),
('TPL_0016', 'CAT_PREMIUM', 'Sweetbox Signature 12 Vị', 690000, 2.20, 1, 'assets/images/cakeproducts/sweetbox-signature-xanh-12.jpg', 'Active', 0, 'Hộp bánh signature tone xanh gồm 12 vị nhỏ.'),
('TPL_0017', 'CAT_SWEETIN', 'Sweetin Matcha Tiramisu', 460000, 1.80, 1, 'assets/images/cakeproducts/sweetin-matcha-tiramisu.jpg', 'Active', 1, 'Tiramisu matcha vị trà xanh dịu nhẹ, lớp kem mềm.'),
('TPL_0018', 'CAT_SWEETIN', 'Sweetin Tiramisu Classic', 440000, 1.80, 1, 'assets/images/cakeproducts/sweetin-tiramisu-classic.jpg', 'Active', 0, 'Tiramisu truyền thống vị cà phê nhẹ, kem béo và cốt mềm.'),
('TPL_0019', 'CAT_ENTREMET', 'Entremet Sakura', 520000, 2.80, 1, 'assets/images/cakeproducts/entremet-sakura.png', 'Active', 1, 'Entremet sakura nhiều lớp, thiết kế tinh tế.'),
('TPL_0020', 'CAT_ENTREMET', 'Entremet Letter Cake', 540000, 3.00, 1, 'assets/images/cakeproducts/entremet-letter.jpg', 'Active', 0, 'Entremet dạng chữ, phù hợp sinh nhật và kỷ niệm.'),
('TPL_0021', 'CAT_HEALTHY', 'Healthy Cake Yến Mạch', 320000, 1.50, 1, 'assets/images/cakeproducts/healthy1.jpg', 'Active', 0, 'Bánh healthy yến mạch, ít ngọt và vị nhẹ.'),
('TPL_0022', 'CAT_HEALTHY', 'Healthy Cake Trái Cây', 350000, 1.60, 1, 'assets/images/cakeproducts/healthy2.jpg', 'Active', 0, 'Bánh healthy kết hợp trái cây, vị thanh nhẹ.'),
('TPL_0023', 'CAT_COMBO', 'Combo Mini Cake 6 Vị', 520000, 2.00, 1, 'assets/images/cakeproducts/combo1.jpg', 'Active', 1, 'Combo bánh mini gồm 6 vị khác nhau, phù hợp tiệc nhỏ.'),
('TPL_0024', 'CAT_COMBO', 'Combo Mini Cake 9 Vị', 640000, 2.30, 1, 'assets/images/cakeproducts/combo2.jpg', 'Active', 0, 'Combo bánh mini gồm 9 vị, trình bày đẹp mắt.');

INSERT INTO `product_image` (`Product_ID`, `Image_URL`, `Is_Cover`, `Sort_Order`) VALUES
('TPL_0001', 'assets/images/cakeproducts/flan1.png', 1, 1), ('TPL_0002', 'assets/images/cakeproducts/flan2.jpg', 1, 1),
('TPL_0003', 'assets/images/cakeproducts/flan3.jpg', 1, 1), ('TPL_0004', 'assets/images/cakeproducts/flan4.jpg', 1, 1),
('TPL_0005', 'assets/images/cakeproducts/mousse1.jpg', 1, 1), ('TPL_0006', 'assets/images/cakeproducts/mousse2.jpg', 1, 1),
('TPL_0007', 'assets/images/cakeproducts/mousse3.jpg', 1, 1), ('TPL_0008', 'assets/images/cakeproducts/mousse4.jpg', 1, 1),
('TPL_0009', 'assets/images/cakeproducts/bap1.jpg', 1, 1), ('TPL_0010', 'assets/images/cakeproducts/bap2.jpg', 1, 1),
('TPL_0011', 'assets/images/cakeproducts/plain-croissant.jpg', 1, 1), ('TPL_0012', 'assets/images/cakeproducts/pain-au-choco.jpg', 1, 1),
('TPL_0013', 'assets/images/cakeproducts/sweetbox1.jpg', 1, 1), ('TPL_0014', 'assets/images/cakeproducts/sweetbox2.jpg', 1, 1),
('TPL_0015', 'assets/images/cakeproducts/sweetbox-signature-hong-16.jpg', 1, 1), ('TPL_0016', 'assets/images/cakeproducts/sweetbox-signature-xanh-12.jpg', 1, 1),
('TPL_0017', 'assets/images/cakeproducts/sweetin-matcha-tiramisu.jpg', 1, 1), ('TPL_0018', 'assets/images/cakeproducts/sweetin-tiramisu-classic.jpg', 1, 1),
('TPL_0019', 'assets/images/cakeproducts/entremet-sakura.png', 1, 1), ('TPL_0020', 'assets/images/cakeproducts/entremet-letter.jpg', 1, 1),
('TPL_0021', 'assets/images/cakeproducts/healthy1.jpg', 1, 1), ('TPL_0022', 'assets/images/cakeproducts/healthy2.jpg', 1, 1),
('TPL_0023', 'assets/images/cakeproducts/combo1.jpg', 1, 1), ('TPL_0024', 'assets/images/cakeproducts/combo2.jpg', 1, 1);

INSERT INTO `accessory` (`Accessory_ID`, `Accessory_Name`, `Price`, `Image_URL`, `Status`) VALUES
('ACC_0001', 'Nến sinh nhật', 10000, 'assets/images/accessories/candle.jpg', 'Active'),
('ACC_0002', 'Dao cắt bánh', 5000, 'assets/images/accessories/knife.jpg', 'Active'),
('ACC_0003', 'Mũ sinh nhật', 20000, 'assets/images/accessories/hat.jpg', 'Active'),
('ACC_0004', 'Thiệp chúc mừng', 15000, 'assets/images/accessories/card.jpg', 'Active'),
('ACC_0005', 'Pháo bông nhỏ', 30000, 'assets/images/accessories/sparkler.jpg', 'Active'),
('ACC_0006', 'Bảng tên mica', 25000, 'assets/images/accessories/nameplate.jpg', 'Active'),
('ACC_0007', 'Hoa trang trí bánh', 35000, 'assets/images/accessories/flower.jpg', 'Active'),
('ACC_0008', 'Hộp quà cao cấp', 45000, 'assets/images/accessories/giftbox.jpg', 'Active');

INSERT INTO `category_accessory` (`Category_ID`, `Accessory_ID`) VALUES
('CAT_FLAN', 'ACC_0001'), ('CAT_FLAN', 'ACC_0002'), ('CAT_MOUSSE', 'ACC_0001'), ('CAT_MOUSSE', 'ACC_0004'),
('CAT_CREAM', 'ACC_0001'), ('CAT_CREAM', 'ACC_0003'), ('CAT_CREAM', 'ACC_0006'),
('CAT_BAKED', 'ACC_0002'), ('CAT_BAKED', 'ACC_0004'), ('CAT_PREMIUM', 'ACC_0004'), ('CAT_PREMIUM', 'ACC_0008'),
('CAT_SWEETIN', 'ACC_0001'), ('CAT_SWEETIN', 'ACC_0004'), ('CAT_ENTREMET', 'ACC_0006'), ('CAT_ENTREMET', 'ACC_0007'),
('CAT_HEALTHY', 'ACC_0004'), ('CAT_COMBO', 'ACC_0004'), ('CAT_COMBO', 'ACC_0008'), ('CAT_SIGNATURE', 'ACC_0001'), ('CAT_SIGNATURE', 'ACC_0007');

INSERT INTO `cake_recipe` (`Recipe_ID`, `Template_ID`, `Recipe_Name`, `Instruction_Steps`) VALUES
('REC_0001', 'TPL_0001', 'Công thức Flan Gato Dâu', 'Chuẩn bị flan, nướng cốt bánh, thêm dâu và làm lạnh.'),
('REC_0002', 'TPL_0002', 'Công thức Flan Gato Truyền Thống', 'Chuẩn bị caramel, flan, cốt bánh và làm lạnh.'),
('REC_0003', 'TPL_0003', 'Công thức Flan Gato Socola', 'Chuẩn bị flan socola, nướng cốt bánh và hoàn thiện.'),
('REC_0004', 'TPL_0004', 'Công thức Flan Gato Matcha', 'Pha matcha, chuẩn bị flan, ráp bánh và làm lạnh.'),
('REC_0005', 'TPL_0005', 'Công thức Mousse Dâu Tây', 'Làm mousse dâu, đổ khuôn và làm lạnh.'),
('REC_0006', 'TPL_0006', 'Công thức Mousse Chanh Dây', 'Làm sốt chanh dây, trộn mousse, đổ khuôn và làm lạnh.'),
('REC_0007', 'TPL_0007', 'Công thức Mousse Việt Quất', 'Chuẩn bị sốt việt quất, làm mousse và trang trí.'),
('REC_0008', 'TPL_0008', 'Công thức Mousse Chocolate', 'Đun chảy socola, trộn mousse, đổ khuôn và làm lạnh.'),
('REC_0009', 'TPL_0009', 'Công thức Bánh Kem Bắp', 'Nướng cốt bánh, đánh kem, phủ bắp và trang trí.'),
('REC_0010', 'TPL_0010', 'Công thức Bánh Kem Bắp Đặc Biệt', 'Nướng cốt bánh, thêm kem bắp, trang trí và làm lạnh.'),
('REC_0011', 'TPL_0011', 'Công thức Croissant Bơ', 'Cán bột, gấp bơ, ủ và nướng.'),
('REC_0012', 'TPL_0012', 'Công thức Pain Au Chocolat', 'Cán bột, thêm nhân socola, ủ và nướng.'),
('REC_0013', 'TPL_0013', 'Công thức Sweetbox Garden', 'Chuẩn bị nhiều loại bánh nhỏ và đóng hộp.'),
('REC_0014', 'TPL_0014', 'Công thức Sweetbox Premium Mix', 'Chuẩn bị các loại bánh premium và sắp xếp vào hộp.'),
('REC_0015', 'TPL_0015', 'Công thức Sweetbox Signature Hồng', 'Chuẩn bị 16 vị bánh nhỏ và đóng hộp tone hồng.'),
('REC_0016', 'TPL_0016', 'Công thức Sweetbox Signature Xanh', 'Chuẩn bị 12 vị bánh nhỏ và đóng hộp tone xanh.'),
('REC_0017', 'TPL_0017', 'Công thức Sweetin Matcha Tiramisu', 'Chuẩn bị kem tiramisu, matcha và xếp lớp bánh.'),
('REC_0018', 'TPL_0018', 'Công thức Sweetin Tiramisu Classic', 'Chuẩn bị cốt bánh, cà phê, kem mascarpone và xếp lớp.'),
('REC_0019', 'TPL_0019', 'Công thức Entremet Sakura', 'Chuẩn bị nhiều lớp mousse, glaze và trang trí sakura.'),
('REC_0020', 'TPL_0020', 'Công thức Entremet Letter Cake', 'Tạo khuôn chữ, chuẩn bị mousse và trang trí.'),
('REC_0021', 'TPL_0021', 'Công thức Healthy Cake Yến Mạch', 'Chuẩn bị yến mạch, cốt bánh healthy và trang trí nhẹ.'),
('REC_0022', 'TPL_0022', 'Công thức Healthy Cake Trái Cây', 'Chuẩn bị cốt bánh healthy, thêm trái cây và hoàn thiện.'),
('REC_0023', 'TPL_0023', 'Công thức Combo Mini Cake 6 Vị', 'Chuẩn bị 6 loại bánh mini và đóng hộp.'),
('REC_0024', 'TPL_0024', 'Công thức Combo Mini Cake 9 Vị', 'Chuẩn bị 9 loại bánh mini và đóng hộp.');

INSERT INTO `template_ingredient_detail` (`Template_ID`, `Ingredient_ID`, `Standard_Gram`) VALUES
('TPL_0001', 'ING_CAKE_FLOUR', 150.00), ('TPL_0001', 'ING_CARAMEL', 60.00), ('TPL_0001', 'ING_STRAWBERRY', 120.00),
('TPL_0002', 'ING_CAKE_FLOUR', 150.00), ('TPL_0002', 'ING_CARAMEL', 80.00), ('TPL_0002', 'ING_MILK', 150.00),
('TPL_0003', 'ING_CAKE_FLOUR', 150.00), ('TPL_0003', 'ING_CHOCOLATE', 120.00), ('TPL_0003', 'ING_CREAM', 150.00),
('TPL_0004', 'ING_CAKE_FLOUR', 150.00), ('TPL_0004', 'ING_MATCHA', 40.00), ('TPL_0004', 'ING_CREAM', 150.00),
('TPL_0005', 'ING_STRAWBERRY', 200.00), ('TPL_0005', 'ING_CREAM', 250.00),
('TPL_0006', 'ING_PASSION', 180.00), ('TPL_0006', 'ING_CREAM', 250.00),
('TPL_0007', 'ING_BLUEBERRY', 180.00), ('TPL_0007', 'ING_CREAM', 250.00),
('TPL_0008', 'ING_CHOCOLATE', 180.00), ('TPL_0008', 'ING_COCOA', 60.00), ('TPL_0008', 'ING_CREAM', 250.00),
('TPL_0009', 'ING_CAKE_FLOUR', 180.00), ('TPL_0009', 'ING_CREAM', 250.00), ('TPL_0009', 'ING_CORN', 150.00),
('TPL_0010', 'ING_CAKE_FLOUR', 200.00), ('TPL_0010', 'ING_CREAM', 280.00), ('TPL_0010', 'ING_CORN', 180.00),
('TPL_0011', 'ING_FLOUR', 180.00), ('TPL_0011', 'ING_BUTTER', 120.00),
('TPL_0012', 'ING_FLOUR', 180.00), ('TPL_0012', 'ING_BUTTER', 120.00), ('TPL_0012', 'ING_CHOCOLATE', 90.00),
('TPL_0013', 'ING_CHOCOLATE', 120.00), ('TPL_0013', 'ING_CREAM', 200.00), ('TPL_0013', 'ING_STRAWBERRY', 100.00),
('TPL_0014', 'ING_CHOCOLATE', 140.00), ('TPL_0014', 'ING_CREAM', 220.00), ('TPL_0014', 'ING_BLUEBERRY', 80.00),
('TPL_0015', 'ING_CREAM', 260.00), ('TPL_0015', 'ING_STRAWBERRY', 120.00), ('TPL_0015', 'ING_ALMOND', 80.00),
('TPL_0016', 'ING_CREAM', 240.00), ('TPL_0016', 'ING_MATCHA', 50.00), ('TPL_0016', 'ING_BLUEBERRY', 80.00),
('TPL_0017', 'ING_MASCARPONE', 220.00), ('TPL_0017', 'ING_MATCHA', 60.00), ('TPL_0017', 'ING_CAKE_FLOUR', 120.00),
('TPL_0018', 'ING_MASCARPONE', 220.00), ('TPL_0018', 'ING_COFFEE', 60.00), ('TPL_0018', 'ING_CAKE_FLOUR', 120.00),
('TPL_0019', 'ING_CREAM', 280.00), ('TPL_0019', 'ING_STRAWBERRY', 100.00), ('TPL_0019', 'ING_ALMOND', 80.00),
('TPL_0020', 'ING_CREAM', 300.00), ('TPL_0020', 'ING_CHOCOLATE', 120.00), ('TPL_0020', 'ING_ALMOND', 70.00),
('TPL_0021', 'ING_OAT', 180.00), ('TPL_0021', 'ING_MILK', 120.00), ('TPL_0021', 'ING_ALMOND', 60.00),
('TPL_0022', 'ING_OAT', 150.00), ('TPL_0022', 'ING_STRAWBERRY', 120.00), ('TPL_0022', 'ING_BLUEBERRY', 90.00),
('TPL_0023', 'ING_CREAM', 260.00), ('TPL_0023', 'ING_CHOCOLATE', 120.00), ('TPL_0023', 'ING_STRAWBERRY', 100.00),
('TPL_0024', 'ING_CREAM', 320.00), ('TPL_0024', 'ING_CHOCOLATE', 150.00), ('TPL_0024', 'ING_BLUEBERRY', 120.00);

-- =========================================================
-- CUSTOM CAKES & ORDERS
-- =========================================================

INSERT INTO `custom_cake` (`Custom_Cake_ID`, `Template_ID`, `Canvas_Image_URL`, `Greeting_Text`, `Frosting_Ingredient_ID`, `Topping_Ingredient_ID`, `Cake_Hash_Structure`, `Calculated_Price`) VALUES
('CC_0001', 'TPL_0001', 'assets/images/custom/cc1.png', 'Chúc mừng sinh nhật', 'ING_CREAM', 'ING_STRAWBERRY', 'HASH_CC_0001', 380000),
('CC_0002', 'TPL_0005', 'assets/images/custom/cc2.png', 'Happy Birthday', 'ING_CREAM', 'ING_CHOCOLATE', 'HASH_CC_0002', 410000),
('CC_0003', 'TPL_0009', 'assets/images/custom/cc3.png', 'Mừng ngày vui', 'ING_CREAM', 'ING_CORN', 'HASH_CC_0003', 450000),
('CC_0004', 'TPL_0011', 'assets/images/custom/cc4.png', NULL, 'ING_BUTTER', NULL, 'HASH_CC_0004', 50000),
('CC_0005', 'TPL_0013', 'assets/images/custom/cc5.png', 'Sweet day', 'ING_CREAM', 'ING_STRAWBERRY', 'HASH_CC_0005', 690000),
('CC_0006', 'TPL_0017', 'assets/images/custom/cc6.png', 'Matcha Love', 'ING_MASCARPONE', 'ING_MATCHA', 'HASH_CC_0006', 480000);

INSERT INTO `cake_layer_detail` (`Layer_ID`, `Custom_Cake_ID`, `Layer_Position`, `Sponge_Ingredient_ID`) VALUES
('LAYER_0001', 'CC_0001', 1, 'ING_CAKE_FLOUR'),
('LAYER_0002', 'CC_0002', 1, 'ING_CAKE_FLOUR'),
('LAYER_0003', 'CC_0003', 1, 'ING_CAKE_FLOUR'),
('LAYER_0004', 'CC_0004', 1, 'ING_FLOUR'),
('LAYER_0005', 'CC_0005', 1, 'ING_CAKE_FLOUR'),
('LAYER_0006', 'CC_0006', 1, 'ING_CAKE_FLOUR');

INSERT INTO `delivery_trip` (`Trip_ID`, `Shipper_ID`, `OSRM_Distance_Km`, `OSRM_Duration_Min`, `Calculated_Shipping_Fee`) VALUES
('TRIP_0001', 'SHIP_0001', 3.20, 15, 25000), ('TRIP_0002', 'SHIP_0001', 5.50, 25, 35000),
('TRIP_0003', 'SHIP_0002', 7.00, 30, 45000), ('TRIP_0004', 'SHIP_0002', 2.80, 12, 22000),
('TRIP_0005', 'SHIP_0001', 9.40, 40, 55000), ('TRIP_0006', 'SHIP_0002', 4.10, 20, 30000);

INSERT INTO `orders` (`Order_No`, `Customer_ID`, `Trip_ID`, `Order_Time`, `Delivery_Window_Start`, `Delivery_Window_End`, `Delivery_Address`, `Deposit_Amount`, `Total_Cost`, `OrderStatus`) VALUES
('ORD_0007', 'CUS_0001', 'TRIP_0001', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY) + INTERVAL 2 HOUR, '12 Nguyễn Trãi, Hà Nội', 100000, 380000, 'Completed'),
('ORD_0008', 'CUS_0001', 'TRIP_0002', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY) + INTERVAL 2 HOUR, '12 Nguyễn Trãi, Hà Nội', 120000, 410000, 'Completed'),
('ORD_0009', 'CUS_0001', 'TRIP_0003', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY) + INTERVAL 2 HOUR, '12 Nguyễn Trãi, Hà Nội', 90000, 450000, 'Cancelled'),
('ORD_0010', 'CUS_0001', 'TRIP_0004', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY) + INTERVAL 2 HOUR, '12 Nguyễn Trãi, Hà Nội', 110000, 500000, 'Processing'),
('ORD_0041', 'CUS_0001', 'TRIP_0005', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 0 DAY), DATE_SUB(NOW(), INTERVAL 0 DAY) + INTERVAL 2 HOUR, '12 Nguyễn Trãi, Hà Nội', 130000, 550000, 'Pending'),
('ORD_0011', 'CUS_0002', 'TRIP_0001', DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY) + INTERVAL 2 HOUR, '25 Lê Lợi, Hà Nội', 100000, 380000, 'Completed'),
('ORD_0012', 'CUS_0002', 'TRIP_0002', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 2 HOUR, '25 Lê Lợi, Hà Nội', 110000, 410000, 'Completed'),
('ORD_0013', 'CUS_0002', 'TRIP_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 2 HOUR, '25 Lê Lợi, Hà Nội', 120000, 450000, 'Cancelled'),
('ORD_0014', 'CUS_0002', 'TRIP_0004', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, '25 Lê Lợi, Hà Nội', 130000, 500000, 'Delivering'),
('ORD_0042', 'CUS_0002', 'TRIP_0005', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), NOW() + INTERVAL 2 HOUR, '25 Lê Lợi, Hà Nội', 140000, 520000, 'Pending'),
('ORD_0015', 'CUS_0003', 'TRIP_0001', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY) + INTERVAL 2 HOUR, '48 Kim Mã, Hà Nội', 100000, 380000, 'Completed'),
('ORD_0016', 'CUS_0003', 'TRIP_0002', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 2 HOUR, '48 Kim Mã, Hà Nội', 110000, 410000, 'Completed'),
('ORD_0017', 'CUS_0003', 'TRIP_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 2 HOUR, '48 Kim Mã, Hà Nội', 120000, 450000, 'Confirmed'),
('ORD_0018', 'CUS_0003', 'TRIP_0004', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, '48 Kim Mã, Hà Nội', 130000, 500000, 'Processing'),
('ORD_0043', 'CUS_0003', 'TRIP_0005', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), NOW() + INTERVAL 2 HOUR, '48 Kim Mã, Hà Nội', 140000, 550000, 'Pending'),
('ORD_0019', 'CUS_0004', 'TRIP_0001', DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY) + INTERVAL 2 HOUR, '88 Cầu Giấy, Hà Nội', 90000, 380000, 'Completed'),
('ORD_0020', 'CUS_0004', 'TRIP_0002', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 2 HOUR, '88 Cầu Giấy, Hà Nội', 110000, 410000, 'Completed'),
('ORD_0021', 'CUS_0004', 'TRIP_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 2 HOUR, '88 Cầu Giấy, Hà Nội', 120000, 450000, 'Confirmed'),
('ORD_0022', 'CUS_0004', 'TRIP_0004', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, '88 Cầu Giấy, Hà Nội', 130000, 500000, 'Processing'),
('ORD_0044', 'CUS_0004', 'TRIP_0005', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), NOW() + INTERVAL 2 HOUR, '88 Cầu Giấy, Hà Nội', 140000, 550000, 'Pending'),
('ORD_0023', 'CUS_0005', 'TRIP_0001', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY) + INTERVAL 2 HOUR, '19 Hai Bà Trưng, Hà Nội', 100000, 380000, 'Completed'),
('ORD_0024', 'CUS_0005', 'TRIP_0002', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 2 HOUR, '19 Hai Bà Trưng, Hà Nội', 110000, 410000, 'Completed'),
('ORD_0025', 'CUS_0005', 'TRIP_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 2 HOUR, '19 Hai Bà Trưng, Hà Nội', 120000, 450000, 'Cancelled'),
('ORD_0026', 'CUS_0005', 'TRIP_0004', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, '19 Hai Bà Trưng, Hà Nội', 130000, 500000, 'Processing'),
('ORD_0035', 'CUS_0005', 'TRIP_0005', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), NOW() + INTERVAL 2 HOUR, '19 Hai Bà Trưng, Hà Nội', 140000, 450000, 'Pending'),
('ORD_0045', 'CUS_0005', 'TRIP_0005', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), NOW() + INTERVAL 2 HOUR, '19 Hai Bà Trưng, Hà Nội', 140000, 550000, 'Pending'),
('ORD_0027', 'CUS_0006', 'TRIP_0001', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY) + INTERVAL 2 HOUR, '36 Đội Cấn, Hà Nội', 100000, 480000, 'Completed'),
('ORD_0028', 'CUS_0006', 'TRIP_0002', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 2 HOUR, '36 Đội Cấn, Hà Nội', 120000, 380000, 'Completed'),
('ORD_0029', 'CUS_0006', 'TRIP_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 2 HOUR, '36 Đội Cấn, Hà Nội', 120000, 410000, 'Confirmed'),
('ORD_0030', 'CUS_0006', 'TRIP_0004', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, '36 Đội Cấn, Hà Nội', 130000, 450000, 'Processing'),
('ORD_0036', 'CUS_0006', 'TRIP_0006', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), NOW() + INTERVAL 2 HOUR, '36 Đội Cấn, Hà Nội', 150000, 50000, 'Pending'),
('ORD_0031', 'CUS_0007', 'TRIP_0001', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY) + INTERVAL 2 HOUR, '72 Trần Duy Hưng, Hà Nội', 100000, 380000, 'Completed'),
('ORD_0032', 'CUS_0007', 'TRIP_0002', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 2 HOUR, '72 Trần Duy Hưng, Hà Nội', 110000, 410000, 'Confirmed'),
('ORD_0033', 'CUS_0007', 'TRIP_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 2 HOUR, '72 Trần Duy Hưng, Hà Nội', 120000, 450000, 'Processing'),
('ORD_0034', 'CUS_0007', 'TRIP_0004', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, '72 Trần Duy Hưng, Hà Nội', 130000, 500000, 'Delivering');

INSERT INTO `order_item` (`Order_Item_ID`, `Order_No`, `Custom_Cake_ID`, `Accessory_ID`, `Quantity`, `Price_At_Purchase`) VALUES
('OI_0007', 'ORD_0007', 'CC_0001', 'ACC_0001', 1, 380000), ('OI_0008', 'ORD_0008', 'CC_0002', 'ACC_0002', 1, 410000),
('OI_0009', 'ORD_0009', 'CC_0003', 'ACC_0003', 1, 450000), ('OI_0010', 'ORD_0010', 'CC_0004', 'ACC_0004', 1, 50000),
('OI_0011', 'ORD_0041', 'CC_0005', 'ACC_0005', 1, 690000), ('OI_0012', 'ORD_0011', 'CC_0002', 'ACC_0001', 1, 410000),
('OI_0013', 'ORD_0012', 'CC_0003', 'ACC_0002', 1, 450000), ('OI_0014', 'ORD_0013', 'CC_0004', 'ACC_0003', 1, 50000),
('OI_0015', 'ORD_0014', 'CC_0005', 'ACC_0004', 1, 690000), ('OI_0016', 'ORD_0042', 'CC_0006', 'ACC_0005', 1, 480000),
('OI_0017', 'ORD_0015', 'CC_0003', 'ACC_0001', 1, 450000), ('OI_0018', 'ORD_0016', 'CC_0004', 'ACC_0002', 1, 50000),
('OI_0019', 'ORD_0017', 'CC_0005', 'ACC_0003', 1, 690000), ('OI_0020', 'ORD_0018', 'CC_0006', 'ACC_0004', 1, 480000),
('OI_0021', 'ORD_0043', 'CC_0001', 'ACC_0005', 1, 380000), ('OI_0022', 'ORD_0019', 'CC_0004', 'ACC_0001', 1, 50000),
('OI_0023', 'ORD_0020', 'CC_0005', 'ACC_0002', 1, 690000), ('OI_0024', 'ORD_0021', 'CC_0006', 'ACC_0003', 1, 480000),
('OI_0025', 'ORD_0022', 'CC_0001', 'ACC_0004', 1, 380000), ('OI_0026', 'ORD_0044', 'CC_0002', 'ACC_0005', 1, 410000),
('OI_0027', 'ORD_0023', 'CC_0005', 'ACC_0001', 1, 690000), ('OI_0028', 'ORD_0024', 'CC_0006', 'ACC_0002', 1, 480000),
('OI_0029', 'ORD_0025', 'CC_0001', 'ACC_0003', 1, 380000), ('OI_0030', 'ORD_0026', 'CC_0002', 'ACC_0004', 1, 410000),
('OI_0031', 'ORD_0035', 'CC_0003', 'ACC_0005', 1, 450000), ('OI_0032', 'ORD_0027', 'CC_0006', 'ACC_0001', 1, 480000),
('OI_0033', 'ORD_0028', 'CC_0001', 'ACC_0002', 1, 380000), ('OI_0034', 'ORD_0029', 'CC_0002', 'ACC_0003', 1, 410000),
('OI_0035', 'ORD_0030', 'CC_0003', 'ACC_0004', 1, 450000), ('OI_0036', 'ORD_0036', 'CC_0004', 'ACC_0005', 1, 50000),
('OI_0037', 'ORD_0031', 'CC_0001', 'ACC_0001', 1, 380000), ('OI_0038', 'ORD_0032', 'CC_0002', 'ACC_0002', 1, 410000),
('OI_0039', 'ORD_0033', 'CC_0003', 'ACC_0003', 1, 450000), ('OI_0040', 'ORD_0034', 'CC_0004', 'ACC_0004', 1, 50000);

INSERT INTO `production_schedule` (`Schedule_ID`, `Order_Item_ID`, `Staff_ID`, `Production_Start_Time`, `Estimated_Completion_Time`, `Actual_Completion_Time`, `Production_Status`) VALUES
('SCH_0007', 'OI_0007', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed'),
('SCH_0008', 'OI_0008', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'Completed'),
('SCH_0009', 'OI_0009', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 'Processing'),
('SCH_0010', 'OI_0010', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 'Pending'),
('SCH_0011', 'OI_0011', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 'Pending'),
('SCH_0012', 'OI_0012', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed'),
('SCH_0013', 'OI_0013', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'Completed'),
('SCH_0014', 'OI_0014', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 'Processing'),
('SCH_0015', 'OI_0015', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 'Processing'),
('SCH_0016', 'OI_0016', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 'Pending'),
('SCH_0017', 'OI_0017', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed'),
('SCH_0018', 'OI_0018', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'Completed'),
('SCH_0019', 'OI_0019', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 'Processing'),
('SCH_0020', 'OI_0020', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 'Pending'),
('SCH_0021', 'OI_0021', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 'Pending'),
('SCH_0022', 'OI_0022', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed'),
('SCH_0023', 'OI_0023', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'Completed'),
('SCH_0024', 'OI_0024', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 'Processing'),
('SCH_0025', 'OI_0025', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 'Processing'),
('SCH_0026', 'OI_0026', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 'Pending'),
('SCH_0027', 'OI_0027', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed'),
('SCH_0028', 'OI_0028', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'Completed'),
('SCH_0029', 'OI_0029', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 'Processing'),
('SCH_0030', 'OI_0030', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 'Pending'),
('SCH_0031', 'OI_0031', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 'Pending'),
('SCH_0032', 'OI_0032', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed'),
('SCH_0033', 'OI_0033', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'Completed'),
('SCH_0034', 'OI_0034', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 'Processing'),
('SCH_0035', 'OI_0035', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 'Processing'),
('SCH_0036', 'OI_0036', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 'Pending'),
('SCH_0037', 'OI_0037', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 'Completed'),
('SCH_0038', 'OI_0038', 'STAFF_0002', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 'Completed'),
('SCH_0039', 'OI_0039', 'STAFF_0003', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 'Processing'),
('SCH_0040', 'OI_0040', 'STAFF_0001', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 'Pending');

INSERT INTO `delivery_evidence` (`Evidence_ID`, `Trip_ID`, `Pickup_Photo_URL`, `Delivery_Photo_URL`) VALUES
('EVI_0001', 'TRIP_0001', 'assets/images/evidence/pickup1.jpg', 'assets/images/evidence/delivery1.jpg'),
('EVI_0002', 'TRIP_0002', 'assets/images/evidence/pickup2.jpg', 'assets/images/evidence/delivery2.jpg'),
('EVI_0003', 'TRIP_0003', 'assets/images/evidence/pickup3.jpg', 'assets/images/evidence/delivery3.jpg'),
('EVI_0004', 'TRIP_0004', 'assets/images/evidence/pickup4.jpg', 'assets/images/evidence/delivery4.jpg'),
('EVI_0005', 'TRIP_0005', 'assets/images/evidence/pickup5.jpg', 'assets/images/evidence/delivery5.jpg'),
('EVI_0006', 'TRIP_0006', 'assets/images/evidence/pickup6.jpg', 'assets/images/evidence/delivery6.jpg');

INSERT INTO `product_review` (`Review_ID`, `Custom_Cake_ID`, `Customer_ID`, `Rating_Stars`, `Comment`, `Moderation_Status`) VALUES
('REV_0001', 'CC_0001', 'CUS_0001', 5, 'Bánh ngon và giao đúng giờ.', 'Approved'),
('REV_0002', 'CC_0002', 'CUS_0002', 4, 'Mousse mềm, vị dâu rõ.', 'Approved'),
('REV_0003', 'CC_0003', 'CUS_0003', 5, 'Trang trí đẹp.', 'Approved'),
('REV_0004', 'CC_0004', 'CUS_0004', 4, 'Croissant thơm bơ.', 'Pending'),
('REV_0005', 'CC_0005', 'CUS_0005', 5, 'Hộp bánh đẹp, phù hợp làm quà.', 'Approved'),
('REV_0006', 'CC_0006', 'CUS_0006', 5, 'Tiramisu matcha rất thơm và không quá ngọt.', 'Approved');