# Online_Retail_II
SQL-based data analysis and customer segmentation (RFM) on the Online Retail II dataset to uncover sales trends and customer behavior.
## 1. Business Questions
- What is the total revenue and total number of orders? 
- What is the Average Order Value (AOV)? 
- What are the monthly sales trends?
- What are the top 5 best-selling products by revenue? 
- Which countries generate the highest revenue? 
- How are customers segmented using RFM? 
- What is the overall order cancellation rate? 
## 2. Data Exploration & Cleaning
Explored the dataset (541,910 total rows) to assess quality before analysis:
| Check | Result |
|---|---|
| Missing Customer ID | 135,080 rows (~25%) |
| Negative Quantity Rows | 10,624 (mostly returns/cancellations) |
| Invalid Prices (≤ 0) | 2,521 rows (2 negative "bad debt" adjustments, 2,519 zero-price rows) |

- All other fields (Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Country) had no missing values.

### Cleaning actions taken:
- Excluded cancelled orders (Invoice starting with 'C') from revenue calculations.
- Filtered out rows with negative or zero Quantity/Price using TRY_CONVERT before revenue and RFM calculations.
- Replaced missing product descriptions with 'Unknown'.
- Excluded rows with missing/blank Customer ID from RFM analysis, since RFM requires a valid customer identity.
