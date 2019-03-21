## ----- Gateway
FROM golang:1.12.1-alpine3.9 AS gateway

RUN apk add git make

ENV APP_ROOT /go/src/github.com/rerost/python-with-grpc-gateway
RUN ln -s $APP_ROOT/ /app

WORKDIR /app/gateway
COPY gateway .

RUN make build
RUN cp bin/gateway /gateway


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
COPY --from=gateway /gateway /usr/local/bin/gateway

CMD ["pipenv", "run", "start"]
