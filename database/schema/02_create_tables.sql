-- ============================================================
-- Script  : 02_create_tables.sql
-- Purpose : Create all application tables
-- ============================================================

USE PBDemoDB;
GO

-- ------------------------------------------------------------
-- USERS table — application login and roles
-- ------------------------------------------------------------
CREATE TABLE users (
    user_id       INT IDENTITY(1,1) PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    role          VARCHAR(20)  NOT NULL DEFAULT 'user',  -- 'admin' | 'user'
    email         VARCHAR(100),
    is_active     BIT          NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT GETDATE(),
    last_login    DATETIME
);
GO

-- ------------------------------------------------------------
-- CUSTOMERS table
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id   INT IDENTITY(1000,1) PRIMARY KEY,
    company_name  VARCHAR(100) NOT NULL,
    contact_name  VARCHAR(100),
    phone         VARCHAR(30),
    email         VARCHAR(100),
    address_line1 VARCHAR(150),
    address_line2 VARCHAR(150),
    city          VARCHAR(80),
    state         VARCHAR(50),
    zip_code      VARCHAR(20),
    country       VARCHAR(60)  NOT NULL DEFAULT 'USA',
    credit_limit  DECIMAL(12,2) NOT NULL DEFAULT 5000.00,
    is_active     BIT          NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT GETDATE(),
    updated_at    DATETIME     NOT NULL DEFAULT GETDATE()
);
GO

-- ------------------------------------------------------------
-- PRODUCT_CATEGORIES table
-- ------------------------------------------------------------
CREATE TABLE product_categories (
    category_id   INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL UNIQUE,
    description   VARCHAR(255)
);
GO

-- ------------------------------------------------------------
-- PRODUCTS table
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id    INT IDENTITY(100,1) PRIMARY KEY,
    category_id   INT            REFERENCES product_categories(category_id),
    product_code  VARCHAR(30)    NOT NULL UNIQUE,
    product_name  VARCHAR(150)   NOT NULL,
    description   VARCHAR(500),
    unit_price    DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    stock_qty     INT            NOT NULL DEFAULT 0,
    reorder_level INT            NOT NULL DEFAULT 10,
    unit_of_measure VARCHAR(20)  NOT NULL DEFAULT 'EA',
    is_active     BIT            NOT NULL DEFAULT 1,
    created_at    DATETIME       NOT NULL DEFAULT GETDATE(),
    updated_at    DATETIME       NOT NULL DEFAULT GETDATE()
);
GO

-- ------------------------------------------------------------
-- ORDERS table (header)
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id      INT IDENTITY(10000,1) PRIMARY KEY,
    customer_id   INT            NOT NULL REFERENCES customers(customer_id),
    order_date    DATE           NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    required_date DATE,
    shipped_date  DATE,
    status        VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
                                 -- PENDING | CONFIRMED | SHIPPED | DELIVERED | CANCELLED
    ship_to_name  VARCHAR(100),
    ship_address  VARCHAR(200),
    ship_city     VARCHAR(80),
    ship_state    VARCHAR(50),
    ship_zip      VARCHAR(20),
    notes         VARCHAR(500),
    created_by    INT            REFERENCES users(user_id),
    created_at    DATETIME       NOT NULL DEFAULT GETDATE(),
    updated_at    DATETIME       NOT NULL DEFAULT GETDATE()
);
GO

-- ------------------------------------------------------------
-- ORDER_ITEMS table (lines)
-- ------------------------------------------------------------
CREATE TABLE order_items (
    item_id       INT IDENTITY(1,1) PRIMARY KEY,
    order_id      INT            NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    INT            NOT NULL REFERENCES products(product_id),
    quantity      INT            NOT NULL DEFAULT 1,
    unit_price    DECIMAL(12,2)  NOT NULL,
    discount_pct  DECIMAL(5,2)   NOT NULL DEFAULT 0.00,
    line_total    AS (quantity * unit_price * (1 - discount_pct / 100)) PERSISTED
);
GO

PRINT 'All tables created successfully.';
GO
