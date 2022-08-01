public with sharing class EmailService {

    public static void sendSingleEmailMessage(String emailSubject, List<String> toEmailAddresses, String mailBody) {
        List<Messaging.Email> emailList = new List<Messaging.Email>();

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(toEmailAddresses);
        message.setSubject(emailSubject);

        message.setPlainTextBody(mailBody);

        emailList.add(message);

        Messaging.sendEmail(emailList);
    }

}
