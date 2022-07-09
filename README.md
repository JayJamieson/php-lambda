# php-lambda

Run php on AWS lambda with terraform for IaC

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
