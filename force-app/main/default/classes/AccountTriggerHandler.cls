public with sharing class AccountTriggerHandler extends TriggerHandler {

    public override void beforeDelete(){

        List<Account> deletedAccs = new List<Account>();

        for(Account acc:(List<Account>)Trigger.Old){
            deletedAccs.add(acc);
        }

        List<Opportunity> oppsToDelete = new List<Opportunity>([SELECT Id, Name, Amount, AccountId, Account.Name FROM Opportunity WHERE AccountId IN:deletedAccs]);

        oppsToDelete.sort();
    
        List<Messaging.Email> emailList = new List<Messaging.Email>();

        String mailBody;

        Integer i = 1;
        Integer border = oppsToDelete.size();

        Id switcher = oppsToDelete[0].AccountId;


        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[] {UserInfo.getUserEmail()});
        message.setSubject('Deleting an Account');

        mailBody = 'Hi ' + UserInfo.getFirstName() + ', \n \n' +
        'Due to deletion of Account ' +  deletedAccs[0].Name + ' all next related Opportunities were deleted as well: \n \n';
   
        for(Opportunity opp:oppsToDelete){

            if(border!=0){


                if(opp.AccountId == switcher){

                    mailBody += i + '. ' + opp.Id + ',' + opp.Name + ',' + opp.Amount + '\n';
                    i++;

            
                } else {

                    mailBody += '\n\n' + 'Best regards,' + '\n\n' + 'Red Tag Service Team.';

                    message.setPlainTextBody(mailBody);
                    emailList.add(message);

                    mailBody = '';
                    i = 1;

                    message = new Messaging.SingleEmailMessage();
                    message.setToAddresses(new String[] {UserInfo.getUserEmail()});
                    message.setSubject('Deleting an Account');

                    mailBody = 'Hi ' + UserInfo.getFirstName() + ', \n \n' +
                    'Due to deletion of Account ' +  opp.Account.Name + ' all next related Opportunities were deleted as well: \n \n';


                }

                switcher = opp.AccountId;
                border--;


            } else {

                break;

            }

        }

        mailBody += '\n\n' + 'Best regards,' + '\n\n' + 'Red Tag Service Team.';

        message.setPlainTextBody(mailBody);
        emailList.add(message);


        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }

        if(!oppsToDelete.isEmpty()){
            delete oppsToDelete;
        }
    }

    public override void afterInsert(){

        Id id;
        String oppName;
        Date closeDate = System.today().addDays(90);
    
        List<Opportunity> oppsToInsert = new List<Opportunity>();
                
        for(Account acc:(List<Account>)Trigger.New){
            id = acc.Id;
            oppName = acc.Name;

            oppName += ' ' + System.today().month() + '.' + System.today().year();

            Opportunity opp = new Opportunity(Name = oppName, AccountId = id, StageName = 'Prospecting', CloseDate = closeDate);
            oppsToInsert.add(opp);

            oppName = '';
        }

        if(!oppsToInsert.isEmpty()){
            insert oppsToInsert;
        }

    }

    public override void afterUpdate(){

        List<Account> newAccs = new List<Account>();

        for(Account acc:(List<Account>)Trigger.New){
            newAccs.add(acc);
        }

        List<Opportunity> oppsToCheck = new List<Opportunity>([SELECT Name, AccountId, Account.Name FROM Opportunity WHERE AccountId IN:newAccs]);
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for(Opportunity opp:oppsToCheck){
            if(opp.Name != opp.Account.Name + ' ' + System.today().month() + '.' + System.today().year()){
                opp.Name = opp.Account.Name + ' ' + System.today().month() + '.' + System.today().year();
                oppsToUpdate.add(opp);
            }
        }

        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }


        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }

    }

}
