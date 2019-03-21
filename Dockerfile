## ----- Gateway
FROM golang:1.12.1 AS gateway
LABEL build_stage=true

RUN	go get github.com/golang/dep/cmd/dep

ENV APP_ROOT /go/src/github.com/rerost/python-with-grpc-gateway
RUN ln -s $APP_ROOT/ /app

WORKDIR /app/gateway
COPY gateway .

RUN dep ensure
RUN go build -o bin/gateway --ldflags '-linkmode external -extldflags -static' main.go

## ----- Server
FROM python:3.7 as server

ENV APP_ROOT /go/src/github.com/rerost/python-with-grpc-gateway
RUN ln -s $APP_ROOT/ /app

WORKDIR /app

RUN pip install pipenv

# install depe
COPY Pipfile .
COPY Pipfile.lock .
RUN pipenv install

COPY . .
COPY --from=gateway /go/src/github.com/rerost/python-with-grpc-gateway/gateway/bin/gateway /usr/local/bin/gateway

CMD ["pipenv", "run", "start"]
