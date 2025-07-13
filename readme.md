# puzl.ing Infrastructure

Infrastructure for my personal apps

 - **Vercel** for frontend apps that use a framework
 - A single **DigitalOcean Droplet** for more custom apps or apps that need a backend
   - **cloud-init** for Droplet setup
   - **Docker** containers for each app on the Droplet
   - **Caddy** to route traffic to each app
 - **Porkbun** domain name registry
 - **CloudFlare** Proxy / DNS
 - **Terraform** to configure it all
 - **make** to deploy

## Required Setup

### .env Vars

```sh
DIGITALOCEAN_TOKEN=

PORKBUN_API_KEY=
PORKBUN_SECRET_API_KEY=

CLOUDFLARE_API_TOKEN=
TF_VAR_cf_zone_id=

VERCEL_API_TOKEN=

APPDIR_DEVDOCTRINE=
APPDIR_PUZLINGHOME=
```

## Todo

 - More secure SSH
 - Better deployment of Caddy
 - DNSSEC?

## Notes

 - Don't create Vercel projects or GitHub repos with Terraform, that's way overkill
