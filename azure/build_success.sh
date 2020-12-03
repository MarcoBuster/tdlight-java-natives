#!/bin/bash -e
set -e

source ./azure/setup_variables.sh

cd ./scripts/

./deploy_snapshot.sh

echo "Build success"
exit 0
