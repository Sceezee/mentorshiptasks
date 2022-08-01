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

    public static void sendEmailMessageWithDeletedOpportunities(
        Map<Account, List<Opportunity>> accountWithRelatedOpportunities,
        Opportunity currentOpp
    ) {
        List<Messaging.Email> emailList = new List<Messaging.Email>();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
        message.setSubject('Deleting an Account');

        message.setPlainTextBody(
            mailBodyGenerator(accountWithRelatedOpportunities, currentOpp)
        );
        emailList.add(message);

        Messaging.sendEmail(emailList);
    }

    public static String mailBodyGenerator(
        Map<Account, List<Opportunity>> accountWithRelatedOpportunities,
        Opportunity currentOpp
    ) {
        String mailBody;

        Integer lineNumber = 1;

        mailBody =
            'Hi ' +
            UserInfo.getFirstName() +
            ', \n \n' +
            'Due to deletion of Account ' +
            currentOpp.Account.Name +
            ' all next related Opportunities were deleted as well: \n \n';

        for (
            Integer i = 0;
            i < accountWithRelatedOpportunities.get(currentOpp.Account).size();
            i++
        ) {
            mailBody +=
                lineNumber +
                '. ' +
                accountWithRelatedOpportunities.get(currentOpp.Account)[i].Id +
                ',' +
                accountWithRelatedOpportunities.get(currentOpp.Account)[i]
                    .Name +
                ',' +
                accountWithRelatedOpportunities.get(currentOpp.Account)[i]
                    .Amount +
                '\n';
            lineNumber++;
        }

        mailBody += '\n\n' + 'Best regards,' + '\n\n' + 'Red Tag Service Team.';

        return mailBody;
    }

    public static void beforeDeleteInstructions(List<Account> deletedAccs) {
        List<Opportunity> oppsToDelete = [
            SELECT Id, Name, Amount, AccountId, Account.Name
            FROM Opportunity
            WHERE AccountId IN :deletedAccs
            ORDER BY AccountId ASC
        ];

        Map<Account, List<Opportunity>> accountWithRelatedOpportunities = new Map<Account, List<Opportunity>>();

        List<Opportunity> relatedOpportunitiesToAccount = new List<Opportunity>();

        for (Integer i = 0; i < oppsToDelete.size(); i++) {
            Opportunity currentOpp = oppsToDelete[i];

            if (
                i != 0 &&
                oppsToDelete[i - 1].accountId != currentOpp.accountId
            ) {
                accountWithRelatedOpportunities.put(
                    oppsToDelete[i - 1].Account,
                    relatedOpportunitiesToAccount
                );

                sendEmailMessageWithDeletedOpportunities(
                    accountWithRelatedOpportunities,
                    oppsToDelete[i - 1]
                );

                relatedOpportunitiesToAccount.clear();
            }

            relatedOpportunitiesToAccount.add(currentOpp);
        }

        accountWithRelatedOpportunities.put(
            oppsToDelete[(oppsToDelete.size() - 1)].Account,
            relatedOpportunitiesToAccount
        );
        sendEmailMessageWithDeletedOpportunities(
            accountWithRelatedOpportunities,
            oppsToDelete[(oppsToDelete.size() - 1)]
        );
        relatedOpportunitiesToAccount.clear();

        if (!oppsToDelete.isEmpty()) {
            delete oppsToDelete;
        }
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
