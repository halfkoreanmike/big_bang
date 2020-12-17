#!/bin/bash

# exit on error
set -e

echo "Checking "
hosts=`kubectl get vs -A -o jsonpath="{ .items[*].spec.hosts[*] }"`
for host in $hosts; do
    curl -vfI https://$host
done