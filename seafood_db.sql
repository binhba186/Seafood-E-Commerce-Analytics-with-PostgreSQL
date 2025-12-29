SET search_path = hqtcsdl;

-- 1. Tỷ lệ phần trăm lượt truy cập có sự kiện mua hàng là bao nhiêu?

SELECT 
    ROUND(COUNT(DISTINCT CASE WHEN ei.event_name = 'Purchase' 
				THEN e.visit_id END) * 100.0/ COUNT(DISTINCT visit_id), 2) 
				AS purchase_percent
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type;

-- 2. Tỷ lệ phần trăm lượt truy cập xem trang thanh toán nhưng không có sự kiện mua
-- hàng là bao nhiêu?

SELECT ROUND(COUNT(DISTINCT e.visit_id)* 100.0 / (SELECT COUNT(DISTINCT visit_id) 
												   FROM events), 2)
												   AS checkout_no_buy_percent
FROM events e
JOIN page_hierarchy p ON e.page_id = p.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE p.page_name = 'Checkout'
	  AND ei.event_name = 'Page View'
	  AND e.visit_id NOT IN ( SELECT DISTINCT e2.visit_id
	  						   FROM events e2
							   JOIN event_identifier ei2 ON e2.event_type = ei2.event_type
							   WHERE ei2.event_name = 'Purchase'
							   );
							 
-- 3. 3 trang có số lượt xem nhiều nhất là những trang nào?

SELECT ph.page_name,
		COUNT(*) AS highest_views
FROM page_hierarchy ph
JOIN events e ON ph.page_id = e.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Page View'
GROUP BY ph.page_name
ORDER BY highest_views DESC
LIMIT 3;

-- 4. Số lượt xem và số lần thêm vào giỏ hàng cho từng danh mục sản phẩm là bao
-- nhiêu?

SELECT ph.product_category,
		COUNT(CASE WHEN ei.event_name = 'Page View' THEN 1 END) AS view_count,
		COUNT(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 END) AS add_to_cart
FROM page_hierarchy ph
JOIN events e ON ph.page_id = e.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE  ph.product_category IS NOT NULL
GROUP BY  ph.product_category;

-- 5. 3 sản phẩm có số lượt mua nhiều nhất là gì?

WITH purchased_id AS(
	SELECT DISTINCT e.visit_id 
	FROM events e
	JOIN event_identifier ei ON e.event_type = ei.event_type
	WHERE ei.event_name = 'Purchase'
)
SELECT ph.page_name AS products,
		COUNT(*) AS purchased
FROM page_hierarchy ph
JOIN events e ON ph.page_id = e.page_id
JOIN event_identifier ei ON e.event_type = ei.event_type
JOIN purchased_id pi ON e.visit_id = pi.visit_id
WHERE  ei.event_name = 'Add to Cart'
		AND ph.product_id IS NOT NULL
GROUP BY ph.page_name 
ORDER BY purchased DESC
LIMIT 3;


-- 6. Sử dụng một truy vấn SQL duy nhất - tạo một bảng đầu ra mới có các chi tiết sau:
-- - Mỗi sản phẩm được xem bao nhiêu lần?
-- - Mỗi sản phẩm được thêm vào giỏ hàng bao nhiêu lần?
-- - Mỗi sản phẩm được thêm vào giỏ hàng nhưng không được mua (bị bỏ rơi) bao nhiêu lần?
-- - Mỗi sản phẩm được mua bao nhiêu lần?

CREATE TABLE product_events AS(
	WITH purchased_id AS(
	SELECT DISTINCT e.visit_id 
	FROM events e
	JOIN event_identifier ei ON e.event_type = ei.event_type
	WHERE ei.event_name = 'Purchase'
	)
	SELECT 	ph.page_name AS product_name,
			COUNT(CASE WHEN ei.event_name = 'Page View' THEN 1 END) AS product_views,
			COUNT(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 END) AS add_to_cart,
			COUNT(CASE WHEN ei.event_name = 'Add to Cart' 
					   AND pi.visit_id IS NULL THEN 1 END) AS add_cart_no_purchase,
			COUNT(CASE WHEN ei.event_name = 'Add to Cart' 
					   AND  pi.visit_id IS NOT NULL THEN 1 END) AS purchased
	FROM page_hierarchy ph
	JOIN events e ON ph.page_id = e.page_id
	JOIN event_identifier ei ON e.event_type = ei.event_type
	LEFT JOIN purchased_id pi ON e.visit_id = pi.visit_id
	WHERE ph.product_id IS NOT NULL
	GROUP BY ph.page_name
);
	
select * from product_events

-- 7. Hãy tạo một bảng khác để tổng hợp thêm dữ liệu tương tự như câu 6 
-- nhưng lần này là cho từng danh mục sản phẩm thay vì từng sản phẩm riêng lẻ.

CREATE TABLE category_events AS(
	SELECT 	ph.product_category AS product_category,
			SUM(pe.product_views) AS category_views,
			SUM(pe.add_to_cart) AS add_to_cart,
			SUM(pe.add_cart_no_purchase) AS add_cart_no_purchase,
			SUM(pe.purchased) AS purchased
	FROM page_hierarchy ph
	JOIN product_events pe ON ph.page_name = pe.product_name
	WHERE ph.product_id IS NOT NULL
	GROUP BY ph.product_category
);

select * from category_events

-- Sử dụng 2 bảng mới từ câu 6 và câu 7 của bạn - trả lời các câu hỏi sau:
-- 8. Sản phẩm nào có nhiều lượt xem, thêm vào giỏ hàng và mua nhất?

SELECT 	(SELECT product_name FROM product_events 
		 ORDER BY product_views DESC LIMIT 1) AS highest_views,
		(SELECT product_name FROM product_events 
		 ORDER BY add_to_cart DESC LIMIT 1) AS highest_add_to_cart,
		(SELECT product_name FROM product_events 
		 ORDER BY purchased DESC LIMIT 1) AS highest_purchased;

-- 9. Sản phẩm nào có khả năng bị bỏ rơi (thêm vào giỏ hàng nhưng không được mua) nhiều nhất?

SELECT product_name 
FROM product_events 
ORDER BY add_cart_no_purchase DESC 
LIMIT 1;

-- 10.Sản phẩm nào có tỷ lệ phần trăm lượt xem thành mua (view to purchase) cao nhất?

SELECT  product_name,
		ROUND(purchased * 100.0 / product_views, 2) AS view_to_purchase_percent
FROM product_events
ORDER BY view_to_purchase_percent DESC
LIMIT 1;

-- 11.Tỷ lệ chuyển đổi trung bình từ lượt xem thành thêm vào giỏ hàng 
-- (from view to cart add) là bao nhiêu?

SELECT ROUND(SUM(add_to_cart)/SUM(category_views), 3) 
			AS avg_view_to_add_cart_rate
FROM category_events;

-- 12.Tỷ lệ chuyển đổi trung bình từ thêm vào giỏ hàng thành mua 
-- (from cart add to purchase) là bao nhiêu?

SELECT ROUND(SUM(purchased)/SUM(add_to_cart), 3) 
			AS avg_view_to_add_cart_rate
FROM category_events;

