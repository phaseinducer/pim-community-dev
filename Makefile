APP=docker-compose exec -T app
CONSOLE=$(APP) app/console

.PHONY: help install pim-install start stop composer db-create db-update clear-cache clear-all perm clean

help:           ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

install:        ## [start composer db-create pim-install clear-all perm] Setup the project using Docker and docker-compose
install: start composer db-create clear-all pim-install perm

pim-install:    ## Install the PIM
	$(CONSOLE) oro:requirejs:generate-config --env=prod
	$(CONSOLE) pim:install --env=prod --force
	$(CONSOLE) asset:install --symlink

start:          ## Start the Docker containers
	docker-compose up -d

stop:           ## Stop the Docker containers
	docker-compose down

composer:       ## Install the project PHP dependencies
	$(APP) composer install -o

db-create:      ## Create the database and load the fixtures in it
	$(APP) php -r "for(;;){if(@fsockopen('db',3306)){break;}}" # Wait for MySQL
	$(CONSOLE) do:da:dr --connection=default --force --if-exists
	$(CONSOLE) do:da:cr --connection=default --if-not-exists
	$(CONSOLE) do:sc:cr

db-update:      ## Update the database structure according to the last changes
	$(CONSOLE) doctrine:schema:update --force

clear-cache:    ## Clear the application cache in development
	$(CONSOLE) cache:clear

clear-all:      ## Deeply clean the application (remove all the cache, the logs, the sessions and the built assets)
	$(APP) rm -fr app/archive/*
	$(APP) rm -fr app/cache/*
	$(APP) rm -fr app/file_storage/*
	$(APP) rm -rf app/logs/*
	$(APP) rm -rf app/sessions/*
	$(APP) rm -rf web/bundles/*
	$(APP) rm -rf web/css/*
	$(APP) rm -rf web/js/*
	$(APP) rm -rf web/media/*
	$(APP) rm -rf supervisord.log supervisord.pid .tmp

clean:          ## Removes all generated files
	- @make clear-all
	$(APP) rm -rf vendor

perm:           ## Fix the application cache and logs permissions
	$(APP) chmod 777 -R app/cache app/logs app/sessions app/archive app/file_storage web/
