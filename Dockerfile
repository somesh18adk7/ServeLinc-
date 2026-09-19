FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o /app/bin/servelinc ./cmd/servelinc

FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/bin/servelinc /app/servelinc
COPY --from=builder /app/policies /app/policies

EXPOSE 8080

CMD ["/app/servelinc"]
