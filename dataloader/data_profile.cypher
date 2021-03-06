// Some staticstics of propteries in the nodes of type ClinicalTrials
MATCH (l:ClinicalTrial)
UNWIND keys(l) as key
UNWIND l[key] as val
RETURN l.NCTId as trialID , key as Property, l[key] as Response, size(collect(distinct val)) as numberOfResponses;

// Frequency count of studies by StudyType and Phase
match(t:ClinicalTrial) WITH count(t.NCTId) as TotalCount
match(l:ClinicalTrial) OPTIONAL MATCH (l)-[:IS_TYPE]->(s:StudyType) OPTIONAL match(p:Phase)<-[:IS_PHASE]-(l)
WITH TotalCount, s.type as StudyType, p.phase as Phase, count(l:NCTId) as NumberOfClinicalTrials 
RETURN StudyType, Phase, NumberOfClinicalTrials, TotalCount order by StudyType, Phase;

// Frequency count of studies by StudyType and Country
match(t:ClinicalTrial) WITH count(t.NCTId) as TotalCount
match(l:ClinicalTrial) OPTIONAL MATCH (l)-[:IS_TYPE]->(s:StudyType) OPTIONAL match(c:Country)<-[:LOCATED_IN]-(ci:City)<-[:LOCATED_IN]-(fa:Facility)<-[:CONDUCTED_AT]-(l)
WITH TotalCount, s.type as StudyType, c.countryName as Country, count(l:NCTId) as NumberOfClinicalTrials 
RETURN StudyType, Country, NumberOfClinicalTrials, TotalCount order by Country, StudyType;
