# Makefile for the temple-python-public template
#
# This Makefile has the following targets:
#
# pyenv - Sets up pyenv and a virtualenv that is automatically used
# deactivate_pyenv - Deactivates the pyenv setup
# pre_commit - Installs git pre-commit hooks
# mac_dependencies - Installs Mac dependencies. Put any homebrew installs here or things that cannot be installed on Linux
# dependencies - Installs all dependencies for a project (including mac dependencies)
# setup - Sets up the entire development environment (pyenv and dependencies)
# test - Run tests

OS = $(shell uname -s)

REPO_NAME=temple-python-public

ifdef CIRCLECI
TEST_COMMAND=pytest --junitxml=$(CIRCLE_TEST_REPORTS)/$(REPO_NAME)/junit.xml
# Use CircleCIs version
PYTHON_VERSION=
PIP_INSTALL_CMD=pip install -q
else
TEST_COMMAND=pytest
PYTHON_VERSION=3.6.4
PIP_INSTALL_CMD=pip install
endif


# Print usage of main targets when user types "make" or "make help"
help:
	@echo "Please choose one of the following targets: \n"\
	      "    setup: Setup your development environment and install dependencies\n"\
	      "    test: Run tests\n"\
	      "\n"\
	      "View the Makefile for more documentation about all of the available commands"
	@exit 2


# Sets up pyenv and the virtualenv that is managed by pyenv
.PHONY: pyenv
pyenv:
ifeq (${OS}, Darwin)
	brew install pyenv pyenv-virtualenv 2> /dev/null || true
# Ensure we remain up to date with pyenv so that new python versions are available for installation
	brew upgrade pyenv pyenv-virtualenv 2> /dev/null || true
endif
ifdef PYTHON_VERSION
	pyenv install -s ${PYTHON_VERSION}
endif
# Only make the virtualenv if it doesnt exist
	@[ ! -e ~/.pyenv/versions/${REPO_NAME} ] && pyenv virtualenv ${PYTHON_VERSION} ${REPO_NAME} || :
	pyenv local ${REPO_NAME}
ifdef PYTHON_VERSION
# If Python has been upgraded, remove the virtualenv and recreate it
	@[ `python --version | cut -f2 -d' '` != ${PYTHON_VERSION} ] && echo "Python has been upgraded since last setup. Recreating virtualenv" && pyenv uninstall -f ${REPO_NAME} && pyenv virtualenv ${PYTHON_VERSION} ${REPO_NAME} || :
endif


# Deactivates pyenv and removes it from auto-using the virtualenv
.PHONY: deactivate_pyenv
deactivate_pyenv:
	pyenv uninstall ${REPO_NAME}
	rm .python-version


# Builds all dependencies for a project
.PHONY: dependencies
dependencies:
	${PIP_INSTALL_CMD} -U pip
	${PIP_INSTALL_CMD} -r test_requirements.txt
	pip check


# Performs the full development environment setup
.PHONY: setup
setup: pyenv dependencies


.PHONY: test
test:
	coverage run -m ${TEST_COMMAND}
	coverage report
