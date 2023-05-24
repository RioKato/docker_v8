NAME=v8

build:
	sudo docker buildx build -t $(NAME):$(shell date +%Y%m%d) .
