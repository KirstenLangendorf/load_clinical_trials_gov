CREATE INDEX ON :ClinicalTrial(NCTId);
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,OrgStudyId,BriefTitle,Acronym,OfficialTitle,StudyType&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.StudyType as StudyType
merge (ct:ClinicalTrial{NCTId:Id,data_source:'clinicaltrials.gov',url:'https://clinicaltrials.gov/ct2/show/' + Id})
MERGE (st:StudyType{type:StudyType}) MERGE(ct)-[:IS_TYPE]->(st)
WITH Id, ct, study_metadata
UNWIND study_metadata.OrgStudyId as OrgStudyId
UNWIND study_metadata.Acronym as Acronym
merge (si:StudyIdentification{studyId:OrgStudyId, acronym:Acronym}) MERGE(ct)-[:HAS_IDENTIFICATION]->(si)
WITH Id, si, study_metadata
UNWIND study_metadata.BriefTitle as BriefTitle
UNWIND study_metadata.OfficialTitle as OfficialTitle
MERGE (t:Title{briefTitle:BriefTitle,officialTitle:OfficialTitle}) MERGE (si)-[:HAS_TITLE]->(t);
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,OverallStatus,WhyStopped,StartDate,PrimaryCompletionDate,CompletionDate&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.OverallStatus as Status
MERGE(s:Status{status:Status})
MERGE(ct)-[:HAS_STATUS]->(s)
with ct, s, study_metadata
UNWIND study_metadata.WhyStopped as WhyStopped
MERGE(ct)-[:WAS_STOPPED]->(r:StopReason{reason:WhyStopped})
MERGE(s)-[:HAS_REASON]->(r)
with ct, study_metadata
UNWIND study_metadata.StartDate as StartDate
MERGE (d:Start{date:StartDate}) MERGE (ct)-[:STARTED_AT]->(d)
with ct, study_metadata
UNWIND study_metadata.PrimaryCompletionDate as PrimaryCompletionDate
UNWIND study_metadata.CompletionDate as CompletionDate
MERGE (e:Completed{primaryCompletionDate:PrimaryCompletionDate, completionDate: CompletionDate}) MERGE (ct)-[:COMPLETED_AT]->(e);
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,ResponsiblePartyType,ResponsiblePartyInvestigatorFullName,ResponsiblePartyInvestigatorAffiliation,LeadSponsorName,CollaboratorName&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.ResponsiblePartyType as ResponsiblePartyType
MERGE(r:Responsible{type:ResponsiblePartyType})
with r, study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.ResponsiblePartyInvestigatorFullName  as InvestigatorFullName
UNWIND study_metadata.ResponsiblePartyInvestigatorAffiliation as InvestigatorAffiliation
match(ct:ClinicalTrial{NCTId:Id}) MERGE(i:Investigator{name:InvestigatorFullName, affiliation:InvestigatorAffiliation})
MERGE(ct)-[:IS_CONDUCTED_BY]->(i)
with r, i, ct, study_metadata
UNWIND study_metadata.LeadSponsorName as LeadSponsorName
MERGE(k:Sponsor{name:LeadSponsorName})
MERGE(ct)-[:IS_SPONSORED_BY]->(k)
with r, i, k, ct, study_metadata
FOREACH(ignoreMe IN CASE WHEN r.type='Sponsor' THEN [1] ELSE [] END | 
    MERGE(r)-[:IS_RESPOSIBLE]->(k))
FOREACH(ignoreMe IN CASE WHEN r.type='Principal Investigator' THEN [1] ELSE [] END | 
    MERGE(r)-[:IS_RESPOSIBLE]->(i))
FOREACH(ignoreMe IN CASE WHEN r.type='Sponsor-Investigator' THEN [1] ELSE [] END | 
    MERGE(r)-[:IS_RESPOSIBLE]->(k) 
    MERGE(r)-[:IS_RESPOSIBLE]->(i))
