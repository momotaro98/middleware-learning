
```
docker-compose up -d --build
```

```
curl -XPUT -H 'Content-Type: application/json' http://localhost:9200/rental --data "@test.json"

curl -XGET http://localhost:9200/rental
```

```
curl -s -XPOST -H 'Content-Type: application/json' http://localhost:9200/_bulk --data-binary "@data"

curl -XGET http://localhost:9200/rental
```
