.PHONY: check deploy expose url status scale load cleanup

NS ?= default
INGRESS_CLASS ?= traefik
TRAEFIK_NS ?= traefik
TRAEFIK_SVC ?= traefik
MANIFEST_URL ?= https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml

check:
	NS=$(NS) INGRESS_CLASS=$(INGRESS_CLASS) TRAEFIK_NS=$(TRAEFIK_NS) TRAEFIK_SVC=$(TRAEFIK_SVC) ./demo/00-check.sh

deploy:
	NS=$(NS) MANIFEST_URL=$(MANIFEST_URL) ./demo/01-deploy.sh

expose:
	NS=$(NS) ./demo/02-expose-traefik.sh

url:
	TRAEFIK_NS=$(TRAEFIK_NS) TRAEFIK_SVC=$(TRAEFIK_SVC) ./demo/03-get-url.sh

status:
	NS=$(NS) TRAEFIK_NS=$(TRAEFIK_NS) TRAEFIK_SVC=$(TRAEFIK_SVC) ./demo/90-status.sh

scale:
	@echo "Usage: make scale REPLICAS=25"; true

load:
	@echo "Usage: make load URL=$$(make -s url)"; true

cleanup:
	NS=$(NS) MANIFEST_URL=$(MANIFEST_URL) ./demo/99-cleanup.sh
