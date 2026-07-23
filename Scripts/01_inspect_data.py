import pandas as pd

df = pd.read_csv(r"D:\DelivInsight\Data\Delivery_Logistics.csv")

print("=== COLUMN NAMES ===")
print(df.columns.tolist())

print("\n=== SHAPE (rows, columns) ===")
print(df.shape)

print("\n=== FIRST 5 ROWS ===")
print(df.head())

print("\n=== NULL VALUES PER COLUMN ===")
print(df.isnull().sum())

print("\n=== DUPLICATE ROWS ===")
print(df.duplicated().sum())

print("\n=== DATA TYPES ===")
print(df.dtypes)