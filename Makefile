# Project Variables
PROJECT_NAME ?= todobackend
ORG_NAME ?= jmenga
REPO_NAME ?= todobackend

# ?= means this is the default value, overridable from env var

#Filenames
DEV_COMPOSE_FILE := docker/dev/builder/docker-compose.yml
REL_COMPOSE_FILE := docker/release/docker-compose.yml

# Docker compose project names
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
# if BUILD_ID is not set, this just evaluates to an empty value, e.g, REL_PROJECT=todobackend, if set BUILDID= 1045,  it will be REL_PROJECT = todobackend1045
DEV_PROJECT := $(REL_PROJECT)-dev

# Cosmetics - See http://linuxmanage.com/colored-man-pages-log-files.html
YELLOW := "\\e[0;33m"
NO_COLOR := "\\e[0m"

# Shell Functions
# @bash is same as @echo off in windows
# Only use single quotes, $$1 will be converted to $1
# VALUE is placeholder reference to the arg
INFO := @bash -c '\
	printf $(YELLOW); \
	echo "=> $$1"; \
	printf $(NO_COLOR)' VALUE 

INSPECT := $$(docker-compose -p $$1 -f $$2 ps -q $$3 | xargs -I ARGS docker inspect -f "{{ .State.ExitCode }}" ARGS)

# $1 - project name , $2 docker-compose file #3 - name of the service  => container Id
# docker inspect containerId - filter exitcode => exit code

CHECK := @bash -c '\
  if [[ $(INSPECT) -ne 0 ]]; \
  then exit $(INSPECT); fi' VALUE

.PHONY: test build release clean 
# if we don't have .PHONY declaration, it will treat test, build and release as files and check if they are up to date

clean:
	${INFO} "Destroying dev env..."
	docker-compose  -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  rm -f 
		docker-compose  -f $(REL_COMPOSE_FILE) kill
	docker-compose   -f $(REL_COMPOSE_FILE)  rm -f -v 
	
test:
	${INFO} "Removing Existing Images..."
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) kill
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) rm -f -v
	
	${INFO} "Building Images..."
	@docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) build 
	${INFO} "Ensuring database is ready..."
	@docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) run --rm agent 
	${INFO} "Running tests..."
	docker-compose  -p $(DEV_PROJECT)  -f $(DEV_COMPOSE_FILE) up test 
	${INFO} "Copying reports..."
	docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q test):/reports/. reports 
	${INFO} "Removing orphaned images.."
	@docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS  
	${CHECK} $(DEV_PROJECT) $(DEV_COMPOSE_FILE) test
build:
	${INFO} "Building application artifacts"
	@docker-compose  -p $(DEV_PROJECT)   -f $(DEV_COMPOSE_FILE) up builder
	${CHECK} $(DEV_PROJECT) $(DEV_COMPOSE_FILE) builder 
	${INFO} "Copying artifacts to target folder..."
	# e.g. docker cp CONTAINER_ID:/wheelhouse/. target
	docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q builder):/wheelhouse/. target
	${INFO} "Removing orphaned images.."
	@docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS  
	

release:
	${INFO} "Building release images"
	@docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  build 
	${INFO} "Ensure db is ready.."
	@docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  run --rm agent 
	${INFO} "Collecting static files..."
	@docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  run --rm app manage.py collectstatic --no-input
	${INFO} "Running db migration"
	@docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  run --rm app manage.py migrate --noinput
	${INFO} "Running acceptance tests..."
	@docker-compose  -p $(REL_PROJECT)  -f $(REL_COMPOSE_FILE)  up test
	${INFO} "Copying reports..."
	docker cp $$(docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) ps -q test):/reports/. reports 
	${CHECK} $(REL_PROJECT) $(REL_COMPOSE_FILE) test
	${INFO} "Remove dangling images..."
	docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS  