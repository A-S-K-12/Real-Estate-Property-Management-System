@IsTest
private class LeaseExpirySchedulerTest {

    @IsTest
    static void testLeaseExpiryScheduler() {

        Property__c property =
            TestDataFactory.createProperty(true);

        Tenant__c tenant =
            TestDataFactory.createTenant(true);

        Lease_Agreement__c lease30 =
            TestDataFactory.createLease(
                property.Id,
                tenant.Id,
                false
            );

        lease30.Tenant__c = tenant.Id;
        lease30.End_Date__c = Date.today().addDays(30);

        Lease_Agreement__c lease1 =
            TestDataFactory.createLease(
                property.Id,
                tenant.Id,
                false
            );

        lease1.Name = 'Lease-002';
        lease1.Tenant__c = tenant.Id;
        lease1.End_Date__c = Date.today().addDays(1);

        Lease_Agreement__c leaseOther =
            TestDataFactory.createLease(
                property.Id,
                tenant.Id,
                false
            );

        leaseOther.Name = 'Lease-003';
        leaseOther.Tenant__c = tenant.Id;
        leaseOther.End_Date__c = Date.today().addDays(90);

        insert new List<Lease_Agreement__c>{
            lease30,
            lease1,
            leaseOther
        };

        Test.startTest();

        String cron =
            '0 0 0 1 1 ? 2099';

        System.schedule(
            'LeaseExpirySchedulerTest',
            cron,
            new LeaseExpiryScheduler()
        );

        Test.stopTest();

        System.assertEquals(
            3,
            [
                SELECT COUNT()
                FROM Lease_Agreement__c
            ]
        );
    }

    @IsTest
    static void testSchedulerNoMatchingLeases() {

        Property__c property =
            TestDataFactory.createProperty(true);

        Tenant__c tenant =
            TestDataFactory.createTenant(true);

        Lease_Agreement__c lease =
            TestDataFactory.createLease(
                property.Id,
                tenant.Id,
                false
            );

        lease.Tenant__c = tenant.Id;
        lease.End_Date__c = Date.today().addDays(120);

        insert lease;

        Test.startTest();

        System.schedule(
            'LeaseExpirySchedulerNoMatch',
            '0 0 0 1 1 ? 2099',
            new LeaseExpiryScheduler()
        );

        Test.stopTest();

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Lease_Agreement__c
            ]
        );
    }

}