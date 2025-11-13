-- Loading.hql
USE hotel_booking;

-- 1. Charger les données clients
LOAD DATA LOCAL INPATH '/shared_volume/hive/clients.txt' INTO TABLE clients;

-- 2. Charger les données hotels via table staging
LOAD DATA LOCAL INPATH '/shared_volume/hive/hotels.txt' INTO TABLE hotels_staging;

-- 3. Insérer dans la table partitionnée dynamiquement
INSERT OVERWRITE TABLE hotels PARTITION (ville)
SELECT hotel_id, nom, etoiles, ville
FROM hotels_staging;

-- 4. Charger les données reservations bucketed
LOAD DATA LOCAL INPATH '/shared_volume/hive/reservations.txt' INTO TABLE reservations;

-- Optionnel : supprimer la table staging
DROP TABLE hotels_staging;
