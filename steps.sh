#############################################################################################################################
# This file contains a few nice commands to generate a local environment as close as possible to that of the Gitlab Runner. #
#############################################################################################################################

# run the dockerfile
set IMAGE artefact.skao.int/ska-cicd-k8s-tools-build-deploy
set IMAGE_VERSION 0.13.6
docker run -it -e CI_COMMIT_SHA=$(git rev-parse --short HEAD) --env-file PrivateRules.mak $IMAGE:$IMAGE_VERSION

# git clone (to mimic the pipeline start)
mkdir /build && mkdir /build/ska-telescope && cd /build/ska-telescope 
git clone --recurse-submodules https://gitlab.com/ska-telescope/aiv/ska-mid-itf-environments.git && cd ska-mid-itf-environments
git checkout $CI_COMMIT_SHA -q && git show -q

