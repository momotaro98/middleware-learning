

up Elasticsearch with docker

```
docker-compose up -d --build
```

Create index

```
curl -XPUT -H 'Content-Type: application/json' http://localhost:9200/rental --data "@test.json"

curl -XGET http://localhost:9200/rental
```

Populate data with bulk

```
curl -s -XPOST -H 'Content-Type: application/json' http://localhost:9200/_bulk --data-binary "@data"
```

Search data

```
curl -i -H "Content-Type: application/json" -XGET http://localhost:9200/rental/_search\? -d '{"query": {"match_all": {}} }'
```
