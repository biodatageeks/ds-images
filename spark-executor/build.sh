#!/usr/bin/env bash
docker build -t biodatageeks/spark-py:v3.0.1-ds . && \
docker push biodatageeks/spark-py:v3.0.1-ds
