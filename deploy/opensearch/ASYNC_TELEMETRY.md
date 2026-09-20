# Asynchronous telemetry

ServeLinc telemetry is deliberately decoupled from quota enforcement. A quota decision should be returned after the Redis/Lua operation completes; publishing its telemetry must not add OpenSearch latency to the request path.

## Event contract

Each quota decision is represented by one event and should be indexed using the mapping in [`deploy/opensearch/servelinc-rate-events-template.json`](./opensearch/servelinc-rate-events-template.json).

| Field | Type | Description |
|---|---|---|
| `@timestamp` | date | Time at which the decision was produced |
| `key` | keyword | Tenant or API key associated with the request; retained for troubleshooting but not indexed |
| `decision` | keyword | `ALLOW` or `DENY` |
| `remaining` | integer | Quota remaining after the decision |
| `latency_ms` | long | Time spent handling the quota request |
| `instance_id` | keyword | Replica that handled the request |

Use a concrete daily index such as `servelinc-rate-events-2026.09.20`, or an alias managed by the deployment. Install the index template before the first event is written.

## Delivery behavior

Telemetry should be published through a bounded in-process buffer and a background worker:

1. Create the event after the quota decision is known.
2. Enqueue it without blocking the gRPC response longer than the configured enqueue deadline.
3. Flush events in batches to OpenSearch.
4. Retry transient OpenSearch failures with bounded exponential backoff.
5. Drop or dead-letter events when the buffer is full or retries are exhausted, and expose a metric for both cases.
6. Stop the worker during shutdown after a short, bounded flush deadline.

OpenSearch is observability infrastructure, not part of authorization or quota correctness. If it is unavailable, quota requests must continue to succeed or fail based on Redis and the limiter result rather than on telemetry delivery.

## Operational checks

Apply the mapping before starting traffic:

```bash
curl -X PUT "http://localhost:9200/_index_template/servelinc-rate-events" \
  -H "Content-Type: application/json" \
  --data-binary @deploy/opensearch/servelinc-rate-events-template.json
```

After traffic is generated, inspect recent events:

```bash
curl "http://localhost:9200/servelinc-rate-events-*/_search?size=5&sort=@timestamp:desc"
```

Monitor at least:

- queue depth and dropped-event count
- batch size and flush latency
- OpenSearch request failures and retry count
- oldest event age in the buffer
- event counts by `decision` and `instance_id`

Do not include credentials, authorization tokens, or request payloads in telemetry. Keep `key` handling aligned with the deployment’s privacy requirements.
