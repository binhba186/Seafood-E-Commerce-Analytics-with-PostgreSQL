# Seafood-E-Commerce-Analytics-with-PostgreSQL

## 1. Project Overview

This project is a **PostgreSQL case study** focused on analyzing user behavior and sales performance for a **seafood e-commerce website**.  
The website sells premium seafood products across multiple categories and tracks detailed user interactions such as **page views**, **cart additions**, and **purchases**.

The main objectives of this project are to:

- Design and populate a relational database  
- Analyze customer journeys and conversion funnels  
- Generate business insights using SQL queries  


## 2. Business Context

The seafood e-commerce platform offers the following products:

- **Fish**: Salmon, Kingfish, Tuna  
- **Luxury**: Russian Caviar, Black Truffle  
- **Shellfish**: Abalone, Lobster, Crab, Oyster  

Each user visit is tracked using browser cookies, and all interactions are stored as events.  
Marketing campaigns are also recorded to evaluate advertising effectiveness.


## 3. Database Setup

### Database Name `seafood_db`

### Setup Steps

1. Create a PostgreSQL database named `seafood_db`
2. Import the provided `casestudy.sql` file into the database
3. Verify that all tables and data are successfully loaded

## 4. Data Model & Table Descriptions

![Seafood Database ERD](seafood_erd.png)

The diagram above illustrates the relationship between users, events, products, and campaigns.

### 4.1 `page_hierarchy`

Stores information about product pages and categories.

| Column Name | Description |
|------------|-------------|
| page_id | Unique ID for each page |
| page_name | Product name |
| product_id | Product identifier (1–9) |
| category | Product category (Fish, Luxury, Shellfish) |

### 4.2 `users`

Tracks website visitors via browser cookies.

| Column Name | Description |
|------------|-------------|
| cookie_id | Unique identifier for each user |
 
### 4.3 `event_identifier`

Defines types of user interactions.

| Column Name | Description |
|------------|-------------|
| event_type | Numeric event code |
| event_name | Event description |

**Event Types Include:**
- Page View  
- Add to Cart  
- Purchase  
- Ad Impression  
- Ad Click  

### 4.4 `campaign_identifier`

Stores marketing campaign information.

| Column Name | Description |
|------------|-------------|
| campaign_id | Campaign identifier |
| campaign_name | Name of the campaign |

### 4.5 `events`

Records every user action on the website.

| Column Name | Description |
|------------|-------------|
| cookie_id | User identifier |
| page_id | Page visited |
| event_type | Type of event |
| event_time | Timestamp of the event |
| sequence_number | Order of events per user |


## 5. Analytical Objectives

This project answers the following business questions:

1. What percentage of website visits result in a purchase?  
2. What percentage of visits reach the checkout page but do not result in a purchase?  
3. Which **three pages** have the highest number of views?  
4. How many page views and cart additions are there per **product category**?  
5. Which **three products** have the highest number of purchases?  
6. Using a **single SQL query**, create a table that shows for each product:
   - Number of views  
   - Number of cart additions  
   - Number of abandoned carts  
   - Number of purchases  
7. Create a similar aggregated table as in Question 6, but at the **category level**  
8. Which product has the highest number of views, cart additions, and purchases?  
9. Which product has the highest cart abandonment?  
10. Which product has the highest **view-to-purchase conversion rate**?  
11. What is the average conversion rate from **view to cart add**?  
12. What is the average conversion rate from **cart add to purchase**?  


## 7. Skills & Tools Used

- PostgreSQL  
- SQL Aggregations & Joins   
- Conversion Rate Analysis  
- E-commerce Analytics  


## 8. Expected Outcome

- Understand user behavior across an e-commerce funnel  
- Identify top-performing products and categories  
- Detect cart abandonment issues  
- Measure conversion efficiency at multiple stages  


