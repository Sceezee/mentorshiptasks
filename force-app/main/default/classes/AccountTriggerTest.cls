@isTest
private with sharing class AccountTriggerTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.createAccounts(1, true);
    }
    @isTest private static void afterInsertTest(){
        
        Test.startTest();

        Account acc = [
            SELECT Name, CreatedDate
            FROM Account
            LIMIT 1
        ];

        Opportunity opp = [
            SELECT Name, StageName, CloseDate
            FROM Opportunity
            WHERE AccountId =: acc.Id
            LIMIT 1
        ];

        Test.stopTest();

        System.assertEquals(opp.Name, acc.Name + ' ' + System.today().month() + '.' + System.today().year());
        System.assertEquals(opp.StageName, 'Prospecting');

        System.assertEquals(acc.CreatedDate.addDays(90).day(), opp.CloseDate.day());
        System.assertEquals(acc.CreatedDate.addDays(90).month(), opp.CloseDate.month());
        System.assertEquals(acc.CreatedDate.addDays(90).year(), opp.CloseDate.year());
        
    }
    @isTest private static void afterUpdateTest(){
        
        Test.startTest();

        Account acc = [
            SELECT Name, CreatedDate
            FROM Account
            LIMIT 1
        ];

        acc.Name = 'AfterUpdate';
        update acc;

        Opportunity opp = [
            SELECT Name
            FROM Opportunity
            WHERE AccountId =: acc.Id
            LIMIT 1
        ];

        Test.stopTest();

        System.assertEquals(opp.Name, acc.Name + ' ' + acc.CreatedDate.month() + '.' + acc.CreatedDate.year());
        
    }
    @isTest private static void beforeDeleteTest(){

        Test.startTest();

        Account acc = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        delete acc;

        List<Opportunity> opps = [
            SELECT Id
            FROM Opportunity
            WHERE AccountId =: acc.Id
        ];

        System.assertEquals(true, opps.isEmpty());
        System.assertEquals(1, Limits.getEmailInvocations());

        Test.stopTest();

    }


}
