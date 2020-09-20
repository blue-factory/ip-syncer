# load .env file
include .env
export $(shell sed 's/=.*//' .env)

# detect system operative
CURRENT_OS=
UNAME_S=$(shell uname -s)
ifeq ($(UNAME_S),Linux)
	CURRENT_OS=linux
endif
ifeq ($(UNAME_S),Darwin)
	CURRENT_OS=darwin
endif

# detect system architecture
CURRENT_ARCH=
UNAME_M=$(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	CURRENT_ARCH=amd64
endif
ifneq ($(filter arm%,$(UNAME_M)),)
	CURRENT_ARCH=arm
endif

#
# INTERNAL VARIABLES
#	note: should export env values form .env
#				- SVC
#       - VERSION
# 			- DOCKER_USER
# 			- DOCKER_PASSWORD
#				- API_KEY
#				- API_EMAIL
#				- DOMAIN
#				- RECORD
#
BIN=$(PWD)/bin/$(SVC)
REGISTRY_URL=$(DOCKER_USER)
CONTAINER_NAME=$(SVC):$(VERSION)
REGISTRY_CONTAINER_NAME=$(REGISTRY_URL)/$(CONTAINER_NAME)

#
# TARGETS
#
configure:
	@echo "[configure] Configuring service for..."
	@kubectl create configmap $(SVC)-env --from-env-file=.env || true
	@kubectl create configmap $(SVC)-env --from-env-file=.env -o yaml --dry-run | kubectl replace -f -

clean c:
	@echo "[clean] Cleaning bin folder..."
	@rm -rf bin/

run r: clean
	@echo "[running] Running service..."
	@API_KEY=$(API_KEY) \
	API_EMAIL=$(API_EMAIL) \
	DOMAIN=$(DOMAIN) \
	RECORD=$(RECORD) \
	GOOS=$(CURRENT_OS) \
	GOARCH=$(CURRENT_ARCH) \
	go run cmd/$(SVC)/main.go

build: clean
	@echo "[build] Building service using SO: $(TARGET_SO) ARCH: $(TARGET_ARCH)..."
	@cd cmd/$(SVC) && GOOS=$(TARGET_SO) GOARCH=$(TARGET_ARCH) go build -o $(BIN)

docker: build
	@echo "[docker] Building docker image..."
	@docker build -t $(CONTAINER_NAME) -f Dockerfile.$(TARGET_ARCH) .

docker-run: docker
	@echo "[docker] Running docker image..."
	@docker run -it \
	--env-file $(PWD)/.env \
	$(CONTAINER_NAME)
	
docker-login:
	@echo "[docker] Login to docker..."
	@docker login -u $(DOCKER_USER) -p $(DOCKER_PASSWORD)

docker-push: docker docker-login
	@echo "[docker] pushing $(REGISTRY_CONTAINER_NAME)"
	@docker tag $(CONTAINER_NAME) $(REGISTRY_CONTAINER_NAME)
	@docker push $(REGISTRY_CONTAINER_NAME)

deploy: docker-push configure
	@echo "[deploy] deploying..."
	@kubectl apply -f infra/$(SVC).yaml

destroy:
	@echo "[destroy] destroying..."
	@kubectl delete -f infra/$(SVC).yaml
	@kubectl delete configmap $(SVC)-env

.PHONY: clean c run r build b linux l docker d docker-login dl push p 