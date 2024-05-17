# File browser vars
FILEBROWSER_ENV ?= dev
FILEBROWSER_CONFIG_SECRET_FILE := config.json
# This is overwritten in CI/CD
FILEBROWSER_CONFIG_PATH ?= ./charts/file-browser/secrets/example.json
FILEBROWSER_CONFIG_SECRET_NAME := file-browser-config-secret

## TARGET: file-browser-install
## SYNOPSIS: make file-browser-install
## HOOKS: none
## VARS:
##	FILEBROWSER_ENV=[environment-name] (default value: dev)
##	FILEBROWSER_CONFIG_SECRET_FILE=[name of file containing secrets (not path)] (default value: config.json)
##	FILEBROWSER_CONFIG_SECRET_NAME=[name of k8s secret created by file-browser-secrets] (default value: file-browser-config-secret)
##  make target for deploying the spectrum analyser file browser.

file-browser-install: K8S_CHART_PARAMS := $(K8S_CHART_PARAMS) --set mounts.configSecret.name=$(FILEBROWSER_CONFIG_SECRET_NAME) \
	--set mounts.configSecret.dest=$(FILEBROWSER_CONFIG_SECRET_FILE) \
	--set env.type=$(FILEBROWSER_ENV)
file-browser-install: K8S_CHART := ska-mid-itf-environments-file-browser
file-browser-install: KUBE_NAMESPACE := file-browser
file-browser-install: k8s-uninstall-chart file-browser-secrets k8s-install-chart

## TARGET: file-browser-secrets
## SYNOPSIS: make file-browser-secrets
## HOOKS: none
## VARS:
##	FILEBROWSER_CONFIG_PATH=[path to json config file with secrets. Overriden in CI/CD.] (default value: ../charts/file-browser/secrets/config.json)
##	FILEBROWSER_CONFIG_SECRET_FILE=[name of file containing secrets (not path).] (default value: config.json)
##	FILEBROWSER_CONFIG_SECRET_NAME=[name of k8s secret created by file-browser-secrets] (default value: file-browser-config-secret)
##  make target for creating k8s secret from JSON file located at $(FILEBROWSER_CONFIG_PATH)

file-browser-secrets: k8s-namespace
	kubectl delete secret -n $(KUBE_NAMESPACE) --ignore-not-found=true file-browser-config-secret
	kubectl create secret -n $(KUBE_NAMESPACE) generic $(FILEBROWSER_CONFIG_SECRET_NAME) --from-file=$(FILEBROWSER_CONFIG_SECRET_FILE)=$(FILEBROWSER_CONFIG_PATH)
