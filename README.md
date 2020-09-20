# IP Syncer

This service is a Kubernetes cronjob that renews the public IP in a record on Cloudflare's DNS service.

Every minute the cronjob will ask using dig command which is the public ip, and then update it in the DNS administrator.

The solution is cross-platform so it can be used in `arm` or `amd64` architectures.

## Installation

For installation the service you must run the following commands

- `git clone git@github.com:blue-factory/ip-syncer.git`: Command used to clone repository.
- `cp .sample-env .env`: Command used to copy base for environment values. Complete this.
- `make configure`: Command used to configure service.

## Local environment 💻

### Run in local

- `make run`: command used to run the service.

_note_: always check if `.env` values are valid to use in `local` environment.

## Cloud environment ☁️

### Deploying service 🚀

- `make deploy`: command used to compile the Dockerfile, push in the registry and update YAML file in Kubernetes cluster

_note_: always check if `.env` values are valid to use in `development|staging|production` environment.

### Destroy service 💥

- `make destroy`: command used to destroy a current deploy.
