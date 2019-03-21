build: depend
	go build -o bin/gateway main.go

setup:
	go get github.com/golang/dep/cmd/dep

depend: setup
	dep ensure

clear:
	rm bin/*
