-- ============================================================
-- Script  : 06_insert_orders.sql
-- Purpose : Seed orders and order line items
-- ============================================================

USE PBDemoDB;
GO

-- Orders
INSERT INTO orders (customer_id, order_date, required_date, shipped_date, status, ship_to_name, ship_address, ship_city, ship_state, ship_zip, created_by) VALUES
(1000, DATEADD(DAY,-30,GETDATE()), DATEADD(DAY,-23,GETDATE()), DATEADD(DAY,-25,GETDATE()), 'DELIVERED',  'Acme Corporation',       '100 Broadway',      'New York',      'NY', '10001', 1),
(1001, DATEADD(DAY,-20,GETDATE()), DATEADD(DAY,-13,GETDATE()), DATEADD(DAY,-15,GETDATE()), 'DELIVERED',  'Global Tech Solutions',  '500 Market St',     'San Francisco', 'CA', '94105', 2),
(1002, DATEADD(DAY,-15,GETDATE()), DATEADD(DAY, -8,GETDATE()), DATEADD(DAY,-10,GETDATE()), 'SHIPPED',    'Sunrise Retail Group',   '200 Michigan Ave',  'Chicago',       'IL', '60601', 2),
(1003, DATEADD(DAY,-10,GETDATE()), DATEADD(DAY, -3,GETDATE()), NULL,                        'CONFIRMED',  'Pacific Distributors',   '800 Pine St',       'Seattle',       'WA', '98101', 1),
(1004, DATEADD(DAY, -7,GETDATE()), DATEADD(DAY,  0,GETDATE()), NULL,                        'PENDING',    'Metro Supplies Inc',     '1200 Main St',      'Houston',       'TX', '77002', 3),
(1005, DATEADD(DAY, -5,GETDATE()), DATEADD(DAY,  2,GETDATE()), NULL,                        'PENDING',    'Northeast Trading Co',   '50 State St',       'Boston',        'MA', '02109', 3),
(1006, DATEADD(DAY, -3,GETDATE()), DATEADD(DAY,  4,GETDATE()), NULL,                        'PENDING',    'Sunbelt Wholesale',      '3100 Central Ave',  'Phoenix',       'AZ', '85004', 2),
(1000, DATEADD(DAY, -2,GETDATE()), DATEADD(DAY,  5,GETDATE()), NULL,                        'CONFIRMED',  'Acme Corporation',       '100 Broadway',      'New York',      'NY', '10001', 1),
(1007, DATEADD(DAY, -1,GETDATE()), DATEADD(DAY,  6,GETDATE()), NULL,                        'PENDING',    'Lakefront Enterprises',  '700 Water St',      'Milwaukee',     'WI', '53202', 2),
(1008, CAST(GETDATE() AS DATE),    DATEADD(DAY,  7,GETDATE()), NULL,                        'PENDING',    'Capital Office Products','400 K St NW',       'Washington',    'DC', '20001', 1),
(1001, DATEADD(DAY,-45,GETDATE()), DATEADD(DAY,-38,GETDATE()), DATEADD(DAY,-40,GETDATE()), 'DELIVERED',  'Global Tech Solutions',  '500 Market St',     'San Francisco', 'CA', '94105', 1),
(1009, DATEADD(DAY,-60,GETDATE()), DATEADD(DAY,-53,GETDATE()), DATEADD(DAY,-55,GETDATE()), 'DELIVERED',  'Southern Comfort Goods', '600 Peachtree St',  'Atlanta',       'GA', '30308', 2);
GO

-- Order Items  (order_id auto-starts at 10000)
-- Order 10000 — Acme
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10000, 100, 2, 1299.99, 5.00),   -- Laptop Pro
(10000, 104, 2,  399.99, 0.00),   -- Monitor
(10000, 101, 1, 1599.99, 0.00);   -- Desktop
GO
-- Order 10001 — Global Tech
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10001, 116, 10, 149.99, 10.00),  -- Office Suite License
(10001, 117, 10,  59.99, 10.00),  -- Antivirus
(10001, 102,  5,  49.99,  0.00);  -- Keyboard
GO
-- Order 10002 — Sunrise Retail
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10002, 107, 100,   8.99, 2.00),  -- Copy Paper
(10002, 108,  50,  12.99, 0.00),  -- Pens
(10002, 111,   5,   9.99, 0.00);  -- Whiteboard Markers
GO
-- Order 10003 — Pacific Distributors
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10003, 119,  5, 299.99, 0.00),   -- Managed Switch
(10003, 120,  8, 199.99, 5.00),   -- Wireless AP
(10003, 122,100,  12.99, 0.00);   -- Cat6 Cable
GO
-- Order 10004 — Metro Supplies
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10004, 112,  4, 349.99, 0.00),   -- Office Chair
(10004, 113,  2, 599.99, 5.00);   -- Standing Desk
GO
-- Order 10005 — Northeast Trading
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10005, 106,  5,  79.99, 0.00),   -- Webcam
(10005, 105,  5,  59.99, 0.00),   -- USB Hub
(10005, 103, 10,  29.99, 0.00);   -- Mouse
GO
-- Order 10006 — Sunbelt
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10006, 118,  3,  79.99, 0.00),   -- PDF Editor
(10006, 116,  5, 149.99, 0.00);   -- Office Suite
GO
-- Order 10007 — Acme (second order)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10007, 115,  1, 899.99, 0.00),   -- Conference Table
(10007, 112,  8, 349.99, 8.00);   -- Chairs
GO
-- Order 10008 — Lakefront
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10008, 110,  2, 249.99, 0.00),   -- Filing Cabinet
(10008, 109,  3,  24.99, 0.00),   -- Stapler
(10008, 107, 50,   8.99, 0.00);   -- Copy Paper
GO
-- Order 10009 — Capital Office
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10009, 100,  5, 1299.99, 7.00),  -- Laptops
(10009, 104,  5,  399.99, 5.00),  -- Monitors
(10009, 121,  1,  649.99, 0.00);  -- Firewall
GO
-- Order 10010 — Global Tech (old)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10010, 119, 10, 299.99, 10.00),
(10010, 121,  2, 649.99,  0.00);
GO
-- Order 10011 — Southern Comfort (old)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10011, 114,  6, 129.99,  0.00),  -- Bookshelf
(10011, 112,  6, 349.99,  5.00);  -- Chair
GO

PRINT 'Orders and order items inserted successfully.';
GO
