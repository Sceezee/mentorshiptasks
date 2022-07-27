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

        List<Messaging.Email> emailList = new List<Messaging.Email>();

        String mailBody;

        Integer lineNumber = 1;

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
        message.setSubject('Deleting an Account');

        mailBody =
            'Hi ' +
            UserInfo.getFirstName() +
            ', \n \n' +
            'Due to deletion of Account ' +
            oppsToDelete[0].Account.Name +
            ' all next related Opportunities were deleted as well: \n \n';

        for (Integer i = 0; i < oppsToDelete.size(); i++) {
            Opportunity currentOpp = oppsToDelete[i];

            if (
                i != 0 &&
                oppsToDelete[i - 1].accountId != currentOpp.accountId
            ) {
                mailBody +=
                    '\n\n' +
                    'Best regards,' +
                    '\n\n' +
                    'Red Tag Service Team.';

                message.setPlainTextBody(mailBody);
                emailList.add(message);

                mailBody = '';
                lineNumber = 1;

                message = new Messaging.SingleEmailMessage();
                message.setToAddresses(
                    new List<String>{ UserInfo.getUserEmail() }
                );
                message.setSubject('Deleting an Account');

                mailBody =
                    'Hi ' +
                    UserInfo.getFirstName() +
                    ', \n \n' +
                    'Due to deletion of Account ' +
                    currentOpp.Account.Name +
                    ' all next related Opportunities were deleted as well: \n \n';
            }

            mailBody +=
                lineNumber +
                '. ' +
                currentOpp.Id +
                ',' +
                currentOpp.Name +
                ',' +
                currentOpp.Amount +
                '\n';
            lineNumber++;
        }

        mailBody += '\n\n' + 'Best regards,' + '\n\n' + 'Red Tag Service Team.';

        message.setPlainTextBody(mailBody);
        emailList.add(message);

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }

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
