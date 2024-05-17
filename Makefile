HELM_CHARTS_TO_PUBLISH=test-equipment
JIVE ?= false# Enable jive
TARANTA ?= false# Enable Taranta
MINIKUBE ?= false ## Minikube or not
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

include resources/makefiles/test-equipment.mk
include resources/makefiles/test-equipment-dev.mk
include resources/makefiles/file-browser.mk
