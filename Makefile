.PHONY: proto tidy test run compose-up compose-down finch-vm-up finch-up finch-down finch-status finch-logs finch-reset

proto:
	buf generate

tidy:
	go mod tidy

test:
	go test ./...

run:
	go run ./cmd/servelinc

compose-up:
	docker compose up -d redis

compose-down:
	docker compose down

finch-vm-up:
	finch vm start || true

finch-up: finch-vm-up
	finch compose up --build -d

finch-down:
	finch compose down --volumes

finch-status:
	finch compose ps

finch-logs:
	finch compose logs -f --tail=200

finch-reset: finch-down finch-up
