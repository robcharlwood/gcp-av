VENV ?= ./.venv-gcp-av
DOCKER_OK := $(shell type -P docker)
PYTHON_EXE ?= python
PYTHON_OK := $(shell type -P ${PYTHON_EXE})
PYTHON_VERSION := $(shell python -V | cut -d' ' -f2)
PYTHON_REQUIRED := $(shell cat .python-version)
TERRAFORM_OK := $(shell type -P terraform)
TERRAFORM_REQUIRED := $(shell cat .terraform-version)
CORRECT_TERRAFORM_INSTALLED := $(shell terraform -v | grep ${TERRAFORM_REQUIRED})
AMZ_LINUX_VERSION := 2
CWD := $(shell pwd)

check_docker:
	@echo '********** Checking for docker installation *********'
    ifeq ('$(DOCKER_OK)','')
	    $(error package 'docker' not found!)
    else
	    @echo Found docker!
    endif

check_terraform:
	@echo '********** Checking for terraform installation *********'
    ifeq ('$(TERRAFORM_OK)','')
	    $(error package 'terraform' not found!)
    else
	    @echo Found terraform!
    endif
	@echo '*********** Checking for terraform version ***********'
    ifeq ('', '$(CORRECT_TERRAFORM_INSTALLED)')
	    $(error incorrect version of terraform found. Expected '${TERRAFORM_REQUIRED}'!)
    else
	    @echo Found terraform ${TERRAFORM_REQUIRED}
    endif

check_python:
	@echo '*********** Checking for Python installation ***********'
    ifeq ('$(PYTHON_OK)','')
	    $(error python interpreter: '${PYTHON_EXE}' not found!)
    else
	    @echo Found Python
    endif
	@echo '*********** Checking for Python version ***********'
    ifneq ('$(PYTHON_REQUIRED)','$(PYTHON_VERSION)')
	    $(error incorrect version of python found: '${PYTHON_VERSION}'. Expected '${PYTHON_REQUIRED}'!)
    else
	    @echo Found Python ${PYTHON_REQUIRED}
    endif

setup_venv: check_python
	@echo '**************** Creating virtualenv *******************'
	${PYTHON_EXE} -m venv $(VENV)
	${VENV}/bin/pip install --upgrade pip
	${VENV}/bin/pip install -r requirements/requirements-local.txt
	@echo '*************** Installation Complete ******************'

setup_terraform: check_terraform
	@echo '****** Setting up terraform ******'
	terraform init ./terraform

setup_git_hooks:
	@echo '****** Setting up git hooks ******'
	pre-commit install

install: check_docker setup_venv setup_terraform setup_git_hooks

test: check_python
	find . -type f -name '*.pyc' -delete
	${VENV}/bin/pytest ./functions

build_clamscan: check_docker
	rm -rf ./build/clamscan_function.zip
	docker run --rm -ti \
		-v ${CWD}:/opt/app \
		amazonlinux:$(AMZ_LINUX_VERSION) \
		/bin/bash -c "cd /opt/app && ./scripts/build_clamscan_function.sh"

build_freshclam: check_docker
	rm -rf ./build/freshclam_function.zip
	docker run --rm -ti \
		-v ${CWD}:/opt/app \
		amazonlinux:$(AMZ_LINUX_VERSION) \
		/bin/bash -c "cd /opt/app && ./scripts/build_freshclam_function.sh"

clean:
	rm -rf ./build
	rm -rf ./.terraform
	rm -rf ${VENV}

terraform_init: check_terraform
	terraform init ./terraform

terraform_fmt: check_terraform
	terraform fmt -recursive ./terraform

terraform_validate: check_terraform
	terraform validate -var-file ./terraform/terraform.tfvars ./terraform

terraform_plan: check_terraform
	terraform plan -var-file ./terraform/terraform.tfvars ./terraform

terraform_apply: check_terraform
	terraform apply -var-file ./terraform/terraform.tfvars ./terraform

terraform_destroy: check_terraform
	terraform destroy -var-file ./terraform/terraform.tfvars ./terraform
