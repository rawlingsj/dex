CHART_REPO := http://jenkins-x-chartmuseum:8080
CURRENT=$(pwd)
NAME := dex
OS := $(shell uname)
VERSION := $(shell cat ../../VERSION)

setup:
	helm repo add jenkinsxio https://chartmuseum.jx.cd.jenkins-x.io 

build: setup clean
	helm dependency build
	helm lint

install: clean setup build
	helm install . --name ${NAME}

upgrade: clean setup  build
	helm upgrade ${NAME} .

delete:
	helm delete --purge ${NAME}

clean:
	rm -rf charts
	rm -rf ${NAME}*.tgz
	rm -rf requirements.lock

init:
	helm init --client-only

release: init setup clean build tag
	helm package .
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(shell sed -n 's/^version: //p' Chart.yaml).tgz" $(CHART_REPO)/api/charts
	helm repo update
	rm -rf ${NAME}*.tgz%

tag:
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" Chart.yaml
	sed -i "" -e "s/tag: .*/tag: $(VERSION)/" values.yaml
else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" Chart.yaml
	sed -i -e "s|repository: .*|repository: $(DOCKER_REGISTRY)\/jenkins-x\/$(NAME)|" values.yaml
	sed -i -e "s/tag: .*/tag: $(VERSION)/" values.yaml
else
	echo "platfrom $(OS) not supported to tag with"
	exit -1
endif
	git add --all
	git commit -m "release $(VERSION)" --allow-empty # if first release then no verion update is performed
	git tag -fa v$(VERSION) -m "Release version $(VERSION)"
	git push origin v$(VERSION)
