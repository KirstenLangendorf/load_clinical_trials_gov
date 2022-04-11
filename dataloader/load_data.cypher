// Create Create ClinicalTrial node, StudyType nodes and connects them
// Create the Location (Facility -> City -> Country) and link Facility to ClinicalTrial
// Create Primary Outcome Measure (Outcome) and link to ClinicalTrial
// Set lots of properties on ClinicalTrial
// Observational studies - QUERY at https://clinicaltrials.gov/api/gui/demo/simple_study_fields:
// COVID AND AREA[StudyType]Observational
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,Phase,Condition,LeadSponsorName,LocationFacility,BriefTitle,InterventionName,CollaboratorName,LocationCity,OverallStatus,PrimaryOutcomeMeasure,EligibilityCriteria,StartDate,LocationState,StudyType,StudyFirstSubmitDate,PrimaryCompletionDate,LocationCountry&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.StudyType as StudyType
merge (ct:ClinicalTrial{NCTId:Id,data_source:'clinicaltrials.gov',url:'https://clinicaltrials.gov/ct2/show/' + Id})
MERGE(st:StudyType{type:StudyType}) MERGE(ct)-[:IS_TYPE]->(st)
WITH Id, ct, study_metadata, RANGE(0,size(study_metadata.LocationFacility)-1) as nfacil
FOREACH(i in nfacil | 
        MERGE(fa:Facility{name:study_metadata.LocationFacility[i]})
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(ct)-[:CONDUCTED_AT]->(fa)
        MERGE(fa)-[:LOCATED_IN]->(ci)
       )
WITH Id, study_metadata, RANGE(0,size(study_metadata.LocationCity)-1) as ncity
FOREACH(i in ncity | 
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(c:Country{name:study_metadata.LocationCountry[i]})
        MERGE(ci)-[:LOCATED_IN]->(c) 
               )
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.Condition as Condition
SET ct.condition= CASE WHEN size(study_metadata.Condition)>1 THEN study_metadata.Condition ELSE Condition END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.PrimaryOutcomeMeasure as PrimaryOutcomeMeasure 
MERGE(ot:PrimaryOutcomeMeasure{outcome:PrimaryOutcomeMeasure}) MERGE(ct)-[:INVESTIGATES_OUTCOME]->(ot)
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.EligibilityCriteria as EligibilityCriteria
with Id, study_metadata, ct, split(replace(replace(trim(substring(EligibilityCriteria,length(split(EligibilityCriteria,"Exclusion")[0])+19,size(EligibilityCriteria))),'\n','//'),'////','//'),'//') as Exclusion, 
split(replace(replace(trim(substring(EligibilityCriteria,19,length(split(EligibilityCriteria,"Exclusion")[0])-19)),'\n','//'),'////','//'),'//') as Inclusion
with Id, study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Inclusion)-1) as nincl
FOREACH(i in nincl |  
MERGE(incl:InclusionCriteria{criteria:Inclusion[i]}) MERGE(ct)-[:HAS_INCLUSION_CRITERIA]->(incl)) 
with Id, study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Exclusion)-1) as nexcl
FOREACH(i in nexcl | 
MERGE(excl:ExclusionCriteria{criteria:Exclusion[i]}) MERGE(ct)-[:HAS_EXCLUSION_CRITERIA]->(excl))
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.LeadSponsorName as LeadSponsorName 
SET ct.leadSponsorName=CASE WHEN size(study_metadata.LeadSponsorName)=1 THEN LeadSponsorName ELSE study_metadata.LeadSponsorName END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.BriefTitle as BriefTitle
SET ct.briefTitle=CASE WHEN size(study_metadata.BriefTitle)=1 THEN BriefTitle ELSE study_metadata.BriefTitle END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.CollaboratorName as CollaboratorName
SET ct.collaboratorName=CASE WHEN size(study_metadata.CollaboratorName)=1 THEN CollaboratorName ELSE study_metadata.CollaboratorName END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.OverallStatus as OverallStatus
SET ct.overallStatus=CASE WHEN size(study_metadata.OverallStatus)=1 THEN OverallStatus ELSE study_metadata.OverallStatus END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.StartDate as StartDate
SET ct.startDate=CASE WHEN size(study_metadata.StartDate)=1 THEN StartDate ELSE study_metadata.StartDate END     
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.StudyFirstSubmitDate as StudyFirstSubmitDate
SET ct.studyFirstSubmitDate=CASE WHEN size(study_metadata.StudyFirstSubmitDate)=1 THEN StudyFirstSubmitDate ELSE study_metadata.StudyFirstSubmitDate END           
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.PrimaryCompletionDate as PrimaryCompletionDate
SET ct.primaryCompletionDate=CASE WHEN size(study_metadata.PrimaryCompletionDate)=1 THEN PrimaryCompletionDate ELSE study_metadata.PrimaryCompletionDate END;
// Create Create ClinicalTrial node, StudyType nodes and connects them
// Create the Location (Facility -> City -> Country) and link Facility to ClinicalTrial
// Create Primary Outcome Measure (Outcome) and link to ClinicalTrial
// Set lots of properties on ClinicalTrial
// Interventional - QUERY at https://clinicaltrials.gov/api/gui/demo/simple_study_fields:
// COVID AND AREA[StudyType]Interventional
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DInterventional&fields=NCTId,Phase,Condition,LeadSponsorName,LocationFacility,BriefTitle,InterventionName,CollaboratorName,LocationCity,OverallStatus,PrimaryOutcomeMeasure,EligibilityCriteria,StartDate,LocationState,StudyType,StudyFirstSubmitDate,PrimaryCompletionDate,LocationCountry&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.StudyType as StudyType
UNWIND study_metadata.Phase as Phase
merge (ct:ClinicalTrial{NCTId:Id,data_source:'clinicaltrials.gov',url:'https://clinicaltrials.gov/ct2/show/' + Id})
MERGE(st:StudyType{type:StudyType}) MERGE(ct)-[:IS_TYPE]->(st)
MERGE(ph:Phase{phase:Phase}) MERGE(ct)-[:IS_PHASE]->(ph)
WITH Id, ct, study_metadata, RANGE(0,size(study_metadata.LocationFacility)-1) as nfacil
FOREACH(i in nfacil | 
        MERGE(fa:Facility{name:study_metadata.LocationFacility[i]})
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(ct)-[:CONDUCTED_AT]->(fa)
        MERGE(fa)-[:LOCATED_IN]->(ci)
       )
