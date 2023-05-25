NAME=v8

build:
ifdef COMMIT
	sudo docker buildx build --no-cache -t $(NAME):$(shell date +%Y%m%d) . --build-arg COMMIT=${COMMIT}
else
	sudo docker buildx build --no-cache -t $(NAME):$(shell date +%Y%m%d) .
endif
