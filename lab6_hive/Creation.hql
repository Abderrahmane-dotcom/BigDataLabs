-- Creation.hql
-- 1. Création de la base de données
CREATE DATABASE IF NOT EXISTS hotel_booking;
USE hotel_booking;

-- 2. Activation des partitions dynamiques et du bucketing
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
SET hive.exec.max.dynamic.partitions = 20000;
SET hive.exec.max.dynamic.partitions.pernode = 20000;
SET hive.enforce.bucketing = true;

-- 3. Supprimer les tables existantes si elles existent
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS hotels;
DROP TABLE IF EXISTS hotels_staging;
DROP TABLE IF EXISTS clients;

-- 4. Création des tables

-- Table clients
CREATE TABLE clients (
    client_id INT,
    nom STRING,
    email STRING,
    telephone STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table hotels partitionnée par ville
CREATE TABLE hotels (
    hotel_id INT,
    nom STRING,
    etoiles INT
)
PARTITIONED BY (ville STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table staging pour hotels (pour gérer partitions dynamiques)
CREATE TABLE hotels_staging (
    hotel_id INT,
    nom STRING,
    ville STRING,
    etoiles INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table reservations bucketed par client_id
CREATE TABLE reservations (
    reservation_id INT,
    client_id INT,
    hotel_id INT,
    date_debut DATE,
    date_fin DATE,
    prix_total DECIMAL(10,2)
)
CLUSTERED BY (client_id) INTO 4 BUCKETS
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
