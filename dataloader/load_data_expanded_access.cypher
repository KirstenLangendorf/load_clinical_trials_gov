call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,OrgStudyId,BriefTitle,Acronym,OfficialTitle,StudyType&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.StudyType as StudyType
merge (ct:ClinicalTrial{NCTId:Id,data_source:'clinicaltrials.gov',url:'https://clinicaltrials.gov/ct2/show/' + Id})
MERGE (st:StudyType{type:StudyType}) 
MERGE(ct)-[:IS_TYPE]->(st)
with ct, study_metadata
UNWIND study_metadata.OrgStudyId as OrgStudyId
merge (ct)-[:HAS_IDENTIFICATION]->(si:StudyIdentification{studyId:OrgStudyId})
WITH si, study_metadata
UNWIND study_metadata.BriefTitle as BriefTitle
UNWIND study_metadata.OfficialTitle as OfficialTitle
MERGE (t:Title{briefTitle:BriefTitle}) 
ON CREATE set t.officialTitle=OfficialTitle
MERGE (si)-[:HAS_TITLE]->(t)
with si, study_metadata
UNWIND study_metadata.Acronym as Acronym
set si.acronym=Acronym
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,OverallStatus,WhyStopped,StartDate,PrimaryCompletionDate,CompletionDate&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.OverallStatus as Status
MERGE(s:Status{status:Status})
MERGE(ct)-[:HAS_STATUS]->(s)
with ct,s, study_metadata
UNWIND study_metadata.StartDate as StartDate
MERGE (d:Start{date:StartDate}) MERGE (ct)-[:STARTED_AT]->(d)
with ct, s, study_metadata
UNWIND study_metadata.PrimaryCompletionDate as PrimaryCompletionDate
UNWIND study_metadata.CompletionDate as CompletionDate
MERGE (e:Completed{primaryCompletionDate:PrimaryCompletionDate, completionDate: CompletionDate}) 
MERGE (ct)-[:COMPLETED_AT]->(e)
with ct, s, study_metadata
UNWIND study_metadata.WhyStopped as WhyStopped
MERGE(ct)-[:WAS_STOPPED]->(r:StopReason{reason:WhyStopped})
MERGE(s)-[:HAS_REASON]->(r)
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,ResponsiblePartyType,ResponsiblePartyInvestigatorFullName,ResponsiblePartyInvestigatorAffiliation,LeadSponsorName,CollaboratorName&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.ResponsiblePartyType as ResponsiblePartyType
MERGE(r:Responsible{type:ResponsiblePartyType})
with r, study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id}) 
UNWIND study_metadata.LeadSponsorName as LeadSponsorName
MERGE(k:Sponsor{name:LeadSponsorName})
FOREACH(ignoreMe IN CASE WHEN r.type='Sponsor' THEN [1] ELSE [] END | 
    MERGE(r)-[:IS_RESPONSIBLE]->(k)
    MERGE(ct)-[:IS_SPONSORED_BY]->(k))
with ct, k, r, study_metadata
UNWIND study_metadata.ResponsiblePartyInvestigatorFullName  as InvestigatorFullName
UNWIND study_metadata.ResponsiblePartyInvestigatorAffiliation as InvestigatorAffiliation
MERGE(i:Investigator{name:InvestigatorFullName, affiliation:InvestigatorAffiliation})
MERGE(ct)-[:IS_CONDUCTED_BY]->(i)
with ct, r, i,k,study_metadata
FOREACH(ignoreMe IN CASE WHEN r.type='Principal Investigator' THEN [1] ELSE [] END | 
    MERGE(r)-[:IS_RESPONSIBLE]->(i))
FOREACH(ignoreMe IN CASE WHEN r.type='Sponsor-Investigator' THEN [1] ELSE [] END | 
    MERGE(r)-[:IS_RESPONSIBLE]->(k) 
    MERGE(r)-[:IS_RESPONSIBLE]->(i))
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,ResponsiblePartyType,ResponsiblePartyInvestigatorFullName,ResponsiblePartyInvestigatorAffiliation,LeadSponsorName,CollaboratorName&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.CollaboratorName as CollaboratorName
MERGE(sp:Collaborator{name:CollaboratorName})
MERGE(ct)-[:IS_SUPPORTED_BY]->(sp)
;
MERGE(r:Response{YN:'Yes'})
;
MERGE(k:Response{YN:'No'})
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,IsFDARegulatedDrug,IsFDARegulatedDevice,IsUnapprovedDevice,HasExpandedAccess&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id}), (r:Response{YN:'Yes'})
UNWIND study_metadata.IsUnapprovedDevice as IsUnapprovedDevice
FOREACH(ignoreMe IN CASE WHEN IsUnapprovedDevice='Yes' THEN [1] ELSE [] END | 
      MERGE(ct)-[:IS_FDA_REGULATED_DEVICE]->(r))
