# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

Types of changes are:

* **Added** for new features.
* **Changed** for changes in existing functionality.
* **Deprecated** for soon-to-be removed features.
* **Removed** for now removed features.
* **Fixed** for any bug fixes.
* **Security** in case of vulnerabilities.

## Unreleased

## [v1.0.0](https://github.com/robcharlwood/gcp-av/releases/tag/v1.0.0) - 2019-06-30

### Added

* Basic cloud functions to scan files uploaded to GCS and keep virus DB up to date.
* README and documentation on working with the codebase.
* Terraform to provision the project.
* Basic test framework in place.
* Integration with Travis CI and coveralls.
* Basic python code validation and formatting with black, flake8 and isort.
* Makefile with basic commands to carry out all the various stages of a build.
