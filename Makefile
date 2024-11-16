all: rebuild up

up:
	docker compose up -d

down:
	docker compose down

build:
	$(MAKE) -C ../landing-backend build
	docker compose build

rebuild:
	$(MAKE) -C ../landing-backend rebuild
	docker compose build --no-cache

clean:
	- docker ps -a --filter "name=landing" -q | xargs -r docker stop
	- docker ps -a --filter "name=landing" -q | xargs -r docker rm -f
	- docker images --filter "reference=landing*" -q | xargs -r docker rmi -f
	$(MAKE) -C ../landing-backend clean

fclean: clean
	- docker volume ls --filter "name=landing" -q | xargs -r docker volume rm
	- docker network ls --filter "name=landing" -q | xargs -r docker network rm
	$(MAKE) -C ../landing-backend fclean

re: fclean rebuild up

.PHONY: \
	all build rebuild up down \
	clean fclean re
