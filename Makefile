SPOOKD_VALUES=charts/ska-mid-itf-ghosts/values.yaml
SPOOKD_VERSION=0.2.2
SPOOKD_NAMESPACE=spookd

OCI_BUILD_ADDITIONAL_ARGS += --cache-from registry.gitlab.com/ska-telescope/ska-mid-itf/ska-mid-itf-base:0.1.4

HELM_CHARTS_TO_PUBLISH=ska-mid-itf dish-lmc ska-db-oda-mid-itf ska-mid-itf-ghosts system-under-test
PYTHON_VARS_AFTER_PYTEST= --disable-pytest-warnings
POETRY_CONFIG_VIRTUALENVS_CREATE = true

# VALUES ?= $(K8S_UMBRELLA_CHART_PATH)values.yaml
XAUTHORITY ?= $(HOME)/.Xauthority
THIS_HOST := $(shell ip a 2> /dev/null | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n1)
DISPLAY ?= $(THIS_HOST):0
JIVE ?= false# Enable jive
TARANTA ?= false# Enable Taranta
MINIKUBE ?= true ## Minikube or not
EXPOSE_All_DS ?= true ## Expose All Tango Services to the external network (enable Loadbalancer service)
SKA_TANGO_OPERATOR ?= true
EXPOSE_DATABASE_DS ?= true## 
TANGO_DATABASE_DS ?= tango-databaseds## TANGO_DATABASE_DS name
TANGO_HOST ?= tango-databaseds:10000## TANGO_HOST connection to the Tango DS
TANGO_SERVER_PORT ?= 45450## TANGO_SERVER_PORT - fixed listening port for local server
CLUSTER_DOMAIN = miditf.internal.skao.int## Domain used for naming Tango Device Servers
INGRESS_HOST = k8s.$(CLUSTER_DOMAIN)## Tango host, cluster domain, what are all these things???
ITANGO_ENABLED ?= true## ITango enabled in ska-tango-base
PYTHON_RUNNER = poetry run python3 -m
PYTHON_LINE_LENGTH = 99
DOCS_SPHINXBUILD = poetry run python3 -msphinx
PYTHON_TEST_FILE = tests/unit/ tests/functional/
PYTHON_LINT_TARGET ?= tests/

K8S_CHART_PARAMS ?= --set global.minikube=$(MINIKUBE) \
	--set global.exposeAllDS=$(EXPOSE_All_DS) \
	--set global.exposeDatabaseDS=$(EXPOSE_DATABASE_DS) \
	--set global.tango_host=$(TANGO_HOST) \
	--set global.device_server_port=$(TANGO_SERVER_PORT) \
	--set global.cluster_domain=$(CLUSTER_DOMAIN) \
	--set global.labels.app=$(KUBE_APP) \
	--set global.operator=$(SKA_TANGO_OPERATOR) \
	--set ska-tango-base.display=$(DISPLAY) \
	--set ska-tango-base.xauthority=$(XAUTHORITY) \
	--set ska-tango-base.jive.enabled=$(JIVE) \
	--set ska-tango-base.itango.enabled=$(ITANGO_ENABLED) 

# include core make support
include .make/base.mk

# include makefile targets from the submodule
include .make/oci.mk

# include k8s support
include .make/k8s.mk

# include Helm Chart support
include .make/helm.mk

# Include Python support
include .make/python.mk

# include raw support
include .make/raw.mk

# include Xray uploads
include .make/xray.mk

itf-te-pass-env: KUBE_NAMESPACE := test-equipment
itf-te-pass-env: itf-skysimctl-links## Generate Gitlab CI configuration for SkySimCtl device server deployment

itf-te-template:
	@make k8s-template-chart
	@mkdir -p build
	@mv manifests.yaml build/

itf-links: ## Create the URLs with which to access the Tango Control System if it is available
	@echo ${CI_JOB_NAME}
	@echo "##############################################################################################"
	@echo "#        Access the Taranta framework for the $(shell echo $(KUBE_APP) | tr a-z A-Z) Tango Control System here:"
	@echo "#        https://$(INGRESS_HOST)/$(KUBE_NAMESPACE)/taranta/devices"
	@echo "##############################################################################################"

itf-skysimctl-links:
	@echo "KUBE_NAMESPACE=$(KUBE_NAMESPACE)"
	@mkdir -p build
	echo "TANGO_HOST=$(shell kubectl get -n $(KUBE_NAMESPACE) svc tango-databaseds -o jsonpath={'.status.loadBalancer.ingress[0].ip'}):10000" > build/deploy.env
	@echo "######################################################################"
	@echo "# THIS PIPELINE IS RUNNING FOR THE $(CI_COMMIT_REF_NAME) BRANCH"
	@echo "######################################################################"
	@if [[ -z "$(CI_COMMIT_REF_NAME)" ]]; then exit 1; fi
	@echo
	@echo "Exporting CI variables"
	@echo "UPSTREAM_CI_COMMIT_REF_NAME=$(CI_COMMIT_REF_NAME)" >> build/deploy.env # This is a workaround - see https://gitlab.com/gitlab-org/gitlab/-/issues/331596
	@echo "UPSTREAM_CI_JOB_ID=$(CI_JOB_ID)" >> build/deploy.env
	@cat build/deploy.env

itf-spookd-uninstall:
	@make k8s-uninstall-chart K8S_CHART=ska-mid-itf-ghosts KUBE_APP=spookd KUBE_NAMESPACE=$(SPOOKD_NAMESPACE) HELM_RELEASE=whoyougonnacall

