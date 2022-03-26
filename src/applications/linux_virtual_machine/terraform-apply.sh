#! /bin/bash

terraform -chdir="$(dirname $(realpath $0))" apply "linux-vm.plan"