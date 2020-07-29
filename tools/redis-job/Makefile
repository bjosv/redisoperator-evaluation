ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

all:
	docker build -t bjosv/redis-job:latest .

push:
	docker push bjosv/redis-job:latest

run:
	kubectl delete -f $(ROOT_DIR)/job.yaml || true
	kubectl apply -f $(ROOT_DIR)/job.yaml

kubedb:
	kubectl delete -f $(ROOT_DIR)/kubedb_job.yaml || true
	kubectl apply -f $(ROOT_DIR)/kubedb_job.yaml
