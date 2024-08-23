# Define variables
DOCKER_COMPOSE_FILE = maven-docker/docker-compose.yml
GRANT_PRIVILEGES_SCRIPT = maven-docker/grant_mysql_privileges.sh

# Default target
all: up grant_privileges

# Target to bring up the Docker containers
up:
	@echo "Starting Docker containers..."
	docker-compose -f $(DOCKER_COMPOSE_FILE) up -d

# Target to run the grant privileges script
grant_privileges: up
	@echo "Waiting for MySQL to be ready..."
	@sleep 90
	@echo "Running grant privileges script..."
	@bash $(GRANT_PRIVILEGES_SCRIPT)

# Target to stop the containers
down:
	@echo "Stopping Docker containers..."
	docker-compose -f $(DOCKER_COMPOSE_FILE) down

# Cleanup target
clean: down
	@echo "Cleaning up Docker volumes..."
	docker-compose -f $(DOCKER_COMPOSE_FILE) down -v

.PHONY: all up grant_privileges down clean
