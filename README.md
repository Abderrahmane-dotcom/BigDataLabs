# BigDataLabs

Un projet complet couvrant les technologies Big Data : **Hadoop MapReduce**, **Kafka**, **HBase**, **Pig**, et **Hive**.

---

## 📋 Structure du Projet

```
BigDataLabs/
├── datasets/                          # Données brutes et scripts de traitement
│   ├── alice.txt, calls.txt, coran_converted.txt
│   ├── Mapper.py, Reducer.py          # Scripts Python MapReduce
│   ├── purchases.txt
│   └── DATSETS_HIVE/
│       ├── clients.txt, hotels.txt, reservations.txt
│       └── hadoop-project/
├── lab0/                              # Configuration initiale (Docker)
│   ├── docker-compose.yaml
│   └── datasets/
├── lab1/                              # Hadoop MapReduce (Java & Python)
│   ├── hadoop_lab/                    # Projet Maven WordCount
│   │   ├── pom.xml
│   │   └── src/main/java/...
│   └── results/                       # Résultats MapReduce
├── lab3_kafka/                        # Apache Kafka (Producteur/Consommateur)
│   ├── pom.xml
│   └── src/main/java/.../
├── lab4_hbase/                        # HBase (stockage NoSQL)
├── lab5_pig/                          # Pig Latin (ETL & analyse)
├── lab6_hive/                         # Hive (SQL sur données structurées)
│   ├── Creation.hql                   # Création tables
│   ├── Loading.hql                    # Chargement données
│   ├── Queries.hql                    # Requêtes analytiques
│   └── results.txt
└── README.md                          # Ce fichier
```

---

## 🎯 Objectifs par Lab

### Lab 0 : Configuration Docker
- **Objectif** : Mettre en place l'environnement Hadoop/Hive en conteneurs.
- **Fichier clé** : `docker-compose.yaml`
- **Commandes** :
  ```bash
  docker-compose up -d
  docker-compose ps
  docker-compose down
  ```

### Lab 1 : Hadoop MapReduce
- **Objectif** : Implémenter MapReduce en Java et Python.
- **Cas d'usage** : Comptage de mots (WordCount), calculs sur données.
- **Fichiers clés** :
  - `hadoop_lab/src/main/java/.../WordCount.java`
  - `hadoop_lab/src/main/java/.../TokenizerMapper.java`
  - `hadoop_lab/src/main/java/.../IntSumReducer.java`
- **Build & Exécution** :
  ```bash
  cd lab1/hadoop_lab
  mvn clean package
  hadoop jar target/WordCount.jar org.apache.hadoop.examples.WordCount <input> <output>
  ```

### Lab 3 : Apache Kafka
- **Objectif** : Architecture pub/sub avec producteur et consommateur.
- **Fichiers clés** :
  - `EventProducer.java` : Envoie messages
  - `EventConsumer.java` : Consomme messages
- **Build** :
  ```bash
  cd lab3_kafka
  mvn clean package
  java -cp target/classes:target/dependency/* edu.ensias.kafka.EventProducer
  java -cp target/classes:target/dependency/* edu.ensias.kafka.EventConsumer
  ```

### Lab 4 : HBase
- **Objectif** : Stockage colonnaire distribué, requêtes NoSQL.
- **Dossier** : `lab4_hbase/`

### Lab 5 : Pig Latin
- **Objectif** : Langage de haut niveau pour ETL et transformation.
- **Scripts** : À placer dans `lab5_pig/`
- **Exemple de script** :
  ```pig
  clients = LOAD 'clients.txt' AS (id:int, name:chararray, email:chararray);
  filtered = FILTER clients BY id > 2;
  DUMP filtered;
  ```

### Lab 6 : Apache Hive
- **Objectif** : SQL sur données structurées (HDFS/Hadoop).
- **Données** : Réservations hôtels (clients, hôtels, réservations).
- **Fichiers clés** :
  - `Creation.hql` : Crée tables (avec OpenCSVSerde, partitionnement)
  - `Loading.hql` : Charge données + transformation via INSERT OVERWRITE
  - `Queries.hql` : Requêtes analytiques (JOIN, GROUP BY, agrégations)

