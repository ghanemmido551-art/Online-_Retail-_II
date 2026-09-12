# Online_Retail_II
SQL-based data analysis and customer segmentation (RFM) on the Online Retail II dataset to uncover sales trends and customer behavior.

## Tools Used
- SQL Server — Data cleaning, exploration, and analysis
- Power BI — Interactive dashboard and RFM customer segmentation
- DAX — Custom measures (Revenue, Cancellation Rate, AOV)

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
- Included cancelled orders (Invoice starting with 'C') in revenue calculations,
  since their negative Quantity naturally offsets returns and yields Net Revenue.
- Filtered out rows with negative or zero Quantity/Price using TRY_CONVERT before revenue and RFM calculations.
- Replaced missing product descriptions with 'Unknown'.
- Excluded rows with missing/blank Customer ID from RFM analysis, since RFM requires a valid customer identity.
## 3. Analysis & Key Insights
- Total Revenue & Orders: Net revenue reached $9,747,765.93 across 25,900 unique orders.
- Average Order Value (AOV): ~$376.36 per order.
- Cancellation Rate: 14.81% of orders (3,836 out of 25,900) were cancelled.
- Monthly Trend: Revenue grew steadily from mid-year, peaking in November 2011 at ~$1.46M — consistent with pre-holiday shopping behavior.
- Top Market: The United Kingdom dominates sales, generating $8.19M (~84% of total revenue), followed by Netherlands, EIRE, Germany, and France.
- Product Performance: The best-selling product by quantity was "PAPER CRAFT, LITTLE BIRDIE" with over 80,000 units sold.
- Customer Segmentation (RFM): Out of 4,372 unique customers, segments break down as:
  - Champions: 998
  - Others: 853
  - Lost: 795
  - Loyal Customers: 674
  - At Risk: 541
  - New Customers: 478

    ## 4. Dashboard Preview

### Sales Overview




<img width="1003" height="557" alt="Screenshot (20)" src="https://github.com/user-attachments/assets/c42e8a7a-c936-4c71-8b6c-606c30b3649e" />

---

### Products & Countries


<img width="990" height="549" alt="Screenshot (18)" src="https://github.com/user-attachments/assets/5c73d0be-7ba4-4315-b0c1-85d71ca36b57" />



---

### Customer Segmentation (RFM)



<img width="989" height="550" alt="Screenshot (19)" src="https://github.com/user-attachments/assets/65e4455b-e149-4b58-ab7e-caf107cf171f" />

---
## 5. Recommendations

- Reduce cancellations: With a 14.81% cancellation rate, investigate the top cancelled products/countries to identify recurring quality or fulfillment issues.
- Retention focus: 795 customers fall into the "Lost" segment — consider a win-back campaign targeting this group before they're permanently gone.
- Geographic expansion: Revenue is heavily concentrated in the UK (~84%). Diversifying marketing efforts toward the Netherlands and Germany (2nd and 4th highest revenue) could reduce market dependency.
- Reward loyalty: "Champions" (998 customers) drive disproportionate value — a loyalty program could increase retention in this segment further.
