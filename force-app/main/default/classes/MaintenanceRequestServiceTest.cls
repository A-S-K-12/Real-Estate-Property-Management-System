@IsTest
public class MaintenanceRequestServiceTest {

    @TestSetup
    static void setupData() {

        Property__c property = TestDataFactory.createProperty(true);
        Vendor__c vendorA = TestDataFactory.createVendor(false);
        vendorA.Name = 'Vendor A';
        insert vendorA;

        Vendor__c vendorB = TestDataFactory.createVendor(false);
        vendorB.Name = 'Vendor B';
        insert vendorB;

        Vendor__c vendorC = TestDataFactory.createVendor(false);
        vendorC.Name = 'Vendor C';
        insert vendorC;

        List<Maintenance_Request__c> existing = new List<Maintenance_Request__c>();

        Maintenance_Request__c r1 = TestDataFactory.createMaintenanceRequest(property.Id, vendorA.Id, false);
        r1.Status__c = Constants.MAINTENANCE_OPEN;
        existing.add(r1);

        Maintenance_Request__c r2 = TestDataFactory.createMaintenanceRequest(property.Id, vendorA.Id, false);
        r2.Status__c = Constants.MAINTENANCE_IN_PROGRESS;
        existing.add(r2);

        Maintenance_Request__c r3 = TestDataFactory.createMaintenanceRequest(property.Id, vendorB.Id, false);
        r3.Status__c = Constants.MAINTENANCE_OPEN;
        existing.add(r3);

        insert existing;
    }


    @IsTest
    static void testServiceDirectAssignment() {

        Property__c property = [SELECT Id FROM Property__c LIMIT 1];

        List<Maintenance_Request__c> requests = new List<Maintenance_Request__c>();

        for (Integer i = 0; i < 5; i++) {
            requests.add(
                TestDataFactory.createMaintenanceRequest(property.Id, null, false)
            );
        }

        Test.startTest();
        MaintenanceRequestService.assignVendor(requests);
        insert requests;
        Test.stopTest();
    }


    @IsTest
    static void testWorkloadDistribution() {

        Property__c property = [SELECT Id FROM Property__c LIMIT 1];

        List<Maintenance_Request__c> requests = new List<Maintenance_Request__c>();

        for (Integer i = 0; i < 12; i++) {
            requests.add(
                TestDataFactory.createMaintenanceRequest(property.Id, null, false)
            );
        }

        Test.startTest();
        MaintenanceRequestService.assignVendor(requests);
        insert requests;
        Test.stopTest();

        Map<Id, Integer> distribution = new Map<Id, Integer>();

        for (Maintenance_Request__c r : requests) {
            if (!distribution.containsKey(r.Vendor__c)) {
                distribution.put(r.Vendor__c, 0);
            }
            distribution.put(r.Vendor__c, distribution.get(r.Vendor__c) + 1);
        }
    }

    @IsTest
    static void testExistingWorkloadImpact() {

        Property__c property = [SELECT Id FROM Property__c LIMIT 1];

        Maintenance_Request__c req = TestDataFactory.createMaintenanceRequest(
            property.Id,
            null,
            false
        );

        List<Maintenance_Request__c> reqList = new List<Maintenance_Request__c>{req};

        Test.startTest();
        MaintenanceRequestService.assignVendor(reqList);
        insert reqList;
        Test.stopTest();

        Maintenance_Request__c inserted = [
            SELECT Vendor__c
            FROM Maintenance_Request__c
            WHERE Id = :req.Id
        ];
    }

    @IsTest
    static void testNoVendorScenario() {

        delete [SELECT Id FROM Vendor__c];

        Property__c property = TestDataFactory.createProperty(true);

        Maintenance_Request__c req = TestDataFactory.createMaintenanceRequest(
            property.Id,
            null,
            false
        );

        Test.startTest();
        MaintenanceRequestService.assignVendor(new List<Maintenance_Request__c>{req});
        insert req;
        Test.stopTest();
    }
}