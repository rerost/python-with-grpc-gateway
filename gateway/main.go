package main

import (
	"context"
	"flag"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/handlers"
	"github.com/grpc-ecosystem/grpc-gateway/runtime"
	gw "github.com/rerost/python-with-grpc-gateway/api"
	"google.golang.org/grpc"
)

var (
	target   = os.Getenv("GATEWAY_TARGET")
	selfPort = os.Getenv("GATEWAY_PORT")
)

func run() error {
	echoEndpoint := flag.String("recommend_service", target, "recommend service")

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

	return http.ListenAndServe(":"+selfPort, newMux)
}

func main() {
	log.Printf("Starting gateway %v. target is %v\n", selfPort, target)

	if err := run(); err != nil {
		log.Fatal(err)
	}
}