with study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id}),(r:Response{YN:'No'})
UNWIND study_metadata.IsUnapprovedDevice as IsUnapprovedDevice
FOREACH(ignoreMe IN CASE WHEN IsUnapprovedDevice='No' THEN [1] ELSE [] END | 
      MERGE(ct)-[:IS_FDA_REGULATED_DEVICE]->(r))
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,IsFDARegulatedDrug,IsFDARegulatedDevice,IsUnapprovedDevice,HasExpandedAccess&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.IsFDARegulatedDrug as IsFDARegulatedDrug
match(ct:ClinicalTrial{NCTId:Id}),(r:Response{YN:'Yes'})
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDrug='Yes' THEN [1] ELSE [] END | 
     MERGE(ct)-[:IS_FDA_REGULATED_DRUG]->(r))
with study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.IsFDARegulatedDrug as IsFDARegulatedDrug
match(ct:ClinicalTrial{NCTId:Id}),(r:Response{YN:'No'})
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDrug='No' THEN [1] ELSE [] END | 
    MERGE(ct)-[:IS_FDA_REGULATED_DRUG]->(r))
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,IsFDARegulatedDrug,IsFDARegulatedDevice,IsUnapprovedDevice,HasExpandedAccess&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id}),(r:Response{YN:'Yes'})
UNWIND study_metadata.IsFDARegulatedDevice as IsFDARegulatedDevice
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDevice='Yes' THEN [1] ELSE [] END |
           MERGE(ct)-[:IS_FDA_REGULATED_DEVICE]->(r))
with study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id}),(r:Response{YN:'No'})
UNWIND study_metadata.IsFDARegulatedDevice as IsFDARegulatedDevice
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDevice='No' THEN [1] ELSE [] END | 
      MERGE(ct)-[:IS_FDA_REGULATED_DEVICE]->(r))
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,IsFDARegulatedDrug,IsFDARegulatedDevice,IsUnapprovedDevice,HasExpandedAccess&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id}),(r:Response{YN:'Yes'})
UNWIND study_metadata.HasExpandedAccess as HasExpandedAccess
FOREACH(ignoreMe IN CASE WHEN HasExpandedAccess='Yes' THEN [1] ELSE [] END | 
      MERGE(ct)-[:HAS_EXPANDED_ACCESS]->(r))
