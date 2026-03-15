-- ============================================================
-- Script  : 05_insert_products.sql
-- Purpose : Seed product categories and products
-- ============================================================

USE PBDemoDB;
GO

INSERT INTO product_categories (category_name, description) VALUES
('Electronics',     'Electronic components and devices'),
('Office Supplies', 'General office consumables and equipment'),
('Furniture',       'Office and warehouse furniture'),
('Software',        'Software licenses and subscriptions'),
('Networking',      'Network hardware and accessories');
GO

INSERT INTO products (category_id, product_code, product_name, description, unit_price, stock_qty, reorder_level, unit_of_measure) VALUES
-- Electronics
(1, 'EL-001', 'Laptop Pro 15"',         '15-inch business laptop, 16GB RAM, 512GB SSD',   1299.99, 45, 10, 'EA'),
(1, 'EL-002', 'Desktop Workstation',    'Tower PC, Intel i7, 32GB RAM, 1TB SSD',          1599.99, 22,  5, 'EA'),
(1, 'EL-003', 'Wireless Keyboard',      'Ergonomic wireless keyboard, USB receiver',         49.99,120, 20, 'EA'),
(1, 'EL-004', 'Wireless Mouse',         'Optical wireless mouse, 2.4GHz',                   29.99,150, 25, 'EA'),
(1, 'EL-005', '27" Monitor 4K',         '27-inch IPS 4K display, USB-C',                   399.99, 38, 10, 'EA'),
(1, 'EL-006', 'USB-C Hub 7-Port',       'Multiport USB-C hub, HDMI, SD card',               59.99, 85, 15, 'EA'),
(1, 'EL-007', 'Webcam HD 1080p',        'Full HD webcam with built-in microphone',           79.99, 60, 15, 'EA'),
-- Office Supplies
(2, 'OS-001', 'Copy Paper A4 (Ream)',   '80gsm white copy paper, 500 sheets',                8.99,500,100, 'RM'),
(2, 'OS-002', 'Ballpoint Pens (Box)',   'Blue ballpoint pens, box of 50',                   12.99,200, 50, 'BX'),
(2, 'OS-003', 'Stapler Heavy Duty',     '100-sheet heavy duty stapler',                     24.99, 40, 10, 'EA'),
(2, 'OS-004', 'Filing Cabinet 4-Draw', 'Steel 4-drawer lateral filing cabinet',            249.99,  8,  3, 'EA'),
(2, 'OS-005', 'Whiteboard Markers',     'Dry-erase markers, 4 colors, set of 8',             9.99,180, 40, 'ST'),
-- Furniture
(3, 'FN-001', 'Executive Office Chair', 'High-back ergonomic chair, lumbar support',        349.99, 15,  4, 'EA'),
(3, 'FN-002', 'Standing Desk 60"',      'Electric height-adjustable desk, 60x30 inches',   599.99,  9,  3, 'EA'),
(3, 'FN-003', 'Bookshelf 5-Tier',       'Metal bookshelf, 71" tall, adjustable shelves',   129.99, 12,  4, 'EA'),
(3, 'FN-004', 'Conference Table 8-Seat','Oval conference table, 96" x 48"',                899.99,  4,  2, 'EA'),
-- Software
(4, 'SW-001', 'Office Suite License',   'Productivity suite annual license per user',       149.99, 999, 10, 'LIC'),
(4, 'SW-002', 'Antivirus Business 1yr', 'Endpoint protection, 1-year subscription',         59.99, 999, 10, 'LIC'),
(4, 'SW-003', 'PDF Editor Pro',         'Full-featured PDF editing and signing tool',        79.99, 999, 10, 'LIC'),
-- Networking
(5, 'NW-001', 'Managed Switch 24-Port', 'Layer 2 managed Gigabit switch',                  299.99, 18,  5, 'EA'),
(5, 'NW-002', 'Wireless AP Enterprise', 'Dual-band 802.11ax access point',                 199.99, 24,  6, 'EA'),
(5, 'NW-003', 'Cat6 Ethernet Cable 50ft','Snagless Cat6 patch cable, blue',                 12.99,250, 50, 'EA'),
(5, 'NW-004', 'Firewall Appliance',     'UTM firewall, 1Gbps throughput',                  649.99,  7,  2, 'EA');
GO

PRINT 'Product categories and products inserted successfully.';
GO
