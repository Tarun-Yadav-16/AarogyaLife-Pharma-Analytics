"""
AarogyaLife Pharma Project
Python used only for data cleaning and transformation.

"""

import os
import pandas as pd


# 1. Folder paths
data_folder = "data"
output_folder = "cleaned_data"
os.makedirs(output_folder, exist_ok=True)


# 2. Load all CSV files
products = pd.read_csv(os.path.join(data_folder, "dim_product.csv"))
distributors = pd.read_csv(os.path.join(data_folder, "dim_distributor.csv"))
sales = pd.read_csv(os.path.join(data_folder, "fact_sales.csv"))
inventory = pd.read_csv(os.path.join(data_folder, "fact_inventory.csv"))
adverse_events = pd.read_csv(os.path.join(data_folder, "fact_adverse_events.csv"))
targets = pd.read_csv(os.path.join(data_folder, "targets.csv"))

print("All CSV files loaded successfully.")


# 3. Store DataFrames in one dictionary for repeated checks
tables = {
    "Products": products,
    "Distributors": distributors,
    "Sales": sales,
    "Inventory": inventory,
    "Adverse Events": adverse_events,
    "Targets": targets,
}


# 4. Basic data checking
for table_name, df in tables.items():
    print("\n", table_name)
    print("Rows and columns:", df.shape)
    print("Duplicate rows:", df.duplicated().sum())
    print("Missing values:")
    print(df.isnull().sum())


# 5. Clean all column names
for table_name in tables:
    df = tables[table_name]
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_", regex=False)
    )


# 6. Remove extra spaces from text columns
for table_name in tables:
    df = tables[table_name]
    text_columns = df.select_dtypes(include="object").columns

    for column in text_columns:
        df[column] = df[column].str.strip()


# 7. Remove complete duplicate rows
products.drop_duplicates(inplace=True)
distributors.drop_duplicates(inplace=True)
sales.drop_duplicates(inplace=True)
inventory.drop_duplicates(inplace=True)
adverse_events.drop_duplicates(inplace=True)
targets.drop_duplicates(inplace=True)


# 8. Convert date columns into datetime
products["launch_date"] = pd.to_datetime(
    products["launch_date"], errors="coerce"
)

distributors["onboard_date"] = pd.to_datetime(
    distributors["onboard_date"], errors="coerce"
)

sales["invoice_date"] = pd.to_datetime(
    sales["invoice_date"], errors="coerce"
)

inventory["snapshot_date"] = pd.to_datetime(
    inventory["snapshot_date"], errors="coerce"
)

inventory["manufacture_date"] = pd.to_datetime(
    inventory["manufacture_date"], errors="coerce"
)

inventory["expiry_date"] = pd.to_datetime(
    inventory["expiry_date"], errors="coerce"
)

adverse_events["report_date"] = pd.to_datetime(
    adverse_events["report_date"], errors="coerce"
)


# 9. Convert important sales columns into numeric datatype
sales_numeric_columns = [
    "quantity_units",
    "gross_sales_inr",
    "discount_inr",
    "net_sales_inr",
    "cogs_inr",
    "gross_profit_inr",
    "units_returned",
    "return_value_inr",
    "payment_days",
]

for column in sales_numeric_columns:
    sales[column] = pd.to_numeric(sales[column], errors="coerce")


# 10. Convert important inventory columns into numeric datatype
inventory_numeric_columns = [
    "opening_stock_units",
    "received_units",
    "sold_units",
    "damaged_units",
    "closing_stock_units",
    "reorder_level_units",
    "stockout_days",
    "near_expiry_units_90d",
    "inventory_value_inr",
]

for column in inventory_numeric_columns:
    inventory[column] = pd.to_numeric(inventory[column], errors="coerce")


# 11. Handle missing values
# Rows with missing IDs cannot be connected with other tables.
products.dropna(subset=["product_id"], inplace=True)
distributors.dropna(subset=["distributor_id"], inplace=True)
sales.dropna(
    subset=["sale_id", "product_id", "distributor_id"],
    inplace=True,
)
inventory.dropna(
    subset=["inventory_id", "product_id"],
    inplace=True,
)
adverse_events.dropna(
    subset=["case_id", "product_id"],
    inplace=True,
)

# Fill non-critical missing numeric values with zero.
sales["units_returned"] = sales["units_returned"].fillna(0)
sales["return_value_inr"] = sales["return_value_inr"].fillna(0)
inventory["damaged_units"] = inventory["damaged_units"].fillna(0)
inventory["stockout_days"] = inventory["stockout_days"].fillna(0)
inventory["near_expiry_units_90d"] = (
    inventory["near_expiry_units_90d"].fillna(0)
)


# 12. Standardise important text values
sales["region"] = sales["region"].str.title()
sales["state"] = sales["state"].str.title()
sales["city"] = sales["city"].str.title()
sales["channel"] = sales["channel"].str.title()
sales["on_time_payment"] = sales["on_time_payment"].str.title()

inventory["region"] = inventory["region"].str.title()
inventory["warehouse_city"] = inventory["warehouse_city"].str.title()

products["therapy_area"] = products["therapy_area"].str.title()
products["dosage_form"] = products["dosage_form"].str.title()

distributors["region"] = distributors["region"].str.title()
distributors["state"] = distributors["state"].str.title()
distributors["city"] = distributors["city"].str.title()
distributors["channel"] = distributors["channel"].str.title()


# 13. Create simple transformed columns for Power BI
# Extract year and month details from invoice date.
sales["sales_year"] = sales["invoice_date"].dt.year
sales["month_number"] = sales["invoice_date"].dt.month
sales["month_name"] = sales["invoice_date"].dt.month_name()

# Convert payment status from Yes/No into 1/0.
sales["on_time_payment_flag"] = sales["on_time_payment"].map(
    {"Yes": 1, "No": 0}
)

# Mark inventory records where stock is below reorder level.
inventory["below_reorder_status"] = "No"

inventory.loc[
    inventory["closing_stock_units"]
    < inventory["reorder_level_units"],
    "below_reorder_status",
] = "Yes"

# Create simple flags for the safety monitoring dashboard.
adverse_events["serious_report_flag"] = 0

adverse_events.loc[
    adverse_events["event_seriousness"].str.lower() == "serious",
    "serious_report_flag",
] = 1

adverse_events["under_review_flag"] = 0

adverse_events.loc[
    adverse_events["case_status"].str.lower() == "under review",
    "under_review_flag",
] = 1


# 14. Check data after cleaning
print("\nData cleaning and transformation completed.")

for table_name, df in tables.items():
    print("\n", table_name)
    print("Final rows and columns:", df.shape)
    print("Remaining duplicate rows:", df.duplicated().sum())
    print("Total remaining missing values:", df.isnull().sum().sum())


# 15. Export cleaned CSV files
products.to_csv(
    os.path.join(output_folder, "dim_product_cleaned.csv"),
    index=False,
)

distributors.to_csv(
    os.path.join(output_folder, "dim_distributor_cleaned.csv"),
    index=False,
)

sales.to_csv(
    os.path.join(output_folder, "fact_sales_cleaned.csv"),
    index=False,
)

inventory.to_csv(
    os.path.join(output_folder, "fact_inventory_cleaned.csv"),
    index=False,
)

adverse_events.to_csv(
    os.path.join(output_folder, "fact_adverse_events_cleaned.csv"),
    index=False,
)

targets.to_csv(
    os.path.join(output_folder, "targets_cleaned.csv"),
    index=False,
)

