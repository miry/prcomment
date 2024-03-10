ARG BUILD_OS=alpine

##############
# Build layers
FROM crystallang/crystal:1.11.2 as build-base-ubuntu
RUN apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
      build-essential \
      ruby-rake

FROM crystallang/crystal:1.11.2-alpine as build-base-alpine
RUN apk add --no-cache \
      ruby-rake \
      ruby-json

FROM build-base-${BUILD_OS} as build

WORKDIR /app

# Cache install package dependicies
COPY ./shard.* /app/
RUN shards install --production -v

# Build the app
COPY . /app/
RUN rake build:static

###############
# Runtime layer
FROM scratch as runtime
# Put the binary in the ROOT folder
WORKDIR /
# Don't run as root
USER 1001

# Copy/install required assets like CA certificates
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem
COPY --from=build /app/_output/prcomment .

ENTRYPOINT ["/prcomment"]
