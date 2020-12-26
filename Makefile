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

.SHELLFLAGS := -NoProfile -Command

REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
TAG := :latest

all: build_fc_pwsh_build build_fc_pwsh_test

build_fc_pwsh_build:
	$(Q)docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build$(TAG) -f Dockerfile.build .

build_fc_pwsh_test:
	$(Q)docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test$(TAG) -f Dockerfile.test .

package: package_fc_pwsh_build package_fc_pwsh_test

package_fc_pwsh_build: build_fc_pwsh_build
	$(Q)$$PackageFileName = "$$("fc_pwsh_build" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build$(TAG) -o $$PackageFileName

package_fc_pwsh_test: build_fc_pwsh_test
	$(Q)$$PackageFileName = "$$("fc_pwsh_test" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test$(TAG) -o $$PackageFileName

publish: publish_fc_pwsh_test publish_fc_pwsh_build

publish_fc_pwsh_test: build_fc_pwsh_test
	$(Q)docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_test$(TAG);

publish_fc_pwsh_build: build_fc_pwsh_build
	$(Q)docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)fc_pwsh_build$(TAG); 