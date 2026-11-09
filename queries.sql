--Section A
--1
select * from customers;

--2
select customer_name,city,customer_segment from customers;

--3
select * from customers where city = 'Nairobi';

--4
select * from customers where registration_date > '2025-01-01';

--5
select distinct city from customers;

--6
select * from orders  order by order_date desc limit 10;

--7
select * from orders where unit_price > 10000;

--8
select * from customers where customer_name like 'A%';

--9
select * from orders where quantity between 2 and 5;

--10
select * from orders where payment_method = 'M-Pesa';


--Section B

--11
select count(*) from customers;

--12
select count(*) from orders;

--13
--select count(*) from orders where order_status = 'Completed'

--13
select sum(quantity* unit_price * (1 - discount/100)) as completed_order_revenue from orders where order_status = 'Completed';

--14
select avg(quantity* unit_price) as completed_order_revenue from orders where order_status = 'Completed';

--15
select max(unit_price) from orders;

select min(unit_price) from orders;

--16
select 
	product_name,
	product_category,
	sum(quantity*unit_price * (1-discount/100)) as total_revenue
from orders
where order_status = 'Completed'
group by product_name,product_category
order by total_revenue desc;

--17
select 
	city,
	count(*) as no_of_customers
from customers 
group by city;

--18
select 
	product_name,
	sum(quantity) as quantity_sold
from orders group by product_name;


--19
SELECT
    product_category,
    SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
FROM orders
GROUP BY
    product_category
HAVING
    SUM(quantity * unit_price * (1 - discount / 100.0)) > 100000
ORDER BY total_revenue DESC;


--20
SELECT
    COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) AS cancelled_orders,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS cancelled_order_percentage
FROM orders;

--section C
-- 21

select 
	c.customer_name,
	c.customer_segment,
	o.order_id,
	o.product_name,
	o.product_category
from customers c left join orders o on c.customer_id=o.customer_id;

--22
SELECT
    a.customer_name,
    SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
FROM customers a left join orders o on a.customer_id=o.customer_id
WHERE order_status = 'Completed'
GROUP BY a.customer_name
ORDER BY total_spending DESC;

--23
select 
	c.customer_name,
	o.order_id
from customers c left join orders o on c.customer_id=o.customer_id
where o.order_id is null;


--24
SELECT
    c.customer_name,
    SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
FROM customers c left join orders o on c.customer_id=o.customer_id
where o.order_status = 'Completed'
GROUP BY c.customer_name
ORDER BY total_spending desc
LIMIT 10;

--25
SELECT
    c.city,
    SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;

--26
select 
	c.customer_name,
	count(*) as total_orders
from customers c left join orders o on c.customer_id=o.customer_id
group by c.customer_name
having count(*)>5
order by total_orders desc;

--27
SELECT
    c.customer_segment,
    AVG(customer_spending) AS average_customer_spending
FROM (
    SELECT
        c.customer_id,
        c.customer_segment,
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS customer_spending
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.customer_segment
) c
GROUP BY c.customer_segment
ORDER BY average_customer_spending DESC;

--28
SELECT
    o.product_category,
    SUM(o.quantity) AS total_quantity_sold
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE c.customer_segment = 'VIP'
GROUP BY o.product_category
ORDER BY total_quantity_sold DESC
FETCH FIRST 1 ROW ONLY;

--SECTION D
--29

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS total_spending
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) >
(
    SELECT AVG(customer_spending)
    FROM (
        SELECT
            SUM(quantity * unit_price * (1 - discount / 100)) AS customer_spending
        FROM orders
        GROUP BY customer_id
    )
)
ORDER BY total_spending DESC;

--30
SELECT
    distinct product_name,
    product_category,
    unit_price
FROM orders
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM orders
)
ORDER BY unit_price DESC;

--31
WITH monthly_revenue AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS revenue_month,
        SUM(quantity * unit_price * (1 - discount / 100)) AS total_revenue
    FROM orders
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    revenue_month,
    total_revenue
FROM monthly_revenue
ORDER BY total_revenue DESC
FETCH FIRST 3 ROWS ONLY;

--32
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.product_category) AS category_count
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY category_count DESC;

--33
WITH category_performance AS (
    SELECT
        product_category,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue,
        SUM(quantity * cost_price) AS total_cost
    FROM orders
    GROUP BY product_category
)
SELECT
    product_category,
    ROUND(total_revenue::numeric, 2) AS revenue,
    ROUND(total_cost::numeric, 2) AS cost,
    ROUND((total_revenue - total_cost)::numeric, 2) AS profit,
    ROUND(
        ((total_revenue - total_cost) / NULLIF(total_revenue, 0) * 100)::numeric,
        2
    ) AS profit_margin_percentage
FROM category_performance
ORDER BY profit DESC;

--34
WITH customer_latest_orders AS (
    SELECT
        customer_id,
        MAX(order_date) AS latest_completed_order
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
dataset_latest_order AS (
    SELECT
        MAX(order_date) AS latest_order_date
    FROM orders
)
SELECT
    c.customer_id,
    c.customer_name,
    clo.latest_completed_order,
    dlo.latest_order_date,
    dlo.latest_order_date - clo.latest_completed_order AS days_since_last_order
FROM customers c
INNER JOIN customer_latest_orders clo
    ON c.customer_id = clo.customer_id
CROSS JOIN dataset_latest_order dlo
WHERE dlo.latest_order_date - clo.latest_completed_order > 90
ORDER BY days_since_last_order DESC;

--SECTION E
--35
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spending
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spending::numeric, 2) AS total_spending,
    RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM customer_spending
