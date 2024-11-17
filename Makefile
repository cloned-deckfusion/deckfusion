all: rebuild up

up:
	docker compose up -d

down:
	docker compose down

build:
	$(MAKE) -C ../deckfusion-landing build
	docker compose build

rebuild:
	$(MAKE) -C ../deckfusion-landing rebuild
	docker compose build --no-cache

clean:
	- docker ps -a --filter "name=deckfusion" -q | xargs -r docker stop
	- docker ps -a --filter "name=deckfusion" -q | xargs -r docker rm -f
	- docker images --filter "reference=deckfusion*" -q | xargs -r docker rmi -f
	$(MAKE) -C ../deckfusion-landing clean

fclean: clean
	- docker volume ls --filter "name=deckfusion" -q | xargs -r docker volume rm
	- docker network ls --filter "name=deckfusion" -q | xargs -r docker network rm
	$(MAKE) -C ../deckfusion-landing fclean

re: fclean rebuild up

.PHONY: \
	all build rebuild up down \
	clean fclean re
