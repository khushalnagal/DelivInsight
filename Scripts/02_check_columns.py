import pandas as pd

df = pd.read_csv(r"D:\DelivInsight\Data\Delivery_Logistics.csv")

print("=== delivery_time_hours sample ===")
print(df["delivery_time_hours"].head(10))

print("\n=== delayed value counts ===")
print(df["delayed"].value_counts())

print("\n=== delivery_status value counts ===")
print(df["delivery_status"].value_counts())

print("\n=== delivery_id unique count vs total rows ===")
print("Unique IDs:", df["delivery_id"].nunique())
print("Total rows:", len(df))

print("\n=== delivery_partner value counts ===")
print(df["delivery_partner"].value_counts())

print("\n=== region value counts ===")
print(df["region"].value_counts())