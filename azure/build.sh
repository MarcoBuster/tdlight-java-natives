#!/bin/bash -e
set -e
if [ "$AZURE_CPU_ARCH" = "arm64" ]; then
  while true; do free -h ; sleep 2; done &
fi

source ./azure/setup_variables.sh

cd ./scripts/
./generate_maven_project.sh
./generate_td_tools.sh
./compile_td.sh
./compile_tdjni.sh
./build_generated_maven_project.sh

echo "Done."
exit 0