with ct, study_metadata
UNWIND study_metadata.CollaboratorName as CollaboratorName
MERGE(sp:Collaborator{name:CollaboratorName})
MERGE(ct)-[:IS_SUPPORTED_BY]->(sp);
MERGE(r:Response{YN:'Yes'})
MERGE(k:Response{YN:'No'});
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,IsFDARegulatedDrug,IsFDARegulatedDevice,IsUnapprovedDevice,HasExpandedAccess&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.IsFDARegulatedDrug as IsFDARegulatedDrug
UNWIND study_metadata.IsFDARegulatedDevice as IsFDARegulatedDevice
UNWIND study_metadata.IsUnapprovedDevice as IsUnapprovedDevice
UNWIND study_metadata.HasExpandedAccess as HasExpandedAccess
match(ct:ClinicalTrial{NCTId:Id})
MATCH(r:Response{YN:'Yes'})
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDrug='Yes' THEN [1] ELSE [] END | 
     MERGE(ct)-[:IS_FDA_REGULATED_DRUG]->(r)) 
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDevice='Yes' THEN [1] ELSE [] END | 
     MERGE(ct)-[:IS_FDA_REGULATED_DEVICE]->(r))
FOREACH(ignoreMe IN CASE WHEN IsUnapprovedDevice='Yes' THEN [1] ELSE [] END | 
     MERGE(ct)-[:IS_UNAPPROVED_DEVICE]->(r)) 
FOREACH(ignoreMe IN CASE WHEN HasExpandedAccess='Yes' THEN [1] ELSE [] END | 
     MERGE(ct)-[:HAS_EXPANDED_ACCESS]->(r))
with ct, study_metadata, IsFDARegulatedDrug, IsFDARegulatedDevice, IsUnapprovedDevice, HasExpandedAccess
MATCH(r:Response{YN:'No'})
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDrug='No' THEN [1] ELSE [] END | 
    MERGE(ct)-[:IS_FDA_REGULATED_DRUG]->(r))
FOREACH(ignoreMe IN CASE WHEN IsFDARegulatedDevice='No' THEN [1] ELSE [] END | 
   MERGE(ct)-[:IS_FDA_REGULATED_DEVICE]->(r))
FOREACH(ignoreMe IN CASE WHEN IsUnapprovedDevice='No' THEN [1] ELSE [] END | 
    MERGE(ct)-[:IS_UNAPPROVED_DEVICE]->(r))
FOREACH(ignoreMe IN CASE WHEN HasExpandedAccess='No' THEN [1] ELSE [] END | 
     MERGE(ct)-[:HAS_EXPANDED_ACCESS]->(r));
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,BriefSummary,DetailedDescription,Condition,Keyword&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.BriefSummary as BriefSummary
UNWIND study_metadata.DetailedDescription as DetailedDescription
MERGE (t:Description{summary:BriefSummary,detailed:DetailedDescription}) MERGE (ct)-[:HAS_DESCRIPTION]->(t)
with ct, study_metadata
UNWIND study_metadata.Condition as Condition
UNWIND study_metadata.Keyword as Keyword
MERGE (c:Condition{disease:Condition}) 
MERGE(k:Keyword{word:Keyword}) 
MERGE (ct)-[:IS_STUDYING]->(c)
MERGE (c)-[:HAS_KEYWORD]->(k);
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,DesignObservationalModel,DesignTimePerspective,BioSpecRetention,BioSpecDescription&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.DesignObservationalModel as Model
UNWIND study_metadata.DesignTimePerspective as DesignTimePerspective
UNWIND study_metadata.BioSpecRetention as BioSpecRetention
UNWIND study_metadata.BioSpecDescription as BioSpecDescription
match(ct:ClinicalTrial{NCTId:Id})
MERGE(m:Design{model:Model}) 
MERGE(t:ObservationPeriod{time:DesignTimePerspective})
MERGE (ct)-[:HAS_STUDY_DESIGN]->(m)
MERGE (ct)-[:HAS_OBSERVATION_PERIOD]->(t)
MERGE(b:BioSpecimen{retension:BioSpecRetention, description:BioSpecDescription})
MERGE(ct)-[:HAS_SMAPLES_RETAINED_IN_BIOREPOSITORY]->(b);
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,DesignObservationalModel,ArmGroupLabel,ArmGroupType,ArmGroupDescription,InterventionType,InterventionName,InterventionOtherName,InterventionDescription&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
UNWIND study_metadata.DesignObservationalModel as Model
match(ct:ClinicalTrial{NCTId:Id})-[:HAS_STUDY_DESIGN]->(m:Design{model:Model})
with m, ct, RANGE(0,size(study_metadata.ArmGroupLabel)-1) as narm, study_metadata
FOREACH(i in narm | 
MERGE(a:Arm{name:study_metadata.ArmGroupLabel[i],description:'',type:''}) 
        SET a.description=study_metadata.ArmGroupDescription[i]
        SET a.type=study_metadata.ArmGroupType[i]
        MERGE(ct)-[:HAS_STUDY_ARMS]->(a)-[:BELONGS_TO_MODEL]->(m)
        )
