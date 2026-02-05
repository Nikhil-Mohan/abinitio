# ===========================
# BUILD STAGE
# ===========================
FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod tidy

COPY . .

RUN go build -o etl transforms/user_aggregate.go

# ===========================
# RUNTIME STAGE (LEAN)
# ===========================
FROM alpine:latest

WORKDIR /etl

# RUN apk add --no-cache ca-certificates

COPY --from=builder /app/etl /etl/etl
COPY runtime ./runtime
COPY data ./data
COPY graphs ./graphs

EXPOSE 8080

ENTRYPOINT ["sh", "runtime/master_pipeline.sh"]
