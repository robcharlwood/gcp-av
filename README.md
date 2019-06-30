# Google Cloud Storage Anti Virus

[![Build Status](https://travis-ci.org/robcharlwood/gcp-av.svg?branch=master)](https://travis-ci.org/robcharlwood/gcp-av/) [![Coverage Status](https://coveralls.io/repos/github/robcharlwood/gcp-av/badge.svg?branch=master)](https://coveralls.io/github/robcharlwood/gcp-av?branch=master)

Anti Virus scanning for CloudStorage buckets using cloud functions and [ClamAV](https://www.clamav.net/)

## Initial checkout and setup of codebase

* Open terminal and move to a suitable directory on your machine
* Run ``git clone git@github.com:robcharlwood/gcp-av.git``
* Run ``cd gcp-av``

### Requirements

This project requires certain software and libraries to be available on your machine. These are listed below.
However, the ``make install`` command will check that your environment contains all the tools needed before install.
The ``.python-version`` and ``.terraform-version`` files will ensure these versions are enabled if you are using the suggested tools.

* [Docker](https://www.docker.com/)
* [Terraform](https://www.terraform.io/) (ideally installed using [``tfenv``](https://github.com/tfutils/tfenv))
* [Python 3](https://www.python.org/) (ideally installed using [``pyenv``](https://github.com/pyenv/pyenv))

### Prerequisites

* Create a project on Google Cloud Platform - they offer $300 free credit for the first year!
* Create a service account for Terraform inside your new project - this will allow your terraform access to the project remotely.
* Download the service account JSON security key and place it in a ``.keys`` folder in the root of the project. Terraform will use this file to authenticate itself with Google in order to provision the relevant infrastructure.

We then need to give the terraform account the relevant priviledges for your project. So add the following roles to the service account
you just created:

* Cloud Functions Admin
* Cloud Scheduler Admin
* Service Account User
* Pub/Sub Admin
* Storage Admin

Please note, that these roles could probably be tightended up from a security perspective. However, since this is not production ready
and this is a hack weekend, I'm going to leave them as this.

* Create a webhook in your Slack account and make a note of the webhook URL.
* Update the ``terraform/terraform.tfvars`` file with your own details for your google project and slack webhook url.
* Create a new private Google Cloud Storage bucket called ``gcp-av-terraform``. This allows you to store terraform state remotely if working in a team.

### Installation locally

To install the project locally you need to run ``make install``. You can also pass ``VENV`` and ``PYTHON_EXE`` keyword arguments
to the make file to configure the installation e.g

* ``make install`` - Installs dependencies with defaults
* ``make install VENV=foo`` - Installs into a local virtualenv named ``foo``
* ``make install PYTHON_EXE=python3.7`` - Installs with a specific python interpreter, example values might be ``python`` or ``python3.6``. This defaults to ``python``.

Once all the code dependencies have been installed, then you need to follow the below steps.

### Running everything.

To See this working from end to end, follow the instructions below:

* Run ``make build_clamscan`` - this will bundle up the cloud function that runs virus scans on files uploaded to our bucket.
* Run ``make build_freshclam`` - this will bundle up the cloud function that keeps the virus database up to date.
* Run ``make terraform_validate`` - validates my nonsense code.
* Run ``make terraform_plan`` - this effectively dry runs your terraform and outputs details on what will change.
* Run ``make terraform_apply`` - this will actually apply your infrastructure to your new project

This can take up to 10 minutes to complete depending on how Google is feeling that day.
Once this is complete, you are ready to run some tests through!

* Go to your ``freshclam`` cloud function and trigger it. You don't normally need to do this as it will run automatically once every 24 hours, but I am assuming you don't want to wait that long. :-) This will pull down the virus definitions database and store it to the relevant private bucket.
* Once this has completed successfully, open your Slack and head to the room you configured for your web hook.
* Open the Cloud storage browser in the Google Cloud Console and make sure you are in the ``gcp-av-watch-bucket`` bucket.
* Upload a ``clean.txt`` text file with "hello world" on something in it and wait for Slack to pop out a notification that it has found and scanned a clean file.
* Upload a second text file called ``infected.txt`` with the following content ``X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*
``.
* Wait for a slack notification saying that an infected file has been uploaded to the bucket.
* Check the bucket and ensure that the infected file was deleted!
* Profit! :)

### Cleaning up

To ensure that you don't incur any costs on the project once you are done, delete the whole project from your Google Cloud Console.
To clean up locally, simply run the ``make clean`` command.

### Running tests

To run the tests for the project locally you need to run ``make test``. This will run pytest with coverage.
Please note that if you have not followed the previous Installation steps above and run ``make install``, this will not work.

### Pre-commit hooks

This project uses the pre-commit library to ensure that certain conditions are met before allowing code to be committed. This project
makes use of the below hooks

* [``black``](https://github.com/python/black) - For code formatting consistency.
* [``isort``](https://github.com/timothycrosley/isort) - For import sorting.

### Continuous Integration

This project uses [Travis CI](http://travis-ci.org/) for continuous integration. This platform runs the project tests and test coverage.
Coverage is handled with Python's coverage library, but also uses the SaaS service [coveralls.io](https://coveralls.io) for visibility on coverage.

## Versioning

This project uses [git](https://git-scm.com/) for versioning. For the available versions,
see the [tags on this repository](https://github.com/robcharlwood/gcp-av/tags).

## Authors

* Rob Charlwood - Bitniftee Limited

## Changes

Please see the [CHANGELOG.md](https://github.com/robcharlwood/gcp-av/blob/master/CHANGELOG.md) file additions, changes, deletions and fixes between each version

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/robcharlwood/gcp-av/blob/master/LICENSE) file for details


curl -X PATCH --data '{"versioning": {"enabled": true}}' \
    -H "Authorization: Bearer ya29.Gls2B4eWhfvIo951g7EDW0oxXUQRF17n8ynGsjOdlbRCpU2mxrwI0iElVYveZIVQsS74Bn445X8GqsLq4XYJ45xJ8tkLdgLsiAUduaHVIjZfbwCsmM9S9xev0nVT" \
    -H "Content-Type: application/json" \
    "https://www.googleapis.com/storage/v1/b/gcp-av-terraform?fields=versioning"


curl -X GET -H "Authorization: Bearer ya29.Gls2B4eWhfvIo951g7EDW0oxXUQRF17n8ynGsjOdlbRCpU2mxrwI0iElVYveZIVQsS74Bn445X8GqsLq4XYJ45xJ8tkLdgLsiAUduaHVIjZfbwCsmM9S9xev0nVT" \
    "https://www.googleapis.com/storage/v1/b/gcp-av-terraform?fields=versioning"
