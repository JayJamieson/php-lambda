# php-lambda

Run php on AWS lambda with terraform for IaC

## Requirements

- terraform cli
- php >=8.0
- composer

## Setup

This uses api gateway and symfony framework to demonstrate setting up an API running on AWS Lambda. See <https://bref.sh/docs/frameworks/symfony.html> for more details

### PHP

- Install php dependencies with `composer install`

### Terraform and Infrastructure

- Create `<environment.tfvars` variable file and fill out required variables
- Initialize terraform with `cd ./infrastructure && terraform init`
- Set environment to production using `export APP_ENV=prod`
- clean up dependencies from developement `composer install --prefer-dist --optimize-autoloader --no-dev`
- Warm up cache `php bin/console cache:warmup --env=prod`
- Package handler and vendor dependencies into zip file for initial terraform apply with `zip -r function.zip ./ -x "./infrastructure/*"`
- Copy to infrastructure directory `cp function.zip ./infrastructure/`
- Deploy infrastructure with `cd ./infrastructure && terraform apply --auto-approve`
- Once completed successfuly you can now deploy new changes with `./deploy.sh` from the root project directory.
