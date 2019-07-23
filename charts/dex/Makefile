CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := dex
OS := $(shell uname)

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass)

init: 
	helm init --client-only

setup: init
	helm repo add jenkins-x-api https://chartmuseum.build.cd.jenkins-x.io 	
	helm repo add jenkinsxio https://chartmuseum.jx.cd.jenkins-x.io 

build: clean
	helm dependency build
	helm lint
	helm template .

install: clean setup build
	helm install . --name ${NAME}
	watch kubectl get pods

upgrade: clean stup build
	helm upgrade ${NAME} .
	watch kubectl get pods

delete:
	helm delete --purge ${NAME}

clean:
	rm -rf charts
	rm -rf ${NAME}*.tgz
	rm -rf requirements.lock

release: build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" Chart.yaml
	sed -i "" -e "s/tag:.*/tag: $(VERSION)/" values.yaml

else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" Chart.yaml
	sed -i -e "s/tag:.*/tag: $(VERSION)/" values.yaml
else
	exit -1
endif
	helm package .
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(VERSION).tgz" $(CHART_REPO)/api/charts
	helm repo update
	rm -rf ${NAME}*.tgz