with study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id}),(r:Response{YN:'No'})
UNWIND study_metadata.HasExpandedAccess as HasExpandedAccess
FOREACH(ignoreMe IN CASE WHEN HasExpandedAccess='No' THEN [1] ELSE [] END | 
      MERGE(ct)-[:HAS_EXPANDED_ACCESS]->(r))
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,BriefSummary,DetailedDescription,Condition,Keyword&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.BriefSummary as BriefSummary
MERGE (ct)-[:HAS_DESCRIPTION]->(t:Description{summary:BriefSummary})
with ct,t, study_metadata
UNWIND study_metadata.Condition as Condition
MERGE (c:Condition{disease:Condition})
MERGE (ct)-[:IS_STUDYING]->(c)
with ct, c, t,study_metadata
UNWIND study_metadata.Keyword as Keyword
MERGE(k:Keyword{word:Keyword}) 
MERGE(ct)-[:IS_STUDYING]->(k) 
with ct, t, study_metadata
UNWIND study_metadata.DetailedDescription as DetailedDescription
set t.description=DetailedDescription
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,DesignObservationalModel,DesignTimePerspective,BioSpecRetention,BioSpecDescription&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.DesignObservationalModel as Model
match(ct:ClinicalTrial{NCTId:Id})
MERGE(m:Design{model:Model}) 
MERGE (ct)-[:HAS_STUDY_DESIGN]->(m)
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,DesignObservationalModel,DesignTimePerspective,BioSpecRetention,BioSpecDescription&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.DesignTimePerspective as DesignTimePerspective
match(ct:ClinicalTrial{NCTId:Id})
MERGE(t:ObservationPeriod{time:DesignTimePerspective})
MERGE (ct)-[:HAS_OBSERVATION_PERIOD]->(t)
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,DesignObservationalModel,DesignTimePerspective,BioSpecRetention,BioSpecDescription&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.BioSpecRetention as BioSpecRetention
match(ct:ClinicalTrial{NCTId:Id})
MERGE(b:BioSpecimen{retension:BioSpecRetention})
MERGE(ct)-[:HAS_SMAPLES_RETAINED_IN_BIOREPOSITORY]->(b)
with b, study_metadata
UNWIND study_metadata.BioSpecDescription as BioSpecDescription
SET b.description=BioSpecDescription
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,DesignObservationalModel,ArmGroupLabel,ArmGroupType,ArmGroupDescription,InterventionType,InterventionName,InterventionOtherName,InterventionDescription&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.DesignObservationalModel as Model
match(ct:ClinicalTrial{NCTId:Id})-[:HAS_STUDY_DESIGN]->(m:Design{model:Model})
with m, ct, RANGE(0,size(study_metadata.ArmGroupLabel)-1) as narm, study_metadata
FOREACH(i in narm | 
MERGE(a:Arm{name:study_metadata.ArmGroupLabel[i]}) 
 ON CREATE SET a.description=study_metadata.ArmGroupDescription[i]
 ON CREATE SET a.type=study_metadata.ArmGroupType[i]
        MERGE(ct)-[:HAS_STUDY_ARMS]->(a)-[:BELONGS_TO_MODEL]->(m)
        )
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,DesignObservationalModel,ArmGroupLabel,ArmGroupType,ArmGroupDescription,InterventionType,InterventionName,InterventionOtherName,InterventionDescription&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with ct, study_metadata, RANGE(0,size(study_metadata.InterventionName)-1) as nelem
FOREACH(i in nelem | 
MERGE(ct)-[:INVESTIGATES_INTERVENTION]->(e:Intervention{name:study_metadata.InterventionName[i]})
  ON CREATE SET e.description=study_metadata.InterventionDescription[i]
  ON CREATE SET e.type=study_metadata.InterventionType[i]
        )
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,PrimaryOutcomeMeasure,PrimaryOutcomeDescription,PrimaryOutcomeTimeFrame,SecondaryOutcomeMeasure,SecondaryOutcomeDescription,SecondaryOutcomeTimeFrame,OtherOutcomeMeasure,OtherOutcomeDescription,OtherOutcomeTimeFrame&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with ct, RANGE(0,size(study_metadata.PrimaryOutcomeMeasure)-1) as npout, study_metadata
FOREACH(i in npout | 
MERGE(ct)-[:HAS_PRIMARY_OUTCOME]->(a:Outcome{name:study_metadata.PrimaryOutcomeMeasure[i]}) 
  ON CREATE SET a.description=study_metadata.PrimaryOutcomeDescription[i]
  ON CREATE SET a.time=study_metadata.PrimaryOutcomeTimeFrame[i]
               )
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,PrimaryOutcomeMeasure,PrimaryOutcomeDescription,PrimaryOutcomeTimeFrame,SecondaryOutcomeMeasure,SecondaryOutcomeDescription,SecondaryOutcomeTimeFrame,OtherOutcomeMeasure,OtherOutcomeDescription,OtherOutcomeTimeFrame&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with ct, RANGE(0,size(study_metadata.SecondaryOutcomeMeasure)-1) as nsout, study_metadata
FOREACH(i in nsout | 
MERGE(ct)-[:HAS_SECONDARY_OUTCOME]->(a:Outcome{name:study_metadata.SecondaryOutcomeMeasure[i]}) 
  ON CREATE SET a.description=study_metadata.SecondaryOutcomeDescription[i]
  ON CREATE SET a.time=study_metadata.SecondaryOutcomeTimeFrame[i]
        )
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,PrimaryOutcomeMeasure,PrimaryOutcomeDescription,PrimaryOutcomeTimeFrame,SecondaryOutcomeMeasure,SecondaryOutcomeDescription,SecondaryOutcomeTimeFrame,OtherOutcomeMeasure,OtherOutcomeDescription,OtherOutcomeTimeFrame&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with ct, RANGE(0,size(study_metadata.OtherOutcomeMeasure)-1) as noout, study_metadata
FOREACH(i in noout | 
MERGE(ct)-[:HAS_OTHER_OUTCOME]->(a:Outcome{name:study_metadata.OtherOutcomeMeasure[i]}) 
  ON CREATE SET a.description=study_metadata.OtherOutcomeDescription[i]
  ON CREATE SET a.time=study_metadata.OtherOutcomeTimeFrame[i]
                )
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,Gender,GenderBased,GenderDescription,MinimumAge,MaximumAge,HealthyVolunteers,StudyPopulation,SamplingMethod,EligibilityCriteria&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.StudyPopulation as StudyPopulation
MERGE (p:StudyPopulation{name:StudyPopulation})
MERGE (ct)-[:HAS_STUDY_POPULATION]->(p)
with study_metadata, ct, p
UNWIND study_metadata.SamplingMethod as SamplingMethod
SET p.sampling=SamplingMethod
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,Gender,GenderBased,GenderDescription,MinimumAge,MaximumAge,HealthyVolunteers,StudyPopulation,SamplingMethod,EligibilityCriteria&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with study_metadata, ct
UNWIND study_metadata.Gender as Gender
MERGE (ct)-[:INCLUDES_GENDER]->(g:Gender{name:Gender})
with ct, g, study_metadata
UNWIND study_metadata.GenderDescription as GenderDescription
set g.description=GenderDescription
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,Gender,GenderBased,GenderDescription,MinimumAge,MaximumAge,HealthyVolunteers,StudyPopulation,SamplingMethod,EligibilityCriteria&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with study_metadata, ct
UNWIND study_metadata.MinimumAge as MinAge
UNWIND study_metadata.MaximumAge as MaxAge
MERGE (ct)-[:INCLUDES_AGE_RANGE]->(a:AgeRange{minAge:MinAge,maxAge:MaxAge})
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,Gender,GenderBased,GenderDescription,MinimumAge,MaximumAge,HealthyVolunteers,StudyPopulation,SamplingMethod,EligibilityCriteria&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.EligibilityCriteria as EligibilityCriteria
with ct, EligibilityCriteria,
  CASE WHEN apoc.text.indexOf(toUpper(EligibilityCriteria),'INCLUSION CRITERIA')> -1 THEN split(replace(replace(trim(substring(EligibilityCriteria,19,size(split(EligibilityCriteria,"Exclusion")[0])-19)),'\n','#'),'##','#'),'#') ELSE ["none"] END AS Inclusion,
  CASE WHEN apoc.text.indexOf(toUpper(EligibilityCriteria),'EXCLUSION CRITERIA')> -1 THEN split(replace(replace(trim(substring(EligibilityCriteria,size(split(EligibilityCriteria,"Exclusion")[0])+19,size(EligibilityCriteria))),'\n','#'),'##','#'),'#')  ELSE ["none"] END AS Exclusion
