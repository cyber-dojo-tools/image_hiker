FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY . .
RUN chown -R nobody .

ARG SHA
ENV SHA=${SHA}
