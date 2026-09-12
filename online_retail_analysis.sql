-- 1. Explore The Data
select *
from [dbo].[online_retail_II]
-- 2. Checking Missing Values
select count(*) AS Total_rows,
sum(Case when Invoice is NULL or Invoice = '' Then 1 Else 0 END) as Missing_invoice,
sum(Case when StockCode is NULL or StockCode = '' Then 1 Else 0 END) as Missing_StockCode,
sum(Case when Description is NULL or Description = '' Then 1 Else 0 END) as Missing_Description,
sum(Case when Quantity is NULL or Quantity = '' Then 1 Else 0 END) as Missing_Quantity,
sum(Case when InvoiceDate  is NULL or InvoiceDate = '' Then 1 Else 0 END) as Missing_InvoiceDate,
sum(Case when Price is NULL or Price = '' Then 1 Else 0 END) as Missing_Price,
sum(Case when [Customer ID] is NULL or [Customer ID] = '' Then 1 Else 0 END) as Missing_Customer_ID,
sum(Case when Country is NULL or Country = '' Then 1 Else 0 END) as Missing_Country
from [dbo].[online_retail_II]
-- 3. checking Negative values
select count(*) AS Negative_Quantity_Rows
from [dbo].[online_retail_II]
where TRY_CONVERT(INT,Quantity) <0;
-- 4. Checking Invalid Prices
select TRY_CONVERT(DECIMAL(10,2),Price) As Price,
count(*) as rows_count
from [dbo].[online_retail_II]
where TRY_CONVERT(DECIMAL(10,2),Price) <= 0
group by TRY_CONVERT(DECIMAL(10,2),Price)
Order By Price;
-- 5. Investigating Negative Prices
select *
from [dbo].[online_retail_II]
where TRY_CONVERT(DECIMAL(10,2),Price) < 0
order by TRY_CONVERT(DECIMAL(10,2),Price);

-- 6. Checking Data Types / Misaligned Rows

SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN TRY_CONVERT(INT, Quantity) IS NULL
             AND Quantity IS NOT NULL
             AND Quantity <> '' THEN 1 ELSE 0 END) AS Invalid_Quantity,
    SUM(CASE WHEN TRY_CONVERT(DECIMAL(10,2), Price) IS NULL
             AND Price IS NOT NULL
             AND Price <> '' THEN 1 ELSE 0 END) AS Invalid_Price,
    SUM(CASE WHEN TRY_CONVERT(DATETIME, InvoiceDate) IS NULL
             AND InvoiceDate IS NOT NULL
             AND InvoiceDate <> '' THEN 1 ELSE 0 END) AS Invalid_InvoiceDate
FROM [dbo].[online_retail_II];
-- 7. Cleaning: Replace missing Description with 'Unknown'
UPDATE [dbo].[online_retail_II]
SET Description = 'Unknown'
WHERE Description IS NULL OR Description = '';
--Data Analysis--
-- 1. Total Revenue & Total Orders
select
sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price)) as Total_Revenue,
count(DISTINCT Invoice) as Total_Orders
FROM [dbo].[online_retail_II];
-- 2. Average Order Value
select
sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price))/count(distinct Invoice) as Average_Order_Value
FROM [dbo].[online_retail_II];
-- 3. Monthly Sales Trends
select
FORMAT(TRY_CONVERT(Datetime ,InvoiceDate , 1),'yyyy-MM') AS Sales_Month,
sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price)) As Monthly_Revenue
FROM [dbo].[online_retail_II]
Where InvoiceDate Is not null
Group by FORMAT(TRY_CONVERT(Datetime ,InvoiceDate , 1),'yyyy-MM')
order by Sales_Month;
-- 5.Top 5 best-selling products by revenue
select Top 5
StockCode,
Description,
sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price)) As Total_Revenue
FROM [dbo].[online_retail_II]
Where TRY_CONVERT(INT,Quantity)>0
And StockCode NOT IN ('DOT','POST','M','C2','BANK CHARGES')
group by StockCode , Description
order by Total_Revenue Desc;
-- 6. Top Contries by Revenue
select
country,
sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price)) As Total_Revenue
FROM [dbo].[online_retail_II]
Where TRY_CONVERT(INT,Quantity)>0
group by country
order by Total_Revenue DESC;
-- 7. RFM Segmentation
With RFM_Base as (
    select
    [Customer ID],
    DATEDIFF(day, MAX(TRY_CONVERT(Datetime, InvoiceDate, 1)),
        (select MAX(TRY_CONVERT(Datetime, InvoiceDate, 1)) from [dbo].[online_retail_II])
    ) as Recency,
    count(distinct Invoice) AS Frequency,
    sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price)) AS Monetary
    FROM [dbo].[online_retail_II]
    where [Customer ID] is not null
    And [Customer ID] <> ''
    and TRY_CONVERT(INT,Quantity)>0
    Group by [Customer ID]
),
RFM_Scores as (
    select
    [Customer ID],
    Recency, Frequency, Monetary,
    NTILE(5) OVER (ORDER BY Recency DESC) as R_Score,
    NTILE(5) OVER (ORDER BY Frequency ASC) as F_Score,
    NTILE(5) OVER (ORDER BY Monetary ASC) as M_Score
    from RFM_Base
)
select
[Customer ID], Recency, Frequency, Monetary,
R_Score, F_Score, M_Score,
(R_Score + F_Score + M_Score) as RFM_Total,
Case
    When R_Score >= 4 And F_Score >= 4 And M_Score >= 4 Then 'Champions'
    When R_Score >= 3 And F_Score >= 3 And M_Score >= 3 Then 'Loyal Customers'
    When R_Score >= 4 And F_Score <= 2 Then 'New Customers'
    When R_Score <= 2 And F_Score >= 3 And M_Score >= 3 Then 'At Risk'
    When R_Score <= 2 And F_Score <= 2 And M_Score <= 2 Then 'Lost'
    Else 'Others'
