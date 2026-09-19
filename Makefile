.PHONY: proto tidy test run compose-up compose-down

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
