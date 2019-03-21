FROM golang:1.12.1-alpine3.9 AS gateway

RUN apk add git

ENV APP_ROOT $GOPATH/src/github.com/rerost/python-with-grpc-gateway
ENV GO111MODULE=on

RUN ln -s $APP_ROOT/ /app

WORKDIR /app
COPY gateway ./gateway

## Copy protoc file
COPY ./api ./api

## install dependency