with ct, Inclusion, Exclusion, RANGE(0,size(Inclusion)-1) as nincl
FOREACH(i in nincl |  
MERGE(incl:InclusionCriteria{criteria:Inclusion[i]}) MERGE(ct)-[:HAS_INCLUSION_CRITERIA]->(incl)) 
with ct, Inclusion, Exclusion, RANGE(0,size(Exclusion)-1) as nexcl
FOREACH(i in nexcl | 
MERGE(excl:ExclusionCriteria{criteria:Exclusion[i]}) MERGE(ct)-[:HAS_EXCLUSION_CRITERIA]->(excl))
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,CentralContactName,CentralContactEmail,OverallOfficialName,OverallOfficialAffiliation,OverallOfficialRole&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.CentralContactName as Name
UNWIND study_metadata.CentralContactEMail as Email
MERGE (ct)-[:HAS_CONTACT_PERSON]->(c:Contact{name:Name,email:Email})
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,LocationFacility,LocationCity,LocationState,LocationCountry&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
WITH Id, ct, study_metadata, RANGE(0,size(study_metadata.LocationFacility)-1) as nfacil
FOREACH(i in nfacil | 
        MERGE(fa:Facility{name:study_metadata.LocationFacility[i]})
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(c:Country{name:study_metadata.LocationCountry[i]})
        MERGE(ct)-[:CONDUCTED_AT]->(fa)
        MERGE(fa)-[:LOCATED_IN]->(ci)
       )
WITH Id, study_metadata, RANGE(0,size(study_metadata.LocationCity)-1) as ncity
FOREACH(i in ncity | 
        MERGE(ci:City{name:study_metadata.LocationCity[i]})
        MERGE(c:Country{name:study_metadata.LocationCountry[i]})
        MERGE(ci)-[:LOCATED_IN]->(c) 
               )
;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+NOT+AREA%5BStudyType%5DInterventional+AND+NOT+AREA%5BStudyType%5DObservational&fields=NCTId,ReferencePMID,ReferenceCitation,ReferenceType,SeeAlsoLinkURL&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with ct, study_metadata, RANGE(0,size(study_metadata.ReferencePMID)-1) as nref
FOREACH(i in nref | 
        MERGE(p:PaperId{id:study_metadata.ReferencePMID[i],type:'pubmed_id'})
        MERGE(c:Citation{name:study_metadata.ReferenceCitation[i]})
        MERGE(r:ReferenceType{name:study_metadata.ReferenceType[i]})
        MERGE(ct)-[:REFERS_TO]->(c)
        MERGE(c)-[:IS_REFERENCE_TYPE]->(r)
        MERGE(c)-[:HAS_PUBLICATION_ID]->(p)
        MERGE(ct)-[:USE_REFERENCE_AS]->(r)
        )
with ct, study_metadata
UNWIND study_metadata.SeeAlsoLinkURL as URL
MERGE(l:Link{url:URL})
MERGE(ct)-[:REFERS_TO_URL]->(l)
;
match(i:InclusionCriteria) where i.criteria in ['-', 'none'] DETACH DELETE i
;
match(e:ExclusionCriteria) where e.criteria in ['-', 'none'] DETACH DELETE e
;
