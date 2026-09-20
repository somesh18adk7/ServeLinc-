# OpenSearch telemetry mapping

`deploy/opensearch/servelinc-rate-events-template.json` defines the index template for quota-decision telemetry.

Install it before indexing events:

```bash
curl -X PUT "http://localhost:9200/_index_template/servelinc-rate-events" \
  -H "Content-Type: application/json" \
  --data-binary @deploy/opensearch/servelinc-rate-events-template.json
```

Use a rollover-friendly index name such as `servelinc-rate-events-2026.09.20`. The mapping is strict so unexpected telemetry fields fail instead of silently creating new fields. `key` is retained in `_source` for troubleshooting but is not indexed, reducing exposure and avoiding high-cardinality term lookups.
