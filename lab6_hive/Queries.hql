-- Queries.hql
USE hotel_booking;

-- 1. Lister tous les clients
SELECT * FROM clients;

-- 2. Lister tous les hôtels à Paris
SELECT * FROM hotels WHERE ville='Paris';

-- 3. Lister toutes les réservations avec infos clients et hôtels
SELECT r.reservation_id, c.nom AS client, h.nom AS hotel, r.date_debut, r.date_fin, r.prix_total
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
JOIN hotels h ON r.hotel_id = h.hotel_id;

-- 4. Nombre de réservations par client
SELECT c.nom, COUNT(*) AS nb_reservations
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
GROUP BY c.nom;

-- 5. Clients avec plus de 2 nuitées
SELECT c.nom, SUM(DATEDIFF(r.date_fin, r.date_debut)) AS total_nuitees
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
GROUP BY c.nom
HAVING total_nuitees > 2;

-- 6. Hôtels réservés par chaque client
SELECT c.nom AS client, COLLECT_SET(h.nom) AS hotels_reserves
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY c.nom;

-- 7. Hôtels avec plus d'une réservation
SELECT h.nom, COUNT(*) AS nb_reservations
FROM reservations r
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.nom
HAVING nb_reservations > 1;

-- 8. Hôtels sans réservation
SELECT h.nom
FROM hotels h
LEFT JOIN reservations r ON h.hotel_id = r.hotel_id
WHERE r.reservation_id IS NULL;

-- 9. Clients ayant réservé un hôtel > 4 étoiles
SELECT DISTINCT c.nom
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
JOIN hotels h ON r.hotel_id = h.hotel_id
WHERE h.etoiles > 4;

-- 10. Total des revenus générés par chaque hôtel
SELECT h.nom, SUM(r.prix_total) AS total_revenus
FROM reservations r
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.nom;

-- 11. Revenus totaux par ville
SELECT h.ville, SUM(r.prix_total) AS revenus_totaux
FROM reservations r
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.ville;

-- 12. Nombre total de réservations par client
SELECT c.nom, COUNT(*) AS nb_reservations
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
GROUP BY c.nom;
