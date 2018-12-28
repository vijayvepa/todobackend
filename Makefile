# Project Variables
PROJECT_NAME ?= todobackend
ORG_NAME ?= jmenga
REPO_NAME ?= todobackend

# ?= means this is the default value, overridable from env var

#Filenames
DEV_COMPOSE_FILE := docker/dev/build/docker-compose.yml
REL_COMPOSE_FILE := docker/release/docker-compose.yml

# Docker compose project names
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID) 
# if BUILD_ID is not set, this just evaluates to an empty value, e.g, REL_PROJECT=todobackend, if set BUILDID= 1045,  it will be REL_PROJECT = todobackend1045
DEV_PROJECT := $(REL_PROJECT) dev

.PHONY: test build release clean 
# if we don't have .PHONY declaration, it will treat test, build and release as files and check if they are up to date

clean:
	docker-compose  -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  rm -f 
		docker-compose  -f $(REL_COMPOSE_FILE) kill
	docker-compose   -f $(REL_COMPOSE_FILE)  rm -f 
test:
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) kill
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) rm -f 
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) build 
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) up agent 
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) up test 
build:DEV_PROJECT
	docker-compose  -p $(DEV_PROJECT)   -f $(DEV_COMPOSE_FILE) up builder
	

release:
	docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  build 
	docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  up agent 
	docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  run --rm app manage.py collectstatic --no-input
	docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  run --rm app manage.py migrate --noinput
	docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  up test