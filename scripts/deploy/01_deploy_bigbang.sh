#!/usr/bin/env bash

set -ex

# Deploy flux and wait for it to be ready
echo "Installing Flux"
flux --version
flux check --pre

# Install flux in the cluster
kubectl create ns flux-system || true

if [[ -z "${AIRGAP}" ]]; then
# TODO When changing the flux images to .mil this will need to chagne
kubectl create secret docker-registry private-registry -n flux-system \
   --docker-server=registry1.dsop.io \
   --docker-username='robot$bigbang' \
   --docker-password=${REGISTRY1_PASSWORD} \
   --docker-email=bigbang@bigbang.dev || true
fi
kubectl apply -f ./scripts/deploy/flux.yaml

# Wait for flux
kubectl wait --for=condition=available --timeout 300s -n "flux-system" "deployment/helm-controller"
kubectl wait --for=condition=available --timeout 300s -n "flux-system" "deployment/source-controller"
flux check

# Deploy BigBang using dev sized scaling
echo "Installing BigBang"
if [[ -z "${AIRGAP}" ]]; then
helm upgrade -i bigbang chart -n bigbang --create-namespace \
--set registryCredentials[0].username='robot$bigbang' --set registryCredentials[0].password=${REGISTRY1_PASSWORD} \
--set registryCredentials[0].registry=registry1.dsop.io                                                         \
--set registryCredentials[1].username='robot$bigbang' --set registryCredentials[1].password=${REGISTRY1_PASSWORD} \
--set registryCredentials[1].registry=registry1.dso.mil                                                         \
-f tests/ci/k3d/values.yaml
else
helm upgrade -i bigbang chart -n bigbang --create-namespace \
-f tests/ci/k3d/values.yaml --set registryCredentials=null
fi

## Apply secrets kustomization pointing to current branch
echo "Deploying secrets from the ${CI_COMMIT_REF_NAME} branch"
if [[ -z "${CI_COMMIT_TAG}" ]]; then
  cat tests/ci/shared-secrets.yaml | sed 's|master|'$CI_COMMIT_REF_NAME'|g' | kubectl apply -f -
else
  # NOTE: $CI_COMMIT_REF_NAME = $CI_COMMIT_TAG when running on a tagged build
  cat tests/ci/shared-secrets.yaml | sed 's|branch: master|tag: '$CI_COMMIT_REF_NAME'|g' | kubectl apply -f -
fi