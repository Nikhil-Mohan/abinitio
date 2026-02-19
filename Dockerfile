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
# RUNTIME STAGE
# ===========================
FROM alpine:3.19

WORKDIR /etl

COPY --from=builder /app/etl .
COPY runtime runtime
COPY graphs graphs
COPY data data

# Fix permissions BEFORE user switch
RUN chmod +x etl runtime/master_pipeline.sh \
 && adduser -D etluser \
 && chown -R etluser:etluser /etl

USER etluser

ENTRYPOINT ["sh","runtime/master_pipeline.sh"]