with ct, study_metadata, RANGE(0,size(study_metadata.InterventionName)-1) as nelem
FOREACH(i in nelem | 
MERGE(e:Intervention{name:study_metadata.InterventionName[i],description:'',type:''})
        SET e.description=study_metadata.InterventionDescription[i]
        SET e.type=study_metadata.InterventionType[i]
        MERGE(ct)-[:INVESTIGATES_INTERVENTION]->(e));
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,PrimaryOutcomeMeasure,PrimaryOutcomeDescription,PrimaryOutcomeTimeFrame,SecondaryOutcomeMeasure,SecondaryOutcomeDescription,SecondaryOutcomeTimeFrame,OtherOutcomeMeasure,OtherOutcomeDescription,OtherOutcomeTimeFrame&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with ct, RANGE(0,size(study_metadata.PrimaryOutcomeMeasure)-1) as npout, study_metadata
FOREACH(i in npout | 
MERGE(a:Outcome{name:study_metadata.PrimaryOutcomeMeasure[i],description:'',type:''}) 
        SET a.description=study_metadata.PrimaryOutcomeDescription[i]
        SET a.time=study_metadata.PrimaryOutcomeTimeFrame[i]
        MERGE(ct)-[:HAS_PRIMARY_OUTCOME]->(a)
        )

with ct, RANGE(0,size(study_metadata.SecondaryOutcomeMeasure)-1) as nsout, study_metadata
FOREACH(i in nsout | 
MERGE(a:Outcome{name:study_metadata.SecondaryOutcomeMeasure[i],description:'',type:''}) 
        SET a.description=study_metadata.SecondaryOutcomeDescription[i]
        SET a.time=study_metadata.SecondaryOutcomeTimeFrame[i]
        MERGE(ct)-[:HAS_SECONDARY_OUTCOME]->(a)
        )
