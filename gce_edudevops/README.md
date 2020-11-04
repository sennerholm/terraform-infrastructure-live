# DevOps labs

## Introduction to Google Cloud

During the laboration we need somewhere to store our artifacts and run our payload (and tests). This example is using Google Cloud infrastructure for it. 

### TODO: Add reference to how to get a "demo" account.


## Let's get started with Google Cloud

To have the possiblity to access Google cloud I need to setup an environment. To help me I have a sample shell script that I need to run. 

Try running a command now:
```bash
  cd bootstrap/gce_edudevops
  ./bootstrap.sh prefix suffix
```

**Tip**: Click the copy button on the side of the code box and paste the command in the Cloud Shell terminal to run it.

**Replace prefix and digit with to make the project unique.**

When the script runs it will bootstrap the project on google cloud we are going to use during the education. 
It has enabled some functionality on the project and will output some variables that we will use in the next step.


## Let's use a Container registry to store our artefacts

In the pipeline we want to have somewhere to store the container images we have built so we need a container registry. The bootstrap script in the previous step  enabled a container registry. If you want to do it manually in the future you can follow the instruction on https://cloud.google.com/container-registry/docs/pushing-and-pulling?_ga=2.224367576.-2118620794.1590522151.

We now need to improve the CircleCI pipeline so it can push the images to Google Cloud. To be able to do that we first need to add the credentials to a google cloud in CircleCI. 


### Add environment in CircleCI

We need to add 3 environment variables to CircleCI, in the last line from the bootstrap script you should have got something like this:

```
Environment variables that need to be added to CircleCI
Organization Settings->Context->Create Context->devopsedu-global
GOOGLE_PROJECT_ID = prefix-username-suffix
GOOGLE_COMPUTE_ZONE = europe-west1-b
GOOGLE_AUTH =  ewogICJ0eXBl...0LmNvbSIKfQo=
```

Add the variables in Organization Settings->Context->Create Context->devopsedu-global. 

The reason to create a context is to make the variables reusable ower multiple pipelines in CircleCI. In a an organisation it's often the "Ops" that is responsible for creating this "context".


### How to use the Context in CircleCI

In Circle we need to change the workflow to have the possibility to use the "Context".

```
version: 2.1
workflows:
  build-and-push:
    jobs:
      - build:
          context: devopsedu-global
jobs:
  build:
    machine: true
    steps:
      - checkout
      - run: 
          name: Checking environment
          command: env
      - run: docker build -t company/app:$CIRCLE_BRANCH .
```

Run the pipeline and verify that you can see that the environment variables have been set.


### Authorize to gCloud and push the image

We now need to update the build configurations so we have the possiblity to push the image.

Change the pipeline to:
```
version: 2.1
workflows:
  build-and-push:
    jobs:
      - build:
          context: devopsedu-global

jobs:
  build:
    machine: true
    steps:
      - checkout
      - run: 
          name: Checking environment
          command: env
      - run: echo ${GOOGLE_AUTH} | base64 -i --decode > ${HOME}/gcp-key.json
      - run: gcloud auth activate-service-account --key-file ${HOME}/gcp-key.json
      - run: gcloud --quiet config set project ${GOOGLE_PROJECT_ID}
      - run: gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}
      - run: docker build --rm=false -t eu.gcr.io/${GOOGLE_PROJECT_ID}/${CIRCLE_PROJECT_REPONAME}:$CIRCLE_SHA1 .
      - run: gcloud docker -- push eu.gcr.io/${GOOGLE_PROJECT_ID}/${CIRCLE_PROJECT_REPONAME}:$CIRCLE_SHA1 
```
build-docker-image-with-circle-ci-2-push-to-google-container-registry/