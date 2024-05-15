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

itf-te-install:
	@make vars;
	@make k8s-install-chart

itf-te-template:
	@make vars;
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

