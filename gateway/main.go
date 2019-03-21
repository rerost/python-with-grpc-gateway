package main

import (
	"context"
	"flag"
	"net/http"

	"github.com/golang/glog"
	"github.com/gorilla/handlers"
	"github.com/grpc-ecosystem/grpc-gateway/runtime"
	gw "github.com/rerost/python-with-grpc-gateway/api"
	"google.golang.org/grpc"
)

var (
	echoEndpoint = flag.String("recommend_service", "localhost:5000", "recommend service")
)

func run() error {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithInsecure()}
	newMux := handlers.CORS(
		handlers.AllowedMethods([]string{"GET", "POST", "OPTIONS"}),
		handlers.AllowedOrigins([]string{"*"}),
		handlers.AllowedHeaders([]string{"content-type", "x-foobar-key"}),
	)(mux)

	err := gw.RegisterRecommendServiceHandlerFromEndpoint(ctx, mux, *echoEndpoint, opts)
	if err != nil {
		return err
	}

	return http.ListenAndServe(":3000", newMux)
}

func main() {
	flag.Parse()
	defer glog.Flush()

	if err := run(); err != nil {
		glog.Fatal(err)
	}
}
