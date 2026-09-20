# OpenSearch verification

Use these steps to validate that the local telemetry pipeline is working.

## 1. Start the stack

```bash
make finch-up
make finch-status
```

This should show Redis, OpenSearch, and all three ServeLinc replicas in a running state.

## 2. Ensure the template is installed

Before generating traffic, install the index template:

```bash
curl -X PUT "http://localhost:9200/_index_template/servelinc-rate-events" \
  -H "Content-Type: application/json" \
  --data-binary @deploy/opensearch/servelinc-rate-events-template.json
```

Check that it exists:

```bash
curl "http://localhost:9200/_index_template/servelinc-rate-events?pretty"
```

## 3. Confirm the cluster is healthy

```bash
curl "http://localhost:9200/_cluster/health?pretty"
```

Expected result: a cluster status of `green` or `yellow`.

## 4. Generate traffic

Run the distributed integration tests or issue quota checks through the local gRPC service:

```bash
go test -v -tags=integration ./tests/integration/...
```

If you are checking manually, generate a few `Check` requests against the replica on port `8081`, `8082`, or `8083`.

## 5. Search for telemetry documents

Query the newest events:

```bash
curl "http://localhost:9200/servelinc-rate-events-*/_search?size=5&sort=@timestamp:desc&pretty"
```

Example response fields:

- `@timestamp`
- `decision`
- `remaining`
- `latency_ms`
- `instance_id`
- `key`

## 6. Example filter queries

```bash
curl "http://localhost:9200/servelinc-rate-events-*/_search?pretty" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "term": { "decision": "ALLOW" }
    }
  }'
```

```bash
curl "http://localhost:9200/servelinc-rate-events-*/_search?pretty" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "term": { "instance_id": "servelinc2" }
    }
  }'
```

## 7. Troubleshooting

If no events appear:

- confirm OpenSearch is healthy
- confirm the template is installed
- confirm `OPENSEARCH_URL` is reachable from the service container
- confirm the quota requests are actually being processed by a replica
- review service logs with `make finch-logs`

If an index template error occurs, ensure the JSON file matches the mapped fields exactly and that the cluster accepts strict mappings.

## 8. Useful cleanup

```bash
curl -X DELETE "http://localhost:9200/servelinc-rate-events-*"
```

Only do this in a local test environment or when intentionally resetting the telemetry dataset.
