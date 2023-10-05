public with sharing class AccountContactService {
    public static void updateActiveContacts(Set<Id> accIds) {
        List<AggregateResult> results = [
            SELECT AccountId, Count(Id) totalContacts 
            FROM Contact 
            WHERE Active__c = true AND AccountId IN :accIds 
            GROUP BY AccountId
        ];
        Map<Id, Account> accToUpdate = new Map<Id, Account>();
        for(AggregateResult result : results){
            // get account if and number of Active contacts
            String accId = String.valueOf(result.get('AccountId'));
            Integer totalContacts = Integer.valueOf(result.get('totalContacts'));
            // make sure to use id field in your account to update
            Account acc = new Account(Id=accId, Active_Contacts__c=totalContacts);
            accToUpdate.put(accId, acc);
        }

        // update accounts with zero active contacts
        for(Id accId : accIds){
            if(!accToUpdate.containsKey(accId)){
                accToUpdate.put(accId, new Account(Id = accId, Active_Contacts__c = 0));
            }
        }

        // update the final list of accounts
        update accToUpdate.values();
    }
}