FROM crystallang/crystal:1.0.0-alpine as builder

WORKDIR /app
COPY ./shard.* /app/
RUN shards install --production -v

COPY . /app/
RUN make build.static

FROM alpine:latest
WORKDIR /
COPY --from=builder /app/_output/prcomment .

ENTRYPOINT ["/prcomment"]
