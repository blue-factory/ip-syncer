# IP Syncer

This service is a Kubernetes cronjob responsible for renewing the public IP to a record in Cloudflare's DNS.

Every minute the cronjob will ask using dig command which is the public ip, and then update it in the DNS administrator.

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

- `make deploy`: command used to transpile all typescript files to javascript files. After to run this command will be copy the graphql and seeds files.

_note_: always check if `.env` values are valid to use in `development|staging|production` environment.

### Destroy service 💥

- `make destroy`: command used to destroy a current deploy.