with ct, RANGE(0,size(study_metadata.OtherOutcomeMeasure)-1) as noout, study_metadata
FOREACH(i in noout | 
MERGE(a:Outcome{name:study_metadata.OtherOutcomeMeasure[i],description:'',type:''}) 
        SET a.description=study_metadata.OtherOutcomeDescription[i]
        SET a.time=study_metadata.OtherOutcomeTimeFrame[i]
        MERGE(ct)-[:HAS_OTHER_OUTCOME]->(a)
        );
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,Gender,GenderBased,GenderDescription,MinimumAge,MaximumAge,HealthyVolunteers,StudyPopulation,SamplingMethod,EligibilityCriteria&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.StudyPopulation as StudyPopulation
MERGE (p:StudyPopulation{name:StudyPopulation, sampling:''})
MERGE (ct)-[:HAS_STUDY_POPULATION]->(p)
with study_metadata, ct, p
UNWIND study_metadata.SamplingMethod as SamplingMethod
SET p.sampling=SamplingMethod
with study_metadata, ct, p
UNWIND study_metadata.Gender as Gender
UNWIND study_metadata.GenderDescription as GenderDescription
MERGE (g:Gender{name:Gender,description:GenderDescription})
MERGE (p)-[:INCLUDES_GENDER]->(g)
with study_metadata, ct, p
UNWIND study_metadata.MinimumAge as MinAge
UNWIND study_metadata.MaximumAge as MaxAge
MERGE (a:AgeRange{minAge:MinAge,maxAge:MaxAge})
MERGE (p)-[:INCLUDES_AGE_RANGE]->(a)
with ct, study_metadata
UNWIND study_metadata.EligibilityCriteria as EligibilityCriteria
with study_metadata, ct, split(replace(replace(trim(substring(EligibilityCriteria,length(split(EligibilityCriteria,"Exclusion")[0])+19,size(EligibilityCriteria))),'\n','#'),'##','#'),'#') as Exclusion, 
split(replace(replace(trim(substring(EligibilityCriteria,19,length(split(EligibilityCriteria,"Exclusion")[0])-19)),'\n','#'),'##','#'),'#') as Inclusion
with study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Inclusion)-1) as nincl
FOREACH(i in nincl |  
MERGE(incl:InclusionCriteria{criteria:Inclusion[i]}) MERGE(ct)-[:HAS_INCLUSION_CRITERIA]->(incl)) 
with study_metadata, ct, Inclusion, Exclusion, RANGE(0,size(Exclusion)-1) as nexcl
FOREACH(i in nexcl | 
MERGE(excl:ExclusionCriteria{criteria:Exclusion[i]}) MERGE(ct)-[:HAS_EXCLUSION_CRITERIA]->(excl));
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,CentralContactName,CentralContactEmail,OverallOfficialName,OverallOfficialAffiliation,OverallOfficialRole&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
UNWIND study_metadata.CentralContactName as Name
MERGE (c:Contact{name:Name, email:''})
MERGE (ct)-[:HAS_CONTACT_PERSON]->(c)
with study_metadata,c
UNWIND study_metadata.CentralContactEmail as Email
SET c.email=Email;
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,LocationFacility,LocationCity,LocationState,LocationCountry&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
WITH Id, ct, study_metadata, RANGE(0,size(study_metadata.LocationFacility)-1) as nfacil
FOREACH(i in nfacil | 
        MERGE(fa:Facility{facilityName:study_metadata.LocationFacility[i]})
        MERGE(ci:City{cityName:study_metadata.LocationCity[i]})
        MERGE(c:Country{countryName:study_metadata.LocationCountry[i]})
        MERGE(ct)-[:CONDUCTED_AT]->(fa)
        MERGE(fa)-[:LOCATED_IN]->(ci)
       )
WITH Id, study_metadata, RANGE(0,size(study_metadata.LocationCity)-1) as ncity
FOREACH(i in ncity | 
        MERGE(ci:City{cityName:study_metadata.LocationCity[i]})
        MERGE(c:Country{countryName:study_metadata.LocationCountry[i]})
        MERGE(ci)-[:LOCATED_IN]->(c) 
               );
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId&fmt=json&max_rnk=1000') yield value
with value.StudyFieldsResponse.NStudiesFound as NStudies, RANGE(0,(value.StudyFieldsResponse.NStudiesFound/1000)) as nloop
UNWIND nloop as i
with range(1+1000*i,1000+1000*i,999) as RANGES
with RANGES, RANGES[1] as urange, RANGES[0] as lrange
call apoc.load.json('https://clinicaltrials.gov/api/query/study_fields?expr=COVID+AND+AREA%5BStudyType%5DObservational&fields=NCTId,ReferencePMID,ReferenceCitation,ReferenceType,SeeAlsoLinkURL&min_rnk='+lrange+'&max_rnk='+urange+'&fmt=json') yield value
with value.StudyFieldsResponse.StudyFields as coll unwind coll as study_metadata
UNWIND study_metadata.NCTId as Id
match(ct:ClinicalTrial{NCTId:Id})
with ct, study_metadata, RANGE(0,size(study_metadata.ReferencePMID)-1) as nref
FOREACH(i in nref | 
        MERGE(p:PubMedId{name:study_metadata.ReferencePMID[i]})
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
MERGE(ct)-[:REFERS_TO_URL]->(l);
//Remove Inclusion or Exclusion nodes that are '-' or none
 match(i:InclusionCriteria) where i.criteria in ['-', 'none'] DETACH DELETE i;
 match(e:ExclusionCriteria) where e.criteria in ['-', 'none'] DETACH DELETE e;
