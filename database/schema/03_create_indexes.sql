-- ============================================================
-- Script  : 03_create_indexes.sql
-- Purpose : Indexes, views, and stored procedures
-- ============================================================

USE PBDemoDB;
GO

-- Indexes
CREATE INDEX IX_customers_company    ON customers(company_name);
CREATE INDEX IX_customers_city       ON customers(city, state);
CREATE INDEX IX_products_code        ON products(product_code);
CREATE INDEX IX_products_category    ON products(category_id);
CREATE INDEX IX_orders_customer      ON orders(customer_id);
CREATE INDEX IX_orders_date          ON orders(order_date);
CREATE INDEX IX_orders_status        ON orders(status);
CREATE INDEX IX_order_items_order    ON order_items(order_id);
CREATE INDEX IX_order_items_product  ON order_items(product_id);
GO

-- ------------------------------------------------------------
-- VIEW: v_order_summary — used by order list DataWindows
-- ------------------------------------------------------------
CREATE VIEW v_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.required_date,
    o.shipped_date,
    c.customer_id,
    c.company_name,
    c.contact_name,
    c.phone,
    ISNULL(SUM(oi.line_total), 0)  AS order_total,
    COUNT(oi.item_id)               AS item_count
FROM orders o
JOIN customers c  ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY
    o.order_id, o.order_date, o.status, o.required_date, o.shipped_date,
    c.customer_id, c.company_name, c.contact_name, c.phone;
GO

-- ------------------------------------------------------------
-- VIEW: v_low_stock — dashboard alert view
-- ------------------------------------------------------------
CREATE VIEW v_low_stock AS
SELECT
    p.product_id,
    p.product_code,
    p.product_name,
    pc.category_name,
    p.stock_qty,
    p.reorder_level,
    p.unit_price
FROM products p
LEFT JOIN product_categories pc ON pc.category_id = p.category_id
WHERE p.stock_qty <= p.reorder_level
  AND p.is_active = 1;
GO

-- ------------------------------------------------------------
-- STORED PROCEDURE: sp_dashboard_summary
-- ------------------------------------------------------------
CREATE PROCEDURE sp_dashboard_summary
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM orders WHERE status IN ('PENDING','CONFIRMED'))     AS open_orders,
        (SELECT COUNT(*) FROM orders WHERE status = 'SHIPPED')                   AS orders_shipped,
        (SELECT COUNT(*) FROM v_low_stock)                                        AS low_stock_items,
        (SELECT COUNT(*) FROM customers WHERE is_active = 1)                      AS active_customers,
        (SELECT ISNULL(SUM(order_total),0) FROM v_order_summary
          WHERE order_date >= DATEADD(MONTH,-1,GETDATE()))                        AS sales_last_30d;
END;
GO

-- ------------------------------------------------------------
-- STORED PROCEDURE: sp_customer_orders
-- ------------------------------------------------------------
CREATE PROCEDURE sp_customer_orders
    @customer_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM v_order_summary
    WHERE customer_id = @customer_id
    ORDER BY order_date DESC;
END;
GO

-- ------------------------------------------------------------
-- STORED PROCEDURE: sp_login
-- ------------------------------------------------------------
CREATE PROCEDURE sp_login
    @username     VARCHAR(50),
    @password_hash VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT user_id, username, full_name, role
    FROM users
    WHERE username     = @username
      AND password_hash = @password_hash
      AND is_active    = 1;

    IF @@ROWCOUNT = 1
    BEGIN
        UPDATE users SET last_login = GETDATE() WHERE username = @username;
    END
END;
GO

PRINT 'Indexes, views, and procedures created successfully.';
GO
