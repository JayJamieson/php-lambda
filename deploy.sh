#!/bin/bash

zip -r function.zip ./ -x "./infrastructure/*"

cp function.zip ./infrastructure/

cd infrastructure

terraform apply --auto-approve

cd ../