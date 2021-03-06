# php-lambda

Run php on AWS lambda with terraform for IaC

## Branches

This repo is setup to with separate branches for different use cases of running php on lambda.

- `main` shows a basic event handler lambda triggered by new files put into s3
- `php-view` shows a *basic* setup for rendering php views and a router for dispatching to the respective view handler
- `php-api` shows a symfony api project with api gateway `{proxy+}` route handling requests and symfony handling routing

## Requirements

- terraform cli
- php >=7.4
- composer

## Setup

### PHP

- Install php dependencies with `composer install`

### Terraform and Infrastructure

- Initialize terraform with `cd ./infrastructure && terraform init`
- Package handler and vendor dependencies into zip file for initial terraform apply with `zip -r function.zip ./ -x "./infrastructure/*"`
- Copy to infrastructure directory `cp function.zip ./infrastructure/`
- Deploy infrastructure with `cd ./infrastructure && terraform apply --auto-approve`

Once completed successfuly you can now deploy new changes with `./deploy.sh` from the root project directory.
