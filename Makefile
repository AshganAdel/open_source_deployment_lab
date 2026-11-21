up:
	docker compose up -d

ps: 
	docker compose ps

clean:
	@if [ "$(CONFIRM_CLEAN)" != "yes" ]; then \
	    echo "Use CONFIRM_CLEAN=yes"; \
		exit 1; \
	fi 
	docker compose down -v 

down:
	docker compose down

backup-db:
	docker compose --env-file .env exec mariadb \
		sh -c 'mariadb-dump -uroot -p"$$MARIADB_ROOT_PASSWORD" "$$MARIADB_DATABASE"' \
		> wordpress_backup.sql

restore:
	@if [ "$(CONFIRM_RESTORE)" != "yes" ]; then \
	    echo "Use CONFIRM_RESTORE=yes"; \
		exit 1; \
	fi 
	docker compose --env-file .env exec -T mariadb \
	    sh -c 'mariadb -uroot -p"$$MARIADB_ROOT_PASSWORD" "$$MARIADB_DATABASE"' \
		< wordpress_backup.sql

logs:
	docker compose logs mariadb -f

simulate-db-failure:
