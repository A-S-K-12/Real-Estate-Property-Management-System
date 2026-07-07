public with sharing class LeaseExpirySchedulerJob {

    public static void scheduleJob() {

        String cronExpression =
            '0 0 8 * * ?';

        System.schedule(
            'Lease Expiry Reminder',
            cronExpression,
            new LeaseExpiryScheduler()
        );

    }

}