WITH Id, study_metadata, RANGE(0,size(study_metadata.LocationCity)-1) as ncity
FOREACH(i in ncity | 
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(c:Country{name:study_metadata.LocationCountry[i]})
        MERGE(ci)-[:LOCATED_IN]->(c) 
               )
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.Condition as Condition
SET ct.condition= CASE WHEN size(study_metadata.Condition)>1 THEN study_metadata.Condition ELSE Condition END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.PrimaryOutcomeMeasure as PrimaryOutcomeMeasure 
MERGE(ot:PrimaryOutcomeMeasure{outcome:PrimaryOutcomeMeasure}) MERGE(ct)-[:INVESTIGATES_OUTCOME]->(ot)
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.EligibilityCriteria as EligibilityCriteria
with Id, study_metadata, ct, split(replace(replace(trim(substring(EligibilityCriteria,length(split(EligibilityCriteria,"Exclusion")[0])+19,size(EligibilityCriteria))),'\n','//'),'////','//'),'//') as Exclusion, 
split(replace(replace(trim(substring(EligibilityCriteria,19,length(split(EligibilityCriteria,"Exclusion")[0])-19)),'\n','//'),'////','//'),'//') as Inclusion
with Id, study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Inclusion)-1) as nincl
FOREACH(i in nincl | 
MERGE(incl:InclusionCriteria{criteria:Inclusion[i]}) MERGE(ct)-[:HAS_INCLUSION_CRITERIA]->(incl))
with Id, study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Exclusion)-1) as nexcl
FOREACH(i in nexcl | 
MERGE(excl:ExclusionCriteria{criteria:Exclusion[i]}) MERGE(ct)-[:HAS_EXCLUSION_CRITERIA]->(excl))
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.LeadSponsorName as LeadSponsorName 
SET ct.leadSponsorName=CASE WHEN size(study_metadata.LeadSponsorName)=1 THEN LeadSponsorName ELSE study_metadata.LeadSponsorName END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.BriefTitle as BriefTitle
SET ct.briefTitle=CASE WHEN size(study_metadata.BriefTitle)=1 THEN BriefTitle ELSE study_metadata.BriefTitle END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.CollaboratorName as CollaboratorName
SET ct.collaboratorName=CASE WHEN size(study_metadata.CollaboratorName)=1 THEN CollaboratorName ELSE study_metadata.CollaboratorName END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.OverallStatus as OverallStatus
SET ct.overallStatus=CASE WHEN size(study_metadata.OverallStatus)=1 THEN OverallStatus ELSE study_metadata.OverallStatus END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.StartDate as StartDate
SET ct.startDate=CASE WHEN size(study_metadata.StartDate)=1 THEN StartDate ELSE study_metadata.StartDate END     
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.StudyFirstSubmitDate as StudyFirstSubmitDate
SET ct.studyFirstSubmitDate=CASE WHEN size(study_metadata.StudyFirstSubmitDate)=1 THEN StudyFirstSubmitDate ELSE study_metadata.StudyFirstSubmitDate END           
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.PrimaryCompletionDate as PrimaryCompletionDate
SET ct.primaryCompletionDate=CASE WHEN size(study_metadata.PrimaryCompletionDate)=1 THEN PrimaryCompletionDate ELSE study_metadata.PrimaryCompletionDate END
;
// Create Create ClinicalTrial node, StudyType nodes and connects them
// Create the Location (Facility -> City -> Country) and link Facility to ClinicalTrial
// Create Primary Outcome Measure (Outcome) and link to ClinicalTrial
// Set lots of properties on ClinicalTrial
// - NOT OBSERVATIONAL AND INTERVENTIONAL STUDIES
// All others - QUERY at https://clinicaltrials.gov/api/gui/demo/simple_study_fields:
// COVID AND NOT AREA[StudyType]Interventional AND NOT AREA[StudyType]Observational
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,Phase,Condition,LeadSponsorName,LocationFacility,BriefTitle,InterventionName,CollaboratorName,LocationCity,OverallStatus,PrimaryOutcomeMeasure,EligibilityCriteria,StartDate,LocationState,StudyType,StudyFirstSubmitDate,PrimaryCompletionDate,LocationCountry&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.StudyType as StudyType
merge (ct:ClinicalTrial{NCTId:Id,data_source:'clinicaltrials.gov',url:'https://clinicaltrials.gov/ct2/show/' + Id})
MERGE(st:StudyType{type:StudyType}) MERGE(ct)-[:IS_TYPE]->(st)
WITH Id, ct, study_metadata, RANGE(0,size(study_metadata.LocationFacility)-1) as nfacil
FOREACH(i in nfacil | 
        MERGE(fa:Facility{name:study_metadata.LocationFacility[i]})
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(ct)-[:CONDUCTED_AT]->(fa)
        MERGE(fa)-[:LOCATED_IN]->(ci)
       )
