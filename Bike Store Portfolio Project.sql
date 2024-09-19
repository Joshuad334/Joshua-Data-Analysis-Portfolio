USE [BikeStores]
GO

/****** Object:  StoredProcedure [dbo].[MainSalesReport]    Script Date: 9/19/2024 12:21:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Joshua Davis
-- Create date: 9-19-2024
-- Description:	This Report is the main sales report for the bike store.
-- It details revenue by customer, sales rep, units sold, customer location, and store name. 
-- =============================================
CREATE PROCEDURE [dbo].[MainSalesReport] @ORDID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ORD.order_id
		,CONCAT_WS(CUS.first_name, ' ', CUS.last_name) AS Name
		,CUS.city AS City
		,CUS.STATE AS STATE
		,ORD.order_date AS OrderDate
		,SUM(ITE.quantity) AS TotalUnits
		,SUM(ITE.quantity * ITE.list_price) AS Revenue
		,product_name AS ProductName
		,CAT.category_name AS CategoryName
		,store_name AS StoreName
		,CONCAT_WS(STA.first_name, ' ', STA.last_name) AS SalesRep
	FROM sales.orders AS ORD
	INNER JOIN sales.customers AS CUS
		ON ORD.customer_id = CUS.customer_id
	INNER JOIN sales.order_items AS ITE
		ON ITE.order_id = ORD.order_id
	INNER JOIN production.products
		ON products.product_id = ITE.product_id
	INNER JOIN production.categories AS CAT
		ON CAT.category_id = products.category_id
	INNER JOIN sales.stores
		ON stores.store_id = ORD.store_id
	INNER JOIN sales.staffs AS STA
		ON STA.staff_id = ORD.staff_id

	GROUP BY CONCAT_WS(CUS.first_name, ' ', CUS.last_name)
		,CONCAT_WS(STA.first_name, ' ', STA.last_name)
		,ORD.order_id
		,CUS.city
		,CUS.STATE
		,ORD.order_date
		,product_name
		,CAT.category_name
		,store_name
END
GO

