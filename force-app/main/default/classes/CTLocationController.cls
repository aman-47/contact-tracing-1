public with sharing class CTLocationController {
    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    public static List <Location__c> searchLocations (String searchTerm){
        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c 
                WHERE Name LIKE :searchTerm
                    OR Pincode__c LIKE :searchTerm
                    OR Address__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c NULLS LAST];

    }

    // get location by Id
    public static Location__c getLocationById(String locationId){
        List<Location__c> locations = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                        FROM Location__c 
                                        WHERE Id =:locationId];

        if(locations != null && locations.size() > 0){
            return locations[0];
        }   
        return null;                             
    }

    // get health status count in each location
    public static Map<String,Integer> getStatusCount(){
        Map<String,Integer> statusCount = new Map<String,Integer>();
        for(AggregateResult ar : [SELECT Status__c, COUNT(Id) total 
                                    FROM Location__c 
                                    GROUP BY Status__c]){
            String healthStatus = String.valueOf(ar.get('Status__c'));
            Integer countHealthStatus = Integer.valueOf(ar.get('total'));
            statusCount.put(healthStatus, countHealthStatus);
        }
        return statusCount;
    }

    public static void updateRedScore(Set<Id> locationIds){
        List<Location__c> locationToUpdate = new List<Location__c>();
        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total FROM Location_Tracing__c
                                                        WHERE Person__r.Health_Status__c = 'Red'
                                                        AND Visit_Date__c = LAST_N_DAYS:10
                                                        AND Location__c IN :locationIds
                                                        GROUP BY Location__c];
    
        for(AggregateResult ar : redPeoplePerLocation){
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = getStatus(redScore);
            locationToUpdate.add(new Location__c(Id=locationId, Red_Score__c=redScore, Status__c=status));
        }

        if(locationToUpdate != null && locationToUpdate.size() > 0){
            update locationToUpdate;
        }
                                                
    }

    public static String getStatus(Integer redScore){
        if(redScore == 0){
            return 'Green';
        }
        else if(redScore <= 5){
            return 'Yellow';
        }
        else if (redScore <= 10) {
            return 'Orange';
        }
        else {
            return 'Red';
        }
    }

    public static Map<String,Integer> getLocationHealthStatusCount(){
        AggregateResult[] healthCountMap = [SELECT Status__c, COUNT(Id) total FROM Location__c GROUP BY Status__c ];

        if(healthCountMap != null && healthCountMap.size() > 0){
            Map<String,Integer> result = new Map<String,Integer>();
            for(AggregateResult ar : healthCountMap){
                result.put(String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('total')));
            }
            return result;
        }
        return null;
    }
}