WITH Id, study_metadata, RANGE(0,size(study_metadata.LocationCity)-1) as ncity
FOREACH(i in ncity | 
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(c:Country{name:study_metadata.LocationCountry[i]})
        MERGE(ci)-[:LOCATED_IN]->(c) 
               )
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.Condition as Condition
SET ct.condition= CASE WHEN size(study_metadata.Condition)>1 THEN study_metadata.Condition ELSE Condition END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.PrimaryOutcomeMeasure as PrimaryOutcomeMeasure 
MERGE(ot:PrimaryOutcomeMeasure{outcome:PrimaryOutcomeMeasure}) MERGE(ct)-[:INVESTIGATES_OUTCOME]->(ot)
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.EligibilityCriteria as EligibilityCriteria
with Id, study_metadata, ct, split(replace(replace(trim(substring(EligibilityCriteria,length(split(EligibilityCriteria,"Exclusion")[0])+19,size(EligibilityCriteria))),'\n','//'),'////','//'),'//') as Exclusion, 
split(replace(replace(trim(substring(EligibilityCriteria,19,length(split(EligibilityCriteria,"Exclusion")[0])-19)),'\n','//'),'////','//'),'//') as Inclusion
with Id, study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Inclusion)-1) as nincl
FOREACH(i in nincl | 
MERGE(incl:InclusionCriteria{criteria:Inclusion[i]}) MERGE(ct)-[:HAS_INCLUSION_CRITERIA]->(incl))
with Id, study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Exclusion)-1) as nexcl
FOREACH(i in nexcl | 
MERGE(excl:ExclusionCriteria{criteria:Exclusion[i]}) MERGE(ct)-[:HAS_EXCLUSION_CRITERIA]->(excl))
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.LeadSponsorName as LeadSponsorName 
SET ct.leadSponsorName=CASE WHEN size(study_metadata.LeadSponsorName)=1 THEN LeadSponsorName ELSE study_metadata.LeadSponsorName END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.BriefTitle as BriefTitle
SET ct.briefTitle=CASE WHEN size(study_metadata.BriefTitle)=1 THEN BriefTitle ELSE study_metadata.BriefTitle END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.CollaboratorName as CollaboratorName
SET ct.collaboratorName=CASE WHEN size(study_metadata.CollaboratorName)=1 THEN CollaboratorName ELSE study_metadata.CollaboratorName END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.OverallStatus as OverallStatus
SET ct.overallStatus=CASE WHEN size(study_metadata.OverallStatus)=1 THEN OverallStatus ELSE study_metadata.OverallStatus END
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.StartDate as StartDate
SET ct.startDate=CASE WHEN size(study_metadata.StartDate)=1 THEN StartDate ELSE study_metadata.StartDate END     
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.StudyFirstSubmitDate as StudyFirstSubmitDate
SET ct.studyFirstSubmitDate=CASE WHEN size(study_metadata.StudyFirstSubmitDate)=1 THEN StudyFirstSubmitDate ELSE study_metadata.StudyFirstSubmitDate END           
with Id, study_metadata
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.PrimaryCompletionDate as PrimaryCompletionDate
SET ct.primaryCompletionDate=CASE WHEN size(study_metadata.PrimaryCompletionDate)=1 THEN PrimaryCompletionDate ELSE study_metadata.PrimaryCompletionDate END
;
// Remove Inclusion or Exclusion nodes that are '-' or none
match(i:InclusionCriteria) where i.criteria in ['-', 'none'] DETACH DELETE i;
match(e:ExclusionCriteria) where e.criteria in ['-', 'none'] DETACH DELETE e;