End as Customer_Segment
from RFM_Scores
Order by RFM_Total Desc;
-- RFM Segment Summary
With RFM_Base as (
    select
    [Customer ID],
    DATEDIFF(day, MAX(TRY_CONVERT(Datetime, InvoiceDate, 1)),
        (select MAX(TRY_CONVERT(Datetime, InvoiceDate, 1)) from [dbo].[online_retail_II])
    ) as Recency,
    count(distinct Invoice) AS Frequency,
    sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price)) AS Monetary
    FROM [dbo].[online_retail_II]
    where [Customer ID] is not null
    And [Customer ID] <> ''
    and TRY_CONVERT(INT,Quantity)>0
    Group by [Customer ID]
),
RFM_Scores as (
    select
    [Customer ID],
    Recency, Frequency, Monetary,
    NTILE(5) OVER (ORDER BY Recency DESC) as R_Score,
    NTILE(5) OVER (ORDER BY Frequency ASC) as F_Score,
    NTILE(5) OVER (ORDER BY Monetary ASC) as M_Score
    from RFM_Base
),
RFM_Segmented as (
    select
    [Customer ID], Monetary,
    Case
        When R_Score >= 4 And F_Score >= 4 And M_Score >= 4 Then 'Champions'
        When R_Score >= 3 And F_Score >= 3 And M_Score >= 3 Then 'Loyal Customers'
        When R_Score >= 4 And F_Score <= 2 Then 'New Customers'
        When R_Score <= 2 And F_Score >= 3 And M_Score >= 3 Then 'At Risk'
        When R_Score <= 2 And F_Score <= 2 And M_Score <= 2 Then 'Lost'
        Else 'Others'
    End as Customer_Segment
    from RFM_Scores
)
select
Customer_Segment,
count(*) as Num_Customers,
SUM(Monetary) as Segment_Revenue,
AVG(Monetary) as Avg_Customer_Value
from RFM_Segmented
group by Customer_Segment
order by Segment_Revenue desc;
-- 8. Order Cancellation Rate
select
count( distinct invoice) as Total_orders,
Count( distinct case when Invoice like 'c%' Then Invoice end) As cancelled_Orders,
Cast(count(distinct case when Invoice like 'c%' Then Invoice end)*100.0/ count(distinct Invoice)
As Decimal(5,2))AS Cancellation_Rate_Percent
 FROM [dbo].[online_retail_II]

--VIEW RFM SEGMENTATION

CREATE VIEW vw_RFM_Segmentation AS
With RFM_Base as (
    select
    [Customer ID],
    DATEDIFF(day, MAX(TRY_CONVERT(Datetime, InvoiceDate, 1)),
        (select MAX(TRY_CONVERT(Datetime, InvoiceDate, 1)) from [dbo].[online_retail_II])
    ) as Recency,
    count(distinct Invoice) AS Frequency,
    sum(TRY_CONVERT(INT, Quantity)*TRY_CONVERT(DECIMAL(10,2), Price)) AS Monetary
    FROM [dbo].[online_retail_II]
    where [Customer ID] is not null
    And [Customer ID] <> ''
    and TRY_CONVERT(INT,Quantity)>0
    Group by [Customer ID]
),
RFM_Scores as (
    select
    [Customer ID],
    Recency, Frequency, Monetary,
    NTILE(5) OVER (ORDER BY Recency DESC) as R_Score,
    NTILE(5) OVER (ORDER BY Frequency ASC) as F_Score,
    NTILE(5) OVER (ORDER BY Monetary ASC) as M_Score
    from RFM_Base
)
select
[Customer ID], Recency, Frequency, Monetary,
R_Score, F_Score, M_Score,
(R_Score + F_Score + M_Score) as RFM_Total,
Case
    When R_Score >= 4 And F_Score >= 4 And M_Score >= 4 Then 'Champions'
    When R_Score >= 3 And F_Score >= 3 And M_Score >= 3 Then 'Loyal Customers'
    When R_Score >= 4 And F_Score <= 2 Then 'New Customers'
    When R_Score <= 2 And F_Score >= 3 And M_Score >= 3 Then 'At Risk'
    When R_Score <= 2 And F_Score <= 2 And M_Score <= 2 Then 'Lost'
    Else 'Others'
End as Customer_Segment
from RFM_Scores;

-- Data view 
DROP VIEW IF EXISTS vw_Sales_Clean;
GO

CREATE VIEW vw_Sales_Clean_2 AS
SELECT
    Invoice,
    StockCode,
    Description,
    TRY_CONVERT(INT, Quantity) AS Quantity,
    TRY_CONVERT(DATETIME, InvoiceDate, 1) AS InvoiceDate,
    TRY_CONVERT(DECIMAL(10,2), Price) AS Price,
    [Customer ID],
    Country,
    TRY_CONVERT(INT, Quantity) * TRY_CONVERT(DECIMAL(10,2), Price) AS Revenue
FROM [dbo].[online_retail_II]
WHERE TRY_CONVERT(INT, Quantity) IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), Price) IS NOT NULL;
GO
