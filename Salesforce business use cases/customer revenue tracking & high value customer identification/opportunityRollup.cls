public class opportunityRollup
{
     public static void handleAfterUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMap)
     {
          Set<Id> accountIds = new Set<Id>();

        for (Opportunity newOpp : newOpportunities)
        {
            if (newOpp.AccountId != null && (newOpp.StageName != oldMap.get(newOpp.Id).StageName || newOpp.Amount != oldMap.get(newOpp.Id).Amount))
            {
                accountIds.add(newOpp.AccountId);
            }
        }
        // Step 2: Prepare each Account starting at 0
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

        for (Id accId : accountIds)
        {
            accountsToUpdate.put(accId, new Account(Id = accId,Total_Won_Amount__c = 0,Total_Won_Deals__c = 0));
        }

        // Step 3: Get all Closed Won Opportunities
        List<Opportunity> wonOpps = [
            SELECT AccountId, Amount
            FROM Opportunity
            WHERE AccountId IN :accountIds AND StageName = 'Closed Won'
        ];

        // Step 4: Add each deal to its Account's total
        for (Opportunity opp : wonOpps)
        {
            Account acc = accountsToUpdate.get(opp.AccountId);
            if (opp.Amount != null)
            {
                acc.Total_Won_Amount__c = acc.Total_Won_Amount__c + opp.Amount;
            }
            acc.Total_Won_Deals__c = acc.Total_Won_Deals__c + 1;
        }

        // Step 5: Save all Accounts
        update accountsToUpdate.values();
    }
}