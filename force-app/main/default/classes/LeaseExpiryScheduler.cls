global with sharing class LeaseExpiryScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Date today = Date.today();

        List<Lease_Agreement__c> agreements = [

            SELECT Id,
                   Name,
                   End_Date__c,
                   Property__r.Name,
                    Tenant__r.Name,
                   Tenant__r.Email__c

            FROM Lease_Agreement__c

            WHERE End_Date__c = :today.addDays(30)
               OR End_Date__c = :today.addDays(1)

        ];

        if (agreements.isEmpty()) {
            return;
        }

        List<Messaging.SingleEmailMessage> emails =
            new List<Messaging.SingleEmailMessage>();

        for (Lease_Agreement__c agreement : agreements) {

    // Skip if no tenant email
    if (agreement.Tenant__r == null ||
        String.isBlank(agreement.Tenant__r.Email__c)) {
        continue;
    }

    Messaging.SingleEmailMessage email =
        new Messaging.SingleEmailMessage();

    email.setToAddresses(
        new String[] {
            agreement.Tenant__r.Email__c
        }
    );

    email.setSubject(
        'Lease Agreement Expiry Reminder'
    );

    Integer daysRemaining =
        today.daysBetween(agreement.End_Date__c);

    String body =
        'Dear ' +
        agreement.Tenant__r.Name +
        ',\n\n' +
        'Your lease agreement for "' +
        agreement.Property__r.Name +
        '" will expire in ' +
        daysRemaining +
        ' day(s).\n\n' +
        'Expiry Date: ' +
        agreement.End_Date__c +
        '\n\nPlease contact us if you wish to renew your lease.\n\n' +
        'Thank you.';

    email.setPlainTextBody(body);

    emails.add(email);
}

        if (!emails.isEmpty()) {

            Messaging.sendEmail(emails);

        }

    }

}