# how to download

```
mysql -u root -p < <( \
    wget 'http://downloads.mysql.com/docs/sakila-db.zip' \
    && unzip -o sakila-db.zip 1>/dev/null \
    && cat sakila-db/sakila-schema.sql sakila-db/sakila-data.sql \
  )
```

