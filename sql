WITH spending_diff AS 
	(SELECT 
	customerid,
	dollar_spent,
	COALESCE (LEAD(dollar_spent,1) OVER (PARTITION BY country ORDER BY dollar_spent DESC),0) AS next_highest_spender,
	country
	FROM 
		(SELECT 
		c.customerid,
		SUM(od.unitprice * od.quantity) AS dollar_spent,
		c.country
		FROM customers c
		INNER JOIN orders o ON c.customerid = o.customerid
		INNER JOIN orderdetails od ON od.orderid = o.orderid
		GROUP BY c.customerid
		ORDER BY c.country, dollar_spent DESC) AS baseline) 

SELECT 
*,
ROUND((dollar_spent - next_highest_spender)::numeric,2) AS difference 
FROM spending_diff
