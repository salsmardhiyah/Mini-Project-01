# Mini-Project-01
Mini Project 01 : Analyzing eCommerce Business Performance with SQL

## Project Background 
In this Mini Project, I play a member of an eCommerce company's Data Analytics team. This company is one of South America's major platforms for connecting tiny companies with their clients. As a member of the Data Analytics team, I am in charge of analyzing three areas of the company's financial performance. These three factors are client growth, product quality, and payment methods. I will analyze the data provided to create a business performance report on these three aspects.

## Data Preparation
Before starting data processing, the first step that must be done is to prepare raw data into structured data and ready to be processed. Here's what I do at Data Preparation Stage:

1. Download datasets given
2. Create a new database and tables for the prepared datasets by adjusting the data type of each column, also arranging Primary Keys and Foreign Keys for each table
3. Importing csv data into the database
4. Create entity relationships between tables based on the structure in the "Data Relationship"
<br>

![Alt text](https://github.com/salsmardhiyah/Mini-Project-01/blob/main/Data+Relationship.png?raw=true)
<br>Fig.1. Data Relationship

Below is entity relationship diagram created based on interpretation of Data Relationship:

```mermaid
erDiagram
    products {
        num serial
        product_id varchar(32) PK
        product_category_name varchar(50)
        product_name_lenght numeric
        product_description_lenght numeric
        product_photos_qty numeric
        product_weight_g numeric
        product_length_cm numeric
        product_height_cm numeric
        product_width_cm numeric
    }
    geolocations {
        geolocation_zip_code_prefix varchar(5) PK
        geolocation_lat numeric
        geolocation_lng numeric
        geolocation_city varchar(50)
        geolocation_state varchar(2)
    }
    customers {
        customer_id varchar(32) PK
        customer_unique_id varchar(32) FK
        customer_zip_code_prefix varchar(5)
        customer_city varchar(50)
        customer_state varchar(2)
    }
    sellers {
        seller_id varchar(32) PK
        seller_zip_code_prefix varchar(5) FK
        seller_city varchar(50)
        seller_state varchar(2)
    }
    orders {
        order_id varchar(32) PK
        customer_id varchar(32) FK
        order_status varchar(20)
        order_purchase_timestamp timestamp
        order_approved_at timestamp
        order_delivered_carrier_date timestamp
        order_delivered_customer_date timestamp
        order_estimated_delivery_date timestamp
    }
    order_items {
        order_id varchar(32) FK
        order_item_id varchar(32)
        product_id varchar(32) FK
        seller_id varchar(32) FK
        shipping_limit_date timestamp
        price numeric
        freight_value numeric
    }
    order_reviews {
        review_id varchar(32)
        order_id varchar(32) FK
        review_score smallint
        review_comment_title varchar(30)
        review_comment_message text
        review_creation_date timestamp
        review_answer_timestamp timestamp
    }
    order_payments {
        order_id varchar(32) FK
        payment_sequential smallint
        payment_type varchar(20)
        payment_installments smallint
        payment_value numeric
    }

    customers ||--o{ orders : places
    orders ||--o{ order_reviews : gets
    orders ||--o{ order_payments : uses
    orders ||--o{ order_items : contains
    order_items }o--|| products : contains
    sellers ||--o{ order_items : processes
    sellers }o--|| geolocations : locates
    customers }o--|| geolocations : locates
```
Fig.2. Entity Relationship Diagram

## Annual Customer Activity Growth Analysis

## Annual Product Category Analysis

## Annual Payment Type Usage Analysis