# ClinicalTrials.gov Data loader

This Neo4j script loads data from [ClinicalTrials.gov API](https://clinicaltrials.gov/api/gui/home) into the neo4j based covidgraph. The script gets data from the StudyFields, which are described on this API homepage.

Maintainer: [Kirsten](https://github.com/KirstenLangendorf)

Version: 0.1.0

Neo4j version: 3.5.17

APOC  version: 3.5.0.11

Developed using Neo4j Desktop version: 1.2.7

Docker image location: https://hub.docker.com/repository/docker/covidgraph/data-template

# Usage
## Docker
### Run
### Build local image
### Run local image
### Envs




# Data
## Queries to ClinicalTrials.gov
Due to a limit of 1000 studies to be returned from a query[https://clinicaltrials.gov/api/gui/demo/simple_study_fields], the queries has been split into 3 parts (syntax for the query):
Studies contatining the word COVID for 
1. Obervational studies (COVID AND AREA[StudyType]Observational)
2. Interventional studies (COVID AND AREA[StudyType]Interventional)
3. NOT (Observations AND Interventional) studies - e..g expanded access(COVID AND NOT AREA[StudyType]Interventional AND NOT AREA[StudyType]Observational)

The following study fields are seleted:

NCTId,

StudyType,

Phase,

Condition,

BriefTitle,

LeadSponsorName,

LocationFacility,

LocationCity,

LocationState,

LocationCountry,

InterventionName,

CollaboratorName,

OverallStatus,

PrimaryOutcomeMeasure,

EligibilityCriteria,

StartDate,

StudyFirstSubmitDate,

PrimaryCompletionDate.

Decription of the fields can be found here: https://clinicaltrials.gov/api/gui/ref/crosswalks.

At this point no results information can be found for COVID studies. This will be added once results are avilable.

## Scheme
<a target="_blank" rel="noopener noreferrer" href="https://github.com/KirstenLangendorf/load_clinical_trials_gov/blob/master/docs/ClinicalTrialsSchema.png"><img src="https://github.com/KirstenLangendorf/load_clinical_trials_gov/blob/master/docs/ClinicalTrialsSchema.png" alt="Datascheme" style="max-width:100%;"></a>

## Example

<a target="_blank" rel="noopener noreferrer" href="https://github.com/KirstenLangendorf/load_clinical_trials_gov/blob/master/docs/ClinicalTrialsExample.png"><img src="https://github.com/KirstenLangendorf/load_clinical_trials_gov/blob/master/docs/ClinicalTrialsExample.png" alt="Datascheme" style="max-width:100%;"></a>
