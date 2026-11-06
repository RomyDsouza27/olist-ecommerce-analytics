# E-Commerce Customer Behaviour & Retention Analytics
## Business Insights Report

### 1. Project Overview

This project analyzes the Olist Brazilian E-Commerce Public Dataset to understand e-commerce sales performance, customer purchasing behaviour, retention patterns, product performance, and seller performance.

The analysis uses PostgreSQL for data storage and SQL analysis, Python for data exploration and cleaning, and Power BI for interactive dashboard development.

**Analysis period:** September 2016 – August 2018  
**Dataset:** Olist Brazilian E-Commerce Public Dataset

### 2. Executive Business Summary

| Business KPI | Result |
|---|---:|
| Total Orders | 99,441 |
| Delivered Orders | 96,478 |
| Delivery Rate | 97.02% |
| Product Revenue | R$13,221,498.11 |
| Freight Revenue | R$2,198,275.64 |
| Average Order Value | R$137.04 |
| Unique Customers | 93,358 |
| Repeat Customers | 2,801 |
| Repeat Customer Rate | 3.00% |

*Revenue represents delivered-order product item prices, excluding freight. It is not profit.*

### 3. Key Business Insights

#### 3.1 Sales Performance

- The dataset contains 99,441 orders, of which 96,478 were delivered.
- Delivered product revenue reached approximately R$13.22 million.
- Freight revenue contributed approximately R$2.20 million.
- Average delivered order value was approximately R$137.04.
- São Paulo was the largest customer-state market, generating approximately R$5.07 million in product revenue.

**Business implication:** São Paulo is a major revenue market. The business can investigate regional demand and use this market as a benchmark for expansion strategies.

#### 3.2 Customer Retention

- The analysis identified 93,358 unique customers.
- Only 2,801 customers made more than one purchase.
- The repeat customer rate was approximately 3.00%.
- Most customers purchased only once during the observed period.

**Business implication:** Customer retention is an important improvement opportunity. Targeted follow-up campaigns, loyalty incentives, personalized recommendations, and post-purchase engagement could encourage repeat purchases.

#### 3.3 RFM Customer Segmentation

RFM analysis was performed using Recency, Frequency, and Monetary value.

| Customer Segment | Customers | Percentage |
|---|---:|---:|
| At Risk | 18,372 | 19.68% |
| Need Attention | 15,266 | 16.35% |
| Champions | 15,053 | 16.12% |
| Potential Loyalists | 14,512 | 15.54% |
| Hibernating | 11,258 | 12.06% |
| Loyal Customers | 7,647 | 8.19% |
| Others | 3,814 | 4.09% |
| Recent Customers | 3,810 | 4.08% |
| Promising | 3,626 | 3.88% |

**Key findings:**

- At Risk customers represent approximately 19.68% of analyzed customers and R$4.37 million in historical product revenue.
- Champions represent approximately 16.12% of customers and R$4.12 million in historical product revenue.
- Hibernating customers represent another segment that may benefit from re-engagement campaigns.

**Business implication:** Prioritize retention campaigns for high-value At Risk customers, while providing loyalty benefits and personalized offers to Champions.

RFM segments are descriptive historical classifications, not predictions of future churn.

#### 3.4 Cohort Retention Analysis

Customers were grouped by their first delivered purchase month. Subsequent delivered purchases were tracked by calendar month.

Weighted retention results:

| Month After First Purchase | Weighted Retention |
|---|---:|
| Month 1 | 0.48% |
| Month 2 | 0.34% |
| Month 3 | 0.25% |

**Business implication:** The low subsequent-month purchase rate highlights an opportunity to improve customer engagement and repeat purchasing.

These results measure calendar-month repeat purchasing, not exact 30-day retention.

#### 3.5 Product Category Performance

The leading product categories by delivered product revenue were:

| Product Category | Revenue |
|---|---:|
| Health & Beauty | R$1,233,131.72 |
| Watches & Gifts | R$1,166,176.98 |
| Bed, Bath & Table | R$1,023,434.76 |

**Business implication:** These categories represent important revenue contributors. The business can investigate inventory availability, marketing investment, customer demand, and cross-selling opportunities.

#### 3.6 Delivery Performance

| Delivery Status | Orders | Percentage |
|---|---:|---:|
| On Time | 88,649 | 89.15% |
| Late | 7,827 | 7.87% |
| Not Delivered | 2,965 | 2.98% |

**Business implication:** Delivery performance is relatively strong, but late and undelivered orders represent opportunities to improve logistics coordination and customer satisfaction.

### 4. Business Recommendations

1. **Improve customer retention:** Introduce post-purchase engagement, loyalty programs, and personalized offers.
2. **Re-engage At Risk customers:** Prioritize high-value customers who have not purchased recently.
3. **Strengthen regional strategy:** Use São Paulo's strong sales performance to understand successful regional demand patterns.
4. **Optimize product category strategy:** Monitor leading categories and identify opportunities for cross-selling.
5. **Improve delivery operations:** Investigate late and undelivered orders to identify logistical bottlenecks.
6. **Monitor performance regularly:** Track sales, customer retention, delivery performance, and category revenue through interactive dashboards.

### 5. Tools and Technologies

- PostgreSQL – Database management and SQL analytics
- Python – Data exploration and cleaning
- Pandas and NumPy – Data manipulation
- Power BI – Interactive dashboards and visualization
- DAX – Measures and business KPIs
- Git and GitHub – Version control and project documentation

### 6. Project Limitations

- The dataset covers historical transactions from 2016 to 2018.
- Product revenue does not represent profit because costs and operating expenses are not included.
- RFM segments are rule-based historical classifications.
- Cohort retention measures subsequent calendar-month purchases.
- The analysis describes historical customer behaviour and does not predict future customer churn.

### 7. Conclusion

The analysis highlights strong historical sales performance alongside a significant customer retention opportunity. Although the business generated approximately R$13.22 million in delivered product revenue, only 3% of unique customers made repeat purchases.

Combining SQL analytics, RFM segmentation, cohort analysis, and Power BI visualization provides a structured way to identify business opportunities and support data-driven decision-making.

### 8. Dataset Attribution

Dataset: Olist Brazilian E-Commerce Public Dataset  
Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce  
License: CC BY-NC-SA 4.0

This project is intended for educational and portfolio purposes. Dataset attribution and license terms must be respected.
