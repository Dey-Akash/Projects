@isTest
public class OpportunityRollupHandlerTest
{
	 @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;
    }

    @isTest
    static void testSingleOpportunityMarkedClosedWon() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Opportunity opp = new Opportunity(
            Name = 'Test Deal',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount = 100000
        );
        insert opp;

        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();

        Account updatedAcc = [
            SELECT Total_Won_Amount__c, Total_Won_Deals__c
            FROM Account WHERE Id = :acc.Id
        ];
        System.assertEquals(100000, updatedAcc.Total_Won_Amount__c, 'Total amount should match the single closed won deal');
        System.assertEquals(1, updatedAcc.Total_Won_Deals__c, 'Deal count should be 1');
    }

    @isTest
    static void testMultipleOpportunitiesRollUpCorrectly() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opps.add(new Opportunity(
                Name = 'Deal ' + i,
                AccountId = acc.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 50000
            ));
        }

        Test.startTest();
        insert opps;
        Test.stopTest();

        Account updatedAcc = [
            SELECT Total_Won_Amount__c, Total_Won_Deals__c
            FROM Account WHERE Id = :acc.Id
        ];
        System.assertEquals(250000, updatedAcc.Total_Won_Amount__c);
        System.assertEquals(5, updatedAcc.Total_Won_Deals__c);
    }

    @isTest
    static void testStageMovedAwayFromClosedWonReducesTotal() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Opportunity opp = new Opportunity(
            Name = 'Test Deal',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 75000
        );
        insert opp;

        Test.startTest();
        opp.StageName = 'Closed Lost'; // deal reversed
        update opp;
        Test.stopTest();

        Account updatedAcc = [
            SELECT Total_Won_Amount__c, Total_Won_Deals__c
            FROM Account WHERE Id = :acc.Id
        ];
        System.assertEquals(0, updatedAcc.Total_Won_Amount__c, 'Total should drop back to 0');
        System.assertEquals(0, updatedAcc.Total_Won_Deals__c);
    }

    @isTest
    static void testBulk200OpportunitiesInsert() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opps.add(new Opportunity(
                Name = 'Bulk Deal ' + i,
                AccountId = acc.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 1000
            ));
        }

        Test.startTest();
        insert opps; // this is the real proof the trigger is bulk-safe
        Test.stopTest();

        Account updatedAcc = [
            SELECT Total_Won_Amount__c, Total_Won_Deals__c
            FROM Account WHERE Id = :acc.Id
        ];
        System.assertEquals(200000, updatedAcc.Total_Won_Amount__c);
        System.assertEquals(200, updatedAcc.Total_Won_Deals__c);
    }
}