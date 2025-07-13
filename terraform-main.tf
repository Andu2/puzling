terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    porkbun = {
      source  = "kyswtn/porkbun"
      version = "~> 0.1.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    vercel = {
      source  = "vercel/vercel"
      version = "~> 3.8.0"
    }
  }
}

resource "porkbun_nameservers" "puzling" {
  domain = "puzl.ing"
  nameservers = [
    "jamie.ns.cloudflare.com",
    "stanley.ns.cloudflare.com"
  ]

  lifecycle {
    prevent_destroy = true
  }
}

variable "cf_zone_id" {
  description = "Cloudflare zone ID for puzl.ing"
}

data "digitalocean_ssh_key" "AnduBox" {
  name = "AnduBox"
}

resource "cloudflare_dns_record" "puzling" {
  zone_id = var.cf_zone_id
  type    = "A"
  name    = "@"
  content = digitalocean_droplet.puzling.ipv4_address
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "puzling_ipv6" {
  zone_id = var.cf_zone_id
  type    = "AAAA"
  name    = "@"
  content = digitalocean_droplet.puzling.ipv6_address
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cf_zone_id
  type    = "CNAME"
  name    = "www"
  content = "@"
  ttl     = 1
  proxied = true
}

// TODO: Exposing this means I'm only proxied through obscurity
// Someone could look up the DNS records and find this subdomain and then the IP
resource "cloudflare_dns_record" "ssh" {
  zone_id = var.cf_zone_id
  type    = "A"
  name    = "shh"
  content = digitalocean_droplet.puzling.ipv4_address
  ttl     = 1
  proxied = false
}

// To get special BlueSky username
resource "cloudflare_dns_record" "bsky" {
  zone_id = var.cf_zone_id
  type    = "TXT"
  name    = "_atproto"
  content = "did=did:plc:grl6q3rtnwzknh7bwyvimpsc"
  ttl     = 1
}

resource "digitalocean_droplet" "puzling" {
  image      = "ubuntu-24-04-x64"
  name       = "puzling"
  region     = "nyc3"
  size       = "s-1vcpu-1gb"
  ssh_keys   = [data.digitalocean_ssh_key.AnduBox.id]
  monitoring = true
  ipv6       = true
  user_data  = file("cloud-init.yaml")
}

resource "digitalocean_firewall" "puzling_firewall" {
  name        = "puzling-firewall"
  droplet_ids = [digitalocean_droplet.puzling.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22" #ssh
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80" #http
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443" #https
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

// Vercel projects
data "vercel_project" "porker" {
  name = "porker"
}

resource "vercel_project_domain" "porker" {
  project_id = data.vercel_project.porker.id
  domain     = "porker.puzl.ing"
}

resource "cloudflare_dns_record" "porker-cname" {
  zone_id = var.cf_zone_id
  type    = "CNAME"
  name    = "porker"
  content = "cname.vercel-dns.com"
  ttl     = 1
}

data "vercel_project" "wtf" {
  name = "andu-wtf-wipn"
}

resource "vercel_project_domain" "wtf" {
  project_id = data.vercel_project.wtf.id
  domain     = "wtf.puzl.ing"
}

resource "cloudflare_dns_record" "wtf-cname" {
  zone_id = var.cf_zone_id
  type    = "CNAME"
  name    = "wtf"
  content = "cname.vercel-dns.com"
  ttl     = 1
}

data "vercel_project" "svg" {
  name = "svg-chara-gen"
}

resource "vercel_project_domain" "svg" {
  project_id = data.vercel_project.svg.id
  domain     = "svg.puzl.ing"
}

resource "cloudflare_dns_record" "svg-cname" {
  zone_id = var.cf_zone_id
  type    = "CNAME"
  name    = "svg"
  content = "cname.vercel-dns.com"
  ttl     = 1
}

data "vercel_project" "pricalc" {
  name = "pricalc-ateb"
}

resource "vercel_project_domain" "pricalc" {
  project_id = data.vercel_project.pricalc.id
  domain     = "priconne.puzl.ing"
}

resource "cloudflare_dns_record" "pricalc-cname" {
  zone_id = var.cf_zone_id
  type    = "CNAME"
  name    = "priconne"
  content = "cname.vercel-dns.com"
  ttl     = 1
}

data "vercel_project" "bogol" {
  name = "bogol-td67"
}

resource "vercel_project_domain" "bogol" {
  project_id = data.vercel_project.bogol.id
  domain     = "bogol.puzl.ing"
}

resource "cloudflare_dns_record" "bogol-cname" {
  zone_id = var.cf_zone_id
  type    = "CNAME"
  name    = "bogol"
  content = "cname.vercel-dns.com"
  ttl     = 1
}
