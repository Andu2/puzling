SHELL := /bin/bash
.PHONY: plan apply destroy caddy-deploy caddy-dev

include .env
export

plan:
	terraform plan

apply:
	terraform apply

destroy:
	terraform destroy

caddy-deploy:
	ssh andu@shh.puzl.ing "\
		sudo mkdir -p /opt/caddy && sudo chown andu:andu /opt/caddy && \
		sudo mkdir -p /srv/puzlinghome && sudo chown andu:andu /srv/puzlinghome && \
		sudo mkdir -p /var/log/caddy/goaccess-db && sudo chown andu:andu /var/log/caddy/goaccess-db && \
		sudo mkdir -p /var/log/caddy/goaccess-report && sudo chown andu:andu /var/log/caddy/goaccess-report"
	
	rsync -av --delete-delay caddy/ andu@shh.puzl.ing:/opt/caddy/

	ssh andu@shh.puzl.ing "\
		sudo install -m 0644 /opt/caddy/run-goaccess.cron /etc/cron.d/puzling-goaccess && \
		chmod 755 /opt/caddy/run-goaccess.sh"

# TODO: run as andu instead of root, shit's complicated though
	ssh andu@shh.puzl.ing "cd /opt/caddy && sudo docker compose up -d --force-recreate"

caddy-dev:
	cp caddy/goaccess.conf ~/.goaccessrc
# sudo mkdir -p /var/log/caddy/goaccess-db && sudo chown andu:andu /var/log/caddy/goaccess-db
# sudo mkdir -p /var/log/caddy/goaccess-report && sudo chown andu:andu /var/log/caddy/goaccess-report
	cd caddy && CADDY_CONFIG_FILE=Caddyfile.local HTTP_PORT=8080 docker compose up -d --force-recreate --remove-orphans
	@echo "Dev Caddy endpoint: https://localhost:8080"

caddy-analytics:
	goaccess -o /var/log/caddy/goaccess-report/index.html

