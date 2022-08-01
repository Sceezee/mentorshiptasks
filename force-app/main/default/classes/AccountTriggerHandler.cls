public with sharing class AccountTriggerHandler extends TriggerHandler {
    public override void beforeDelete() {
        beforeDeleteInstructions(Trigger.Old);
    }

    public override void afterInsert() {
        afterInsertInstructions(Trigger.New);
    }

    public override void afterUpdate() {
        afterUpdateInstructions(Trigger.New);
    }

    public static void beforeDeleteInstructions(List<Account> deletedAccs) {
        List<Opportunity> oppsToDelete = [
            SELECT Id, Name, Amount, AccountId, Account.Name
            FROM Opportunity
            WHERE AccountId IN :deletedAccs
            ORDER BY AccountId ASC
        ];

        String emailSubject = 'Deleting an Account';
        List<String> toEmailAddresses = new List<String>();
        toEmailAddresses.add(UserInfo.getUserEmail());

        Map<Account, List<Opportunity>> accountWithRelatedOpportunities = populateMapWithAccountsAndRelatedOppurtunites(deletedAccs, oppsToDelete);

        List<String> mailBodies = mailBodiesAccountsToOppsGenerator(accountWithRelatedOpportunities);

        for(String mailBody : mailBodies){
            EmailService.sendSingleEmailMessage(emailSubject, toEmailAddresses, mailBody);
        }
        

        if (!oppsToDelete.isEmpty()) {
            delete oppsToDelete;
        }
    }

    public static List<String> mailBodiesAccountsToOppsGenerator(Map<Account, List<Opportunity>> accountWithRelatedOpportunities) {
        
        List<String> mailBodies = new List<String>();

        for(Account key : accountWithRelatedOpportunities.keySet()){

            String mailBody = '';

            mailBody =
                'Hi ' +
                UserInfo.getFirstName() +
                ', \n \n' +
                'Due to deletion of Account ' +
                key.Name +
                ' all next related Opportunities were deleted as well: \n \n';

            Integer lineNumber = 1;

            if(accountWithRelatedOpportunities.get(key).size() != 0){

                for(Opportunity opportunity : accountWithRelatedOpportunities.get(key)){
                    mailBody +=
                        lineNumber +
                        '. ' +
                        opportunity.Id +
                        ',' +
                        opportunity.Name +
                        ',' +
                        opportunity.Amount +
                        '\n';
                        
                    lineNumber++;
                }
            }

            mailBody += '\n\n' + 'Best regards,' + '\n\n' + 'Red Tag Service Team.';
            mailBodies.add(mailBody);

        }

        return mailBodies;

    }

    public static Map<Account, List<Opportunity>> populateMapWithAccountsAndRelatedOppurtunites(List<Account> accounts, List<Opportunity> opportunities) {
        
        Map<Account,List<Opportunity>> accountWithRelatedOpportunities = new Map<Account, List<Opportunity>>();
        
        for(Account account : accounts){

            List<Opportunity> relatedOpportunitiesToAccount = new List<Opportunity>();

            for(Opportunity opportunity : opportunities){

                if(opportunity.AccountId == account.Id){
                    relatedOpportunitiesToAccount.add(opportunity);
                }

            }

            accountWithRelatedOpportunities.put(account, relatedOpportunitiesToAccount);

        }

        return accountWithRelatedOpportunities;

    }



    public static void afterInsertInstructions(List<Account> newAccounts) {
        Id accountId;
        String oppName;
        Date closeDate = System.today().addDays(90);

        List<Opportunity> oppsToInsert = new List<Opportunity>();

        for (Account acc : newAccounts) {
            accountId = acc.Id;

            oppName =
                acc.Name +
                ' ' +
                System.today().month() +
                '.' +
                System.today().year();

            Opportunity opp = new Opportunity(
                Name = oppName,
                AccountId = accountId,
                StageName = 'Prospecting',
                CloseDate = closeDate
            );
            oppsToInsert.add(opp);
        }

        if (!oppsToInsert.isEmpty()) {
            insert oppsToInsert;
        }
    }

    public static void afterUpdateInstructions(List<Account> newAccounts) {
        List<Opportunity> oppsToCheck = [
            SELECT Name, AccountId, Account.Name
            FROM Opportunity
            WHERE AccountId IN :newAccounts
        ];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Opportunity opp : oppsToCheck) {
            if (
                opp.Name !=
                opp.Account.Name + ' ' + System.today().month() + '.' +
                System.today().year()
            ) {
                opp.Name =
                    opp.Account.Name +
                    ' ' +
                    System.today().month() +
                    '.' +
                    System.today().year();
                oppsToUpdate.add(opp);
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}
