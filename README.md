# Related Article from Kirsten 
https://www.s-cubed-global.com/news/covidgraph-nerds-response-to-the-pandemic

# Related Issue Tracker
https://github.com/covidgraph/documentation/issues/8

# ClinicalTrials.gov Data loader

This python script loads data from [ClinicalTrials.gov API](https://clinicaltrials.gov/api/gui/home) into the neo4j based covidgraph. The script gets data from the StudyFields, which are described on this API homepage.

Maintainer: [Kirsten](https://github.com/KWLangendorf)

Version: 0.2.1

Neo4j version: < 3.5.17

APOC version: < 3.5.0.11

Docker image location: [covidgraph/data-clinical_trials_gov](https://hub.docker.com/r/covidgraph/data-clinical_trials_gov)

# Usage

## Docker

### Run prebuild  image

`docker run -it --rm --name data-cord19 --network host -e NEO4J='{"host":"localhost"}' covidgraph/data-clinical_trials_gov`
### Build and run local image

`docker build -t data-clinical_trials_gov .`

`docker run -it --rm --name data-cord19 --network host -e NEO4J='{"host":"localhost"}' data-clinical_trials_gov`

### Envs

The most important Env variables are:

`NEO4J`: defaults to `{"host":"localhost"}`. The connections details for the database. For details see https://github.com/covidgraph/motherlode/blob/master/README.md#the-neo4j-connection-string

## Python (without Docker)

To run the code without docker you need to have python installed.

**Setup**

Install the python requirments with

`pip install --no-cache-dir -r requirement.txt`

Run the script with

`python3 ./dataloader/main.py`

# Data

## Queries to ClinicalTrials.gov

Due to a limit of 1000 studies to be returned from a query[https://clinicaltrials.gov/api/gui/demo/simple_study_fields], the queries has been split into 3 parts (syntax for the query):
Studies contatining the word COVID for

1. Obervational studies (COVID AND AREA[StudyType]Observational)
2. Interventional studies (COVID AND AREA[StudyType]Interventional)
3. NOT (Observations AND Interventional) studies - e..g expanded access(COVID AND NOT AREA[StudyType]Interventional AND NOT AREA[StudyType]Observational)

Decription of the fields can be found here: https://clinicaltrials.gov/api/gui/ref/crosswalks.

At this point no results information can be found for COVID studies. This will be added once results are avilable.

## Scheme

<a target="_blank" rel="noopener noreferrer" href="https://github.com/covidgraph/data_clinical-trials-gov/blob/master/docs/ClinicalTrialsSchema.png"><img src="https://github.com/covidgraph/data_clinical-trials-gov/blob/master/docs/ClinicalTrialsSchema.png" alt="Datascheme" style="max-width:100%;"></a>
