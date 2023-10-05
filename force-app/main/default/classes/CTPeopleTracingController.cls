public with sharing class CTPeopleTracingController {
    
    public static List<People_Tracing__c> getTraces(String recordId){
        return[SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c 
                FROM People_Tracing__c 
                WHERE (Person_1__c =: recordId
                    OR Person_2__c =: recordId)
                    AND Contact_Date__c = LAST_N_DAYS:30
                ORDER BY Contact_Date__c DESC];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces){
        // unique person ids
        Set<Id> personsIds = new Set<Id>();
        for(People_Tracing__c trace : peopleTraces){
            personsIds.add(trace.Person_1__c);
            personsIds.add(trace.Person_2__c);
        }

        // list of duplicate records
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();

        // map id and set<id>
        Map<Id,Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        // query for existing records
        List<People_Tracing__c> existingRecords = [SELECT Id, Person_1__c, Person_2__c
                                                    FROM People_Tracing__c
                                                    WHERE Person_1__c IN:personsIds
                                                     OR Person_2__c IN:personsIds ];

        if(existingRecords != null && existingRecords.size()>0){
            for(People_Tracing__c trace : existingRecords){
                // build map for person 1
                if(! mapOfExistingRecords.containsKey(trace.Person_1__c)){
                    mapOfExistingRecords.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);

                // build map for person 2
                if(! mapOfExistingRecords.containsKey(trace.Person_2__c)){
                    mapOfExistingRecords.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);
            }

            for(People_Tracing__c traces : peopleTraces){
                if(mapOfExistingRecords.containsKey(traces.Person_1__c) && mapOfExistingRecords.get(traces.Person_1__c).contains(traces.Person_2__c)
                ||
                mapOfExistingRecords.containsKey(traces.Person_2__c) && mapOfExistingRecords.get(traces.Person_2__c).contains(traces.Person_1__c)
                ){
                    duplicates.add(traces);
                }
                
            }
        }
         return duplicates;
    }
}