# kernel-style V=1 build verbosity
ifeq ('$(origin V)', 'command line')
	BUILD_VERBOSE = $(V)
endif
ifeq ($(BUILD_VERBOSE),1)
	Q =
else
	Q = @
endif

ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.PHONY: all clean test lint package publish
.SHELLFLAGS := -NoProfile -Command

REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
TAG := :latest

all: build_fc_pwsh_build build_fc_pwsh_test

getcommitid: 
	$(eval COMMITID = $(shell git log -1 --pretty=format:"%H"))

getbranchname:
	$(eval BRANCH_NAME = $(shell (git branch --show-current ) -replace '/','.'))

build_fc_pwsh_build: getcommitid getbranchname
	$(Q)docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build:$(BRANCH_NAME).$(COMMITID) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build:$(BRANCH_NAME) -f Dockerfile.build .

build_fc_pwsh_test: getcommitid getbranchname
	$(Q)docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test:$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test:$(BRANCH_NAME).$(COMMITID) -f Dockerfile.test .

package: package_fc_pwsh_build package_fc_pwsh_test

package_fc_pwsh_build: build_fc_pwsh_build
	$(Q)$$PackageFileName = "$$("fc_pwsh_build" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build$(TAG) -o $$PackageFileName

package_fc_pwsh_test: build_fc_pwsh_test
	$(Q)$$PackageFileName = "$$("fc_pwsh_test" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test$(TAG) -o $$PackageFileName

publish: publish_fc_pwsh_test publish_fc_pwsh_build

publish_fc_pwsh_test: build_fc_pwsh_test
	$(Q)docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test$(TAG); docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test:$(BRANCH_NAME); docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test:$(BRANCH_NAME).$(COMMITID);

publish_fc_pwsh_build: build_fc_pwsh_build
	$(Q)docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build$(TAG); docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build:$(BRANCH_NAME); docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build:$(BRANCH_NAME).$(COMMITID); 

lint: lint_mega lint_credo

lint_mega:
	docker run -v $${PWD}:/tmp/lint oxsecurity/megalinter:v6
lint_goodcheck:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck check
lint_goodcheck_test:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck test