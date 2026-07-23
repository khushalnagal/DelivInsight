CREATE DATABASE IF NOT EXISTS delivinsight;
USE delivinsight;

CREATE TABLE deliveries (
    delivery_id        INT PRIMARY KEY,
    delivery_partner    VARCHAR(50),
    package_type        VARCHAR(50),
    vehicle_type        VARCHAR(50),
    delivery_mode       VARCHAR(50),
    region              VARCHAR(50),
    weather_condition   VARCHAR(50),
    distance_km         DECIMAL(6,2),
    package_weight_kg   DECIMAL(6,2),
    delivery_status     VARCHAR(20),
    delivery_rating     INT,
    delivery_cost       DECIMAL(8,2)
);