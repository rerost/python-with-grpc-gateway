# ----- protoc
PROTO_DIR := ./api/protos
PROTO_FILES := $(shell ls ${PROTO_DIR} | grep -e ".*\.proto")
PROTO_OUT_DIR := ./api
PROTO_PATH := /usr/local/include

GATEWAY_FLAGS := -I. -I/usr/local/include -I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis -I/usr/local/include
GATEWAY_OUT_DIR := ./gateway/api

# see https://github.com/protocolbuffers/protobuf/issues/1491
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
	sed -i '.bak' 's/^\(import.*_pb2\)/from . \1/' ${PROTO_OUT_DIR}/*pb2*.py 
	rm ${PROTO_OUT_DIR}/*.py.bak

.PHONY: gateway
gateway:
	protoc $(GATEWAY_FLAGS) \
	-I=${PROTO_DIR} \
	--go_out=plugins=grpc:${GATEWAY_OUT_DIR} \
	--grpc-gateway_out=logtostderr=true:${GATEWAY_OUT_DIR} \
	${PROTO_FILES}
