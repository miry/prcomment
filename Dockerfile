FROM crystallang/crystal:0.36.1 as builder

WORKDIR /app
COPY ./shard.yml /app/
RUN shards install

COPY . /app/
RUN make build

FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y \
      ca-certificates \
      libssl1.1 \
      libssl-dev \
      libevent-2.1-7 \
      libxml2-dev \
      libyaml-dev \
      libgmp-dev \
      libevent-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /
COPY --from=builder /app/_output/prcomment .

ENTRYPOINT ["/prcomment"]
