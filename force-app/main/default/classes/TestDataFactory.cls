public with sharing class TestDataFactory {

    public static List<Account> createAccounts(Integer numOfAccs, Boolean isInsert){

        List<Account> accsToInsert = new List<Account>();

        for(Integer i = 0; i<numOfAccs; i++){
            Account acc = new Account(
                Name = 'TestAccount ' + i
            );
            accsToInsert.add(acc);
        }

        if(isInsert){
            insert accsToInsert;
        }
        
        return accsToInsert;

    }

}
