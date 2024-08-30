# Tell terraform to use the provider and select a version.
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}


# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
}

variable "tailscale_auth_key" {
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "Hogwarts" {
  name     = "Hogwarts"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "Hogwarts-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.Hogwarts.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_network" "Durmstrang" {
  name     = "Durmstrang"
  ip_range = "10.1.0.0/16"
}

resource "hcloud_network_subnet" "Durmstrang-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.Durmstrang.id
  network_zone = "eu-central"
  ip_range     = "10.1.1.0/24"
}

resource "hcloud_server" "Harry" {
  name        = "Harry"
  server_type = "cx22"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    "demo@allaway.tech",
    "demo@dolphin"
  ]

  network {
    network_id = hcloud_network.Hogwarts.id
    #    ip         = "10.0.1.5"
  }

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.Hogwarts-subnet
  ]
}


resource "hcloud_server" "Hermione" {
  name        = "Hermione"
  server_type = "cx22"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    "demo@allaway.tech",
    "demo@dolphin"
  ]

  network {
    network_id = hcloud_network.Hogwarts.id
    #ip         = "10.0.1.6"
  }

  network {
    network_id = hcloud_network.Durmstrang.id
  }

  user_data = templatefile("hetzner.tftpl", { tailscale_auth_key = var.tailscale_auth_key })

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.Hogwarts-subnet,
    hcloud_network_subnet.Durmstrang-subnet
  ]
}


resource "hcloud_server" "Ron" {
  name        = "Ron"
  server_type = "cx22"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    "demo@allaway.tech",
    "demo@dolphin"
  ]

  network {
    network_id = hcloud_network.Hogwarts.id
    #ip         = "10.0.1.7"
  }

  user_data = templatefile("hetzner.tftpl", { tailscale_auth_key = var.tailscale_auth_key })

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.Hogwarts-subnet
  ]
}

resource "hcloud_server" "Krum" {
  name        = "Krum"
  server_type = "cx22"
  image       = "ubuntu-20.04"
  location    = "nbg1"
  ssh_keys = [
    "demo@allaway.tech",
    "demo@dolphin"
  ]

  network {
    network_id = hcloud_network.Durmstrang.id
    #    ip         = "10.0.1.5"
  }

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_network_subnet.Durmstrang-subnet
  ]
}
