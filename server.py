import grpc
import os
from concurrent import futures
import time
import logging

import api.recommend_pb2_grpc as recommend_pb2_grpc
import api.recommend_pb2 as recommend_pb2

_ONE_DAY_IN_SECONDS = 60 * 60 * 24

class Recommend(recommend_pb2_grpc.RecommendServiceServicer):
  def ListUsers(self, request, context):
    return recommend_pb2.ListUsersResponse(
      users=[
        {
          "id": 1, 
          "score": 1,
          "score_description": recommend_pb2.ScoreDescription(
            scores=[
              recommend_pb2.Score(name="popularity", score=1),
              recommend_pb2.Score(name="attractive", score=1),
            ],
            score_func="0.5 * popularity + 0.5 * attractive",
          )
        },
        {
          "id": 2, 
          "score": 6,
          "score_description": recommend_pb2.ScoreDescription(
            scores=[
              recommend_pb2.Score(name="popularity", score=5),
              recommend_pb2.Score(name="attractive", score=1),
            ],
            score_func="0.5 * popularity + 0.5 * attractive",
          )
        }
      ]
    )

  def ListBlogs(self, request, context):
    return recommend_pb2.ListBlogsResponse(
      blogs=[]
    )

def serve(port):
  server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
  recommend_pb2_grpc.add_RecommendServiceServicer_to_server(Recommend(), server)
  server.add_insecure_port('[::]:' + port)
  server.start()
  try:
    while True:
      time.sleep(_ONE_DAY_IN_SECONDS)
  except KeyboardInterrupt:
    server.stop(0)


if __name__ == '__main__':
  port = os.getenv("GRPC_PORT")
  print("Started server {0}.".format(port))
  logging.basicConfig()
  serve(port)
