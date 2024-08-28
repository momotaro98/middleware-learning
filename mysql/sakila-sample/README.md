# how to download (初回のときのみで不要だがメモとして残し)

```
mysql -u root -p < <( \
    wget 'http://downloads.mysql.com/docs/sakila-db.zip' \
    && unzip -o sakila-db.zip 1>/dev/null \
    && cat sakila-db/sakila-schema.sql sakila-db/sakila-data.sql \
  )
```

# Run sakila DB with docker compose in local

```
docker compose -f docker-compose.my80.yml up -d
```

# Access to the DB

```
direnv allow
mysql -u${MYSQL_USER} -p${MYSQL_PASS} -P${MYSQL_PORT} -h${MYSQL_HOST} -D${MYSQL_DBNAME}
```