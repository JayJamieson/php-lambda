# php-lambda

Run php on AWS lambda with terraform for IaC

## Branches

This repo is setup to with separate branches for different use cases of running php on lambda.

- `main` shows a basic event handler lambda triggered by new files put into s3
- `php-view` shows a *basic* setup for rendering php views and a router for dispatching to the respective view handler
- `php-api` shows a symfony api project with api gateway `{proxy+}` route handling requests and symfony handling routing

## Requirements

- terraform cli
- php >=8.0
- composer

## Setup

### PHP

- Install php dependencies with `composer install`

### Terraform and Infrastructure

- Initialize terraform with `cd ./infrastructure && terraform init`

## Links

- [Bref runtime layers](https://runtimes.bref.sh/)