---

## 📊 Données Lab 6 (Hive)

### Fichier `clients.txt`
```
1,John Doe,john.doe@example.com,1234567890
2,Sarah Connor,sarah.connor@example.com,0987654321
3,James Bond,james.bond@example.com,1122334455
...
```

### Fichier `hotels.txt`
```
1,Grand Hotel,Paris,5
2,Beach Resort,Nice,4
3,Mountain Lodge,Chamonix,3
...
```

### Fichier `reservations.txt`
```
1,1,1,2024-12-01,2024-12-05,1500.00
2,2,2,2024-12-10,2024-12-15,800.00
...
```

---

## 🚀 Exécution Lab 6 (Hive)

### 1️⃣ Créer les tables
```bash
hive -f lab6_hive/Creation.hql
```

### 2️⃣ Charger les données
```bash
hive -f lab6_hive/Loading.hql
```

### 3️⃣ Exécuter les requêtes
```bash
hive -f lab6_hive/Queries.hql
```

Ou en mode interactif (Beeline) :
```bash
beeline -u jdbc:hive2://localhost:10000 -f lab6_hive/Creation.hql
```

---

## 🔧 Points Clés d'Implémentation

### OpenCSVSerde (Hive)
Pour éviter les erreurs de parsing CSV :
```sql
CREATE TABLE raw_clients (
  id STRING, name STRING, email STRING, phone STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ("separatorChar" = ",")
STORED AS TEXTFILE;
```

### Tables de Staging (raw_*)
- Chargent les fichiers bruts en STRING.
- Évitent les erreurs de type lors du LOAD DATA.
- INSERT OVERWRITE avec CAST vers tables finales typées.

### Partitionnement
```sql
PARTITIONED BY (date_debut STRING)
```
Les dates sont en STRING pour éviter les erreurs lors du chargement.

### Bucketing
```sql
CLUSTERED BY (client_id) INTO 4 BUCKETS
STORED AS ORC;
```
Améliore les JOIN et GROUP BY sur `client_id`.

---

## 📝 Requêtes Utiles (Lab 6)

### Revenus par hôtel
```sql
SELECT h.nom, SUM(r.prix_total) AS total_revenus
FROM reservations r
JOIN hotels_partitioned h ON r.hotel_id = h.hotel_id
GROUP BY h.nom
ORDER BY total_revenus DESC;
```

### Nombre de réservations par client
```sql
SELECT c.nom, COUNT(*) AS nb_reservations
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
GROUP BY c.nom;
```

### Hôtels sans réservation
```sql
SELECT h.nom
FROM hotels_partitioned h
LEFT JOIN reservations r ON h.hotel_id = r.hotel_id
WHERE r.reservation_id IS NULL;
```

---

## 🛠️ Dépendances

- **Java** : OpenJDK 8+
- **Hadoop** : 3.x
- **Hive** : 3.x
- **Kafka** : 2.x
- **HBase** : 2.x
- **Pig** : 0.17+
- **Maven** : 3.6+
- **Docker** : 20.10+ (pour Lab 0)

---

## 📦 Installation

1. **Cloner le projet** :
   ```bash
   git clone https://github.com/Abderrahmane-dotcom/BigDataLabs.git
   cd BigDataLabs
   ```

2. **Vérifier Maven** :
   ```bash
   mvn --version
   ```

3. **Builder les projets Java** :
   ```bash
   cd lab1/hadoop_lab && mvn clean package
   cd ../../lab3_kafka && mvn clean package
   ```

4. **Lancer Docker (Lab 0)** :
   ```bash
   cd lab0
   docker-compose up -d
   ```

---

## 📚 Ressources

- [Apache Hadoop Documentation](https://hadoop.apache.org/docs/)
- [Apache Hive Documentation](https://hive.apache.org/)
- [Apache Pig Documentation](https://pig.apache.org/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Apache HBase Documentation](https://hbase.apache.org/)

---

## 🤝 Auteur

**Abderrahmane** - [GitHub](https://github.com/Abderrahmane-dotcom)

---

## 📄 Licence

Projet éducatif - BigDataLabs (2024-2025)