ORDER BY spending_rank;

--36
SELECT
    customer_id,
    order_id,
    order_date,
    order_status,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date DESC
    ) AS order_recency_rank
FROM orders
ORDER BY customer_id, order_recency_rank;


--37
WITH product_revenue AS (
    SELECT
        product_category,
        product_name,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    GROUP BY
        product_category,
        product_name
)
SELECT
    product_category,
    product_name,
    ROUND(total_revenue::numeric, 2) AS total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY product_category
        ORDER BY total_revenue DESC
    ) AS product_rank
FROM product_revenue
ORDER BY
    product_category,
    product_rank;

--38
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS revenue_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    TO_CHAR(revenue_month, 'YYYY-MM') AS revenue_month,
    ROUND(total_revenue::numeric, 2) AS monthly_revenue,
    ROUND(
        SUM(total_revenue) OVER (
            ORDER BY revenue_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )::numeric,
        2
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY revenue_month;

--39
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS revenue_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_comparison AS (
    SELECT
        revenue_month,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY revenue_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    TO_CHAR(revenue_month, 'YYYY-MM') AS revenue_month,
    ROUND(total_revenue::numeric, 2) AS current_month_revenue,
    ROUND(previous_month_revenue::numeric, 2) AS previous_month_revenue,
    ROUND(
        (total_revenue - previous_month_revenue)::numeric, 2
    ) AS revenue_difference,
    ROUND(
        (
            (total_revenue - previous_month_revenue)
            / NULLIF(previous_month_revenue, 0) * 100
        )::numeric, 2
    ) AS revenue_growth_percentage
FROM revenue_comparison
ORDER BY revenue_month;

--40

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS revenue_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_comparison AS (
    SELECT
        revenue_month,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY revenue_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    TO_CHAR(revenue_month, 'YYYY-MM') AS revenue_month,
    ROUND(total_revenue::numeric, 2) AS current_month_revenue,
    ROUND(previous_month_revenue::numeric, 2) AS previous_month_revenue,
    ROUND(
        (
            (total_revenue - previous_month_revenue)
            / NULLIF(previous_month_revenue, 0) * 100
        )::numeric, 2
    ) AS mom_growth_percentage
FROM revenue_comparison
ORDER BY revenue_month;


--41
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(
            o.quantity * o.unit_price * (1 - o.discount / 100.0)
        ) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
),
customer_groups AS (
    SELECT
        customer_id,
        customer_name,
        total_spending,
        NTILE(4) OVER (
            ORDER BY total_spending DESC
        ) AS spending_group
    FROM customer_spending
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spending::numeric, 2) AS total_spending,
    spending_group,
    CASE
        WHEN spending_group = 1 THEN 'High Spenders'
        WHEN spending_group = 2 THEN 'Upper-Middle Spenders'
        WHEN spending_group = 3 THEN 'Lower-Middle Spenders'
        WHEN spending_group = 4 THEN 'Low Spenders'
    END AS spending_category
FROM customer_groups
ORDER BY spending_group, total_spending DESC;

--42
WITH category_revenue AS (
    SELECT
        product_category,
        SUM(
            quantity * unit_price * (1 - discount / 100.0)
        ) AS total_revenue
    FROM orders
    GROUP BY product_category
)
SELECT
    product_category,
    ROUND(total_revenue::numeric, 2) AS category_revenue,
    ROUND(
        SUM(total_revenue) OVER ()::numeric, 2
    ) AS overall_revenue,
    ROUND(
        (
            total_revenue / NULLIF(SUM(total_revenue) OVER (), 0) * 100
        )::numeric, 2
    ) AS revenue_share_percentage
FROM category_revenue
ORDER BY revenue_share_percentage DESC;

--SECTION F
--43

CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT
    DATE_TRUNC('month', order_date)::date AS sales_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue,
    SUM(quantity * cost_price) AS total_cost,
    SUM(quantity * unit_price * (1 - discount / 100.0))
        - SUM(quantity * cost_price) AS total_profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

--44
CREATE OR REPLACE FUNCTION get_customer_revenue(p_customer_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_revenue NUMERIC;
BEGIN
    SELECT
        COALESCE(
            SUM(quantity * unit_price * (1 - discount / 100.0)),
            0
        )
    INTO v_total_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';

    RETURN v_total_revenue;
END;
$$;

--45
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(
            SUM(
                o.quantity * o.unit_price * (1 - o.discount / 100.0)
            ), 0
        ) AS total_spending
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
       AND o.order_status = 'Completed'
    GROUP BY
        c.customer_id,
        c.customer_name
),
customer_ranking AS (
    SELECT
        customer_id,
        customer_name,
        total_spending,
        NTILE(3) OVER (
            ORDER BY total_spending DESC
        ) AS spending_group
    FROM customer_spending
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spending::numeric, 2) AS total_spending,
    CASE
        WHEN spending_group = 1 THEN 'High Value'
        WHEN spending_group = 2 THEN 'Medium Value'
        WHEN spending_group = 3 THEN 'Low Value'
    END AS customer_segment
FROM customer_ranking
ORDER BY total_spending DESC;

--46
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(
        SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0))::numeric,
        2
    ) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 5;


	

