# Makefile – convenience helpers

IMAGE_REPO ?= ghcr.io/$(shell git config --get remote.origin.url | sed -E 's#.*/([^/]+)\.git#\1#')
IMAGE_NAME ?= talos-edid-extension
IMAGE_TAG  ?= latest
PLATFORMS  ?= linux/amd64,linux/arm64

IMAGE := $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: build push tag

build:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --tag $(IMAGE) \
	  --push=false \
	  .

push:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --tag $(IMAGE) \
	  --push \
	  .

tag:
	docker tag $(IMAGE) $(IMAGE_REPO)/$(IMAGE_NAME):$(VERSION) 