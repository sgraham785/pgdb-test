.DEFAULT_GOAL := all

########################
## Helpers variables
########################
M=$(shell printf "\033[34;1m▶\033[0m")
TIMESTAMP := $(shell /bin/date "+%Y-%m-%d_%H-%M-%S")

all: build build-image push-image deploy ; $(info $(M) Done...)

######
## Build targets
######
build: rm-bin ; $(info $(M) Building project server...)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o ./bin/eli-pgdb-test ./


######
## Docker commands
######
.PHONY: build-image

build-image: ; $(info $(M) Building docker image...)
	docker build -t eli-pgdb-test .

######
## Ship commands
######
.PHONY: ecr-login push-image

ecr-login: ; $(info $(M) Logging in to Amazon ECR...)
	$(shell aws ecr get-login --no-include-email --region us-east-1)

push-image: ecr-login ; $(info $(M) Pushing docker image...)
	docker tag eli-pgdb-test:latest 872941275684.dkr.ecr.us-east-1.amazonaws.com/eli-pgdb-test:latest
	docker push 872941275684.dkr.ecr.us-east-1.amazonaws.com/eli-pgdb-test:latest

deploy: ; $(info $(M) Deploying to k8s...)
	kubectl apply -f k8s.yml -n acceptance --context canary-eks
######
## Clean up commands
######
.PHONY: rm-bin

rm-bin: ; $(info $(M) Removing ./bin files... )
	sudo rm -rf ./bin
