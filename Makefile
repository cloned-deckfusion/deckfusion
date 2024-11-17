all: rebuild up

up:
	docker compose up -d

down:
	docker compose down

build: check-env
	$(MAKE) -C ../deckfusion-backend build
	$(MAKE) -C ../deckfusion-landing build
	docker compose build

rebuild: check-env
	$(MAKE) -C ../deckfusion-backend rebuild
	$(MAKE) -C ../deckfusion-landing rebuild
	docker compose build --no-cache

clean:
	- docker ps -a --filter "name=deckfusion" -q | xargs -r docker stop
	- docker ps -a --filter "name=deckfusion" -q | xargs -r docker rm -f
	- docker images --filter "reference=backend_base*" -q | xargs -r docker rmi -f
	- docker images --filter "reference=deckfusion*" -q | xargs -r docker rmi -f
	$(MAKE) -C ../deckfusion-landing clean
	$(MAKE) -C ../deckfusion-backend clean

fclean: clean
	- docker volume ls --filter "name=deckfusion" -q | xargs -r docker volume rm
	- docker network ls --filter "name=deckfusion" -q | xargs -r docker network rm
	$(MAKE) -C ../deckfusion-landing fclean
	$(MAKE) -C ../deckfusion-backend fclean

re: fclean rebuild up

check-env:
	@test -f .env || (echo ".env not found. Copying .env.example to .env."; cp .env.example .env)

.PHONY: \
	all build rebuild up down \
	clean fclean re check-env
