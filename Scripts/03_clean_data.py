import pandas as pd

df = pd.read_csv(r"D:\DelivInsight\Data\Delivery_Logistics.csv")

# 1. Drop broken time columns (unusable epoch timestamps)
df = df.drop(columns=["delivery_time_hours", "expected_time_hours"])

# 2. Drop the 'delayed' yes/no column — delivery_status already captures this with more detail
df = df.drop(columns=["delayed"])

# 3. Regenerate a clean sequential delivery_id (original had ~498 duplicate/broken values)
df["delivery_id"] = range(1, len(df) + 1)

# 4. Confirm no missing values remain
print("Nulls after cleaning:")
print(df.isnull().sum())

# 5. Confirm delivery_status categories
print("\nDelivery status counts:")
print(df["delivery_status"].value_counts())

# 6. Save cleaned file
df.to_csv(r"D:\DelivInsight\Data\Delivery_Logistics_cleaned.csv", index=False)
print("\nCleaned file saved as Delivery_Logistics_cleaned.csv")