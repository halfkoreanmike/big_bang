#!/bin/bash

tmpdir="/tmp/umbrella"


usage () {
    echo "USAGE: $0 TODO: "
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--dir)
        tmpdir="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        help="true"
        shift
        ;;
        *)
        usage
        exit 1
        ;;
    esac
done

if [[ $help ]]; then
    usage
    exit 0
fi

# Get repo list:

ISTIO_REPO=`yq r -j chart/values.yaml | jq -r '.istio.git.repo'`
ISTIO_TAG=`yq r -j chart/values.yaml | jq -r '.istio.git.tag'`
ISTIO_OPERATOR_REPO=`yq r -j chart/values.yaml | jq -r '.istiooperator.git.repo'`
ISTIO_OPERATOR_TAG=`yq r -j chart/values.yaml | jq -r '.istiooperator.git.tag'`
CLUSTER_AUDITOR_REPO=`yq r -j chart/values.yaml | jq -r '.clusterAuditor.git.repo'`
CLUSTER_AUDITOR_TAG=`yq r -j chart/values.yaml | jq -r '.clusterAuditor.git.tag'`
LOGGING_
yq r -j chart/values.yaml | jq -r '.gatekeeper.git.repo'
yq r -j chart/values.yaml | jq -r '.logging.git.repo'
yq r -j chart/values.yaml | jq -r '.eckoperator.git.repo'
yq r -j chart/values.yaml | jq -r '.fluentbit.git.repo'
yq r -j chart/values.yaml | jq -r '.monitoring.git.repo'
yq r -j chart/values.yaml | jq -r '.twistlock.git.repo'
yq r -j chart/values.yaml | jq -r '.addons.argocd.git.repo'
yq r -j chart/values.yaml | jq -r '.addons.authservice.git.repo'


# CURRENT_COMMIT=`git rev-parse HEAD`
# CURRENT_REPO=`git config --get remote.origin.url`     

# mkdir -p ${tmpdir}/umbrella
# pushd ${tmpdir}/umbrella
# git init
# git remote add origin ${CURRENT_REPO}
# git fetch --depth 1 origin ${CURRENT_COMMIT}
# popd


# # get the current repo


# git clone ${CURRENT_REPO}

# # kpt umbrella in vendor/umbrella
# mkdir -p vendor/umbrella
# git fetch --depth 1 origin v0.1.
# rm -rf .git
# cd ../../