-- ============================================================
-- Script  : 04_insert_customers.sql
-- Purpose : Seed users and customers sample data
-- ============================================================

USE PBDemoDB;
GO

-- Users (password_hash = SHA2-256 of 'demo1234' — replace with real hashing in prod)
INSERT INTO users (username, password_hash, full_name, role, email) VALUES
('admin',   '3ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'System Admin',     'admin', 'admin@pbdemo.local'),
('jsmith',  '3ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'John Smith',       'user',  'jsmith@pbdemo.local'),
('mjones',  '3ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Mary Jones',       'user',  'mjones@pbdemo.local'),
('rwilson', '3ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Robert Wilson',    'admin', 'rwilson@pbdemo.local');
GO

-- Customers
INSERT INTO customers (company_name, contact_name, phone, email, address_line1, city, state, zip_code, country, credit_limit) VALUES
('Acme Corporation',        'Alice Thompson',   '212-555-0101', 'alice@acme.com',       '100 Broadway',         'New York',     'NY', '10001', 'USA', 25000.00),
('Global Tech Solutions',   'Bob Martinez',     '415-555-0122', 'bob@globaltech.com',   '500 Market St',        'San Francisco','CA', '94105', 'USA', 50000.00),
('Sunrise Retail Group',    'Carol White',      '312-555-0133', 'carol@sunrise.com',    '200 Michigan Ave',     'Chicago',      'IL', '60601', 'USA', 15000.00),
('Pacific Distributors',    'David Lee',        '206-555-0144', 'david@pacific.com',    '800 Pine St',          'Seattle',      'WA', '98101', 'USA', 30000.00),
('Metro Supplies Inc',      'Eva Green',        '713-555-0155', 'eva@metrosup.com',     '1200 Main St',         'Houston',      'TX', '77002', 'USA', 20000.00),
('Northeast Trading Co',    'Frank Brown',      '617-555-0166', 'frank@netrade.com',    '50 State St',          'Boston',       'MA', '02109', 'USA', 35000.00),
('Sunbelt Wholesale',       'Grace Kim',        '602-555-0177', 'grace@sunbelt.com',    '3100 Central Ave',     'Phoenix',      'AZ', '85004', 'USA', 18000.00),
('Lakefront Enterprises',   'Henry Davis',      '414-555-0188', 'henry@lakefront.com',  '700 Water St',         'Milwaukee',    'WI', '53202', 'USA', 22000.00),
('Capital Office Products', 'Irene Scott',      '202-555-0199', 'irene@capoffice.com',  '400 K St NW',          'Washington',   'DC', '20001', 'USA', 40000.00),
('Southern Comfort Goods',  'James Wilson',     '404-555-0200', 'james@scgoods.com',    '600 Peachtree St',     'Atlanta',      'GA', '30308', 'USA', 12000.00),
('Mountain View Trading',   'Karen Hall',       '720-555-0211', 'karen@mvtrade.com',    '1500 Blake St',        'Denver',       'CO', '80202', 'USA', 28000.00),
('Bayou Industrial',        'Larry Young',      '504-555-0222', 'larry@bayouind.com',   '900 Canal St',         'New Orleans',  'LA', '70112', 'USA', 16000.00);
GO

PRINT 'Users and customers inserted successfully.';
GO
