FROM golang:1.23.4-alpine AS builder

WORKDIR /etl
COPY . .

CMD ["sh", "runtime/master_pipeline.sh"]
