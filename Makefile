# ----- protoc
PROTO_DIR := ./api/protos
PROTO_FILES := $(shell ls ${PROTO_DIR} | grep -e ".*\.proto")
PROTO_OUT_DIR := ./
PROTO_PATH := /usr/local/include
GATEWAY_FLAGS := -I. -I/usr/local/include -I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis -I/usr/local/include
GATEWAY_OUT_DIR := ./gateway/api

.PHONY: protoc
protoc:
	protoc \
	-I=${PROTO_PATH} \
	-I=${PROTO_DIR} \
	${GATEWAY_FLAGS} \
	--python_out=${PROTO_OUT_DIR} \
	--grpc_python_out=${PROTO_OUT_DIR} \
	--plugin=protoc-gen-grpc_python=`which grpc_python_plugin` \
	${PROTO_FILES}

.PHONY: gateway
gateway:
	protoc $(GATEWAY_FLAGS) \
	-I=${PROTO_DIR} \
	--go_out=plugins=grpc:${GATEWAY_OUT_DIR} \
	--grpc-gateway_out=logtostderr=true:${GATEWAY_OUT_DIR} \
	${PROTO_FILES}
