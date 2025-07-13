SHELL := /bin/bash
.PHONY: plan apply destroy

include .env
export

plan:
	terraform plan

apply:
	terraform apply

destroy:
	terraform destroy

deploy-caddy:
	ssh andu@shh.puzl.ing "sudo mkdir -p /opt/caddy && sudo chown andu:andu /opt/caddy && \
		sudo mkdir -p /srv/puzlinghome && sudo chown andu:andu /srv/puzlinghome && \
		sudo mkdir -p /srv/devdoctrine && sudo chown andu:andu /srv/devdoctrine"
	scp docker-compose.yml andu@shh.puzl.ing:/opt/caddy/docker-compose.yml
	scp -r conf andu@shh.puzl.ing:/opt/caddy/conf
# TODO: run as andu instead of root, shit's complicated though
	ssh andu@shh.puzl.ing "cd /opt/caddy && sudo docker compose up -d"
