🧪 Clinical Trials Data Pipeline (API → Pandas → SQLite)

🚧 Project Status: In Progress
This project is actively being developed. Features, schema design, and analyses are subject to change.

📌 Project Overview

This project builds an end-to-end data pipeline using publicly available clinical trials data. The goal is to extract raw clinical trial data, clean and normalize it using Python and pandas, store it in a structured SQLite database, and enable downstream analysis using SQL.

The project emphasizes:

Data normalization

Relational database design

Real-world ETL (Extract, Transform, Load) workflows

Analytical readiness for healthcare and life sciences data

🧱 Tech Stack

Python

pandas – data cleaning & transformation

SQLite – relational database storage

sqlite3 – database connections & SQL execution

Jupyter Notebook – development & experimentation

🗂️ Database Schema (Current)
studies (Core Table)

Stores one row per clinical trial.

Key fields include:

nct_id (Primary Key)

Study titles and identifiers

Sponsoring organization details

Study status and dates

Study design characteristics

Enrollment and FDA regulation flags

Derived metrics (e.g., duration)

study_conditions (Child Table)

Stores medical conditions associated with each study.

Design highlights:

One-to-many relationship with studies

Composite primary key: (nct_id, condition)

Foreign key constraint ensures referential integrity

This design prevents duplicate conditions per study and follows database normalization best practices.

🔄 ETL Workflow

Extract

Pull raw clinical trial data from a public API (e.g., ClinicalTrials.gov)

Transform

Clean and standardize fields using pandas

Convert dates, numerics, and booleans

Derive additional fields (e.g., study duration, enrollment size)

Load

Insert cleaned data into SQLite using DataFrame.to_sql()

Maintain relational integrity across tables

📊 Planned Analyses (Upcoming)

Distribution of studies by condition

Enrollment size trends over time

Study duration by phase or sponsor type

FDA-regulated vs non-regulated studies

Sponsor-level portfolio analysis

🚧 Work in Progress

The following are still under development:

Additional normalized tables (interventions, locations, outcomes)

Robust data validation checks

Indexing and query optimization

Analytical SQL queries and visualizations

Documentation of API extraction logic

Expect:

Schema changes

Refactoring

New datasets and analyses added incrementally

▶️ How to Run (Current State)

Clone the repository

Open the Jupyter notebook

Run cells in order to:

Create the SQLite database

Create tables

Load cleaned data

⚠️ Note: Some notebooks/scripts assume tables may be dropped and recreated during development.

🎯 Project Goals

This project is designed to demonstrate:

Practical data engineering skills

Strong understanding of relational databases

Healthcare data domain familiarity

Analytical thinking using SQL and Python

📌 Future Improvements

Migrate to PostgreSQL for scalability

Add automated data refresh scripts

Build Tableau / Power BI dashboards

Add unit tests for data validation

Create reproducible pipeline scripts

👤 Author

Noah George
Data Analytics & Data Science Student
Stony Brook University
