# php-lambda

Run php on AWS lambda with terraform for IaC

## Requirements

- terraform cli
- php >=7.4
- composer

## Setup

This simple uses Api Gateway v2 http integration with aws lambda. A catchall default route is configured to forward all requests to the `index.php` file acting as the handler.

A simple router.php handles mapping requests to handler functions or php view files. Notably we call `getenv('LAMBDA_TASK_ROOT')` to get the directory of running application for handling
file includes. This is because the lambda runtime doesn't configure `$_SERVER['DOCUMENT_ROOT']` such as Apache or Nginx does for us.

- `index.php` handles bootstrapping application with `autoloading` and invoking route handlers. This could be modified to setup better logging and database connections
- `router.php` is copied from <https://github.com/phprouter/main> and is a very *basic* router of paths to handlers
- `home.php` renders landing page with default html and displays basic info about the request url and user IP

### PHP

- Install php dependencies with `composer install`

### Terraform and Infrastructure

- Initialize terraform with `cd ./infrastructure && terraform init`
- Package handler and vendor dependencies into zip file for initial terraform apply with `zip -r function.zip ./ -x "./infrastructure/*"`
- Copy to infrastructure directory `cp function.zip ./infrastructure/`
- Deploy infrastructure with `cd ./infrastructure && terraform apply --auto-approve`

Once completed successfuly you can now deploy new changes with `./deploy.sh` from the root project directory.

## Running locally

- `php -S localhost:8000`
