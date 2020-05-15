# Data loader template

Template Maintainer: [Tim](https://github.com/motey)

This repository serves as a template for developers writing scripts to load data into covidgraph.

# Why we have a template

We try to have data loading scripts in a certain format to build a automated data loading pipeline.

When a developer created a script, it can be registered at https://github.com/covidgraph/motherlode

Motherlode will run the script to load the data into the DEV instance of covidgraph.
When the function and content of the data is verified, it can be run by motherlode against the PROD instance.

If you write your script in python, you can take this repo as template. When you write in another laguage, take it as inspiration and just follow the "Connect to the correct neo4j instance" part

# How it works

All data source scripts will be wrapped in a docker container. Motherlode is just a python script that pulls the data source docker images from docker hub and runs them.

## Your tasks overview

The datasource script is responsible for the following tasks:

- Download the source data
- Transform the source data
- Connect to the correct neo4j instance
- Load the data in an idempotent\* way into the database

\* "idempotent" means basically, merge your nodes. If your script fails on half the way the first time, we want to be able to just re-run. Without duplicating all nodes that are already loaded in the DB.

After that you need to do the following things to let your script work at the covid graph

- Publish your script as a docker image
- Register the script at https://github.com/covidgraph/motherlode

## Your tasks in detail

### Connect to the correct neo4j instance

Motherlode will hand over the following environment variables when your data source script is called:

`ENV`: will be `PROD` or `DEV`

`GC_NEO4J_URL`: The full bolt url. example 'bolt://myneo4jhostname:7687'

`GC_NEO4J_USER`: The neo4j user

`GC_NEO4J_PASSWORD`: The neo4j password

**You have to take care that your script uses these variables to connect to the database**

## Make your image availabe

We share the scripts via docker images at https://hub.docker.com/

### Wrap your script

When you finished developeing your script, you have to "dockerize"/"container" it.

### Build your script and publish it

There are multiple ways, to build and publish your script.
The easiest is to just run:

```bash
docker build -t data-my-datasource-script .
docker login --username my-docker-hub-username
docker tag data-my-datasource-script:$tag covidgraph/data-my-datasource-script:version
docker push covidgraph/data-my-datasource-script:$tag
```

To be able to publish your script to the docker hub organization `covidgraph` you need to be a member. ping [Martin](https://github.com/mpreusse) or [Tim](https://github.com/motey) for that)

#### Publish via github actions

A more convenient way of publishing your image is, to let github take care of that. You can use github `Actions` for that.
As an example have a look at https://github.com/covidgraph/data_cord19 or ping [Tim](https://github.com/motey)

### Register your script at Motherlode

just ping [Tim](https://github.com/motey) for that and tell him the location of your docker image

Thats it! :)

All following text belongs to the template README.md. Cut here when you create a new template
✂---------------------------------

# Template Data loader

This script loads data X and Y from source Z into the neo4j based covidgraph

Maintainer: {You}[https://github.com/{YourGitHub.Com-id}]

Version: 0.0.1

Docker image location: https://hub.docker.com/repository/docker/covidgraph/data-template
