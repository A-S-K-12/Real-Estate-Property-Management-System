@IsTest
public class TestDataFactory {

    public static Property__c createProperty(Boolean doInsert) {

        Property__c property = new Property__c(
            Address__c = '123 Main Street',
            City__c = 'Bangalore',
            State__c = 'Karnataka',
            Postal_Code__c = '560001',
            Country__c = 'India',
            Availability_Status__c = 'Available',
            Furnishing_Status__c = 'Furnished',
            Monthly_Rent__c = 25000,
            Property_Type__c ='Residential',
            Description__c = 'Test Property'
        );

        if (doInsert) {
            insert property;
        }

        return property;
    }


    public static Vendor__c createVendor(Boolean doInsert) {

        Vendor__c vendor = new Vendor__c(
            Name = 'ABC Maintenance',
            Phone__c = '9999999999',
            Email__c = 'vendor@test.com',
            IsActive__c = true
        );

        if (doInsert) {
            insert vendor;
        }

        return vendor;
    }
    
    public static Tenant__c createTenant(Boolean doInsert) {

        Tenant__c tenant = new Tenant__c(
            Name = 'ABC Maintenance',
            Phone__c = '9999999999',
            Email__c = 'vendor@test.com'
        );

        if (doInsert) {
            insert tenant;
        }

        return tenant;
    }

    public static Lease_Agreement__c createLease(
        Id propertyId,
        Id tenantId,
        Boolean doInsert
    ) {

        Lease_Agreement__c lease = new Lease_Agreement__c(
            Name = 'Lease-001',
            Property__c = propertyId,
            Monthly_Rent__c = 25000,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addYears(1),
            Terms__c = 'Standard Lease Terms',
            Status__c = 'Draft'
        );

        if (doInsert) {
            insert lease;
        }

        return lease;
    }

    public static Maintenance_Request__c createMaintenanceRequest(
        Id propertyId,
        Id vendorId,
        Boolean doInsert
    ) {

        Maintenance_Request__c request = new Maintenance_Request__c(
            Property__c = propertyId,
            Vendor__c = vendorId,
            Status__c = 'Open',
            Description__c = 'Water leakage in kitchen'
        );

        if (doInsert) {
            insert request;
        }

        return request;
    }

}