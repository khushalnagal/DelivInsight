-- Note: run via MySQL CLI with --local-infile=1 flag (Workbench 8.0.46 GUI does not expose this client-side setting)

USE delivinsight;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'D:/DelivInsight/Data/Delivery_Logistics_cleaned.csv'
INTO TABLE deliveries
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(delivery_id, delivery_partner, package_type, vehicle_type, delivery_mode,
 region, weather_condition, distance_km, package_weight_kg,
 delivery_status, delivery_rating, delivery_cost);