@IsTest
private class LeaseAgreementServiceTest {

    private static Lease_Agreement__c createLease() {

        Property__c property = TestDataFactory.createProperty(true);
        Tenant__c tenant = TestDataFactory.createTenant(true);
        Lease_Agreement__c lease =TestDataFactory.createLease(
                property.Id,
                tenant.Id,
                true
            );
        lease.Tenant__c = tenant.Id;
        update lease;
        return lease;
    }

    private static String getPdfBase64() {
        return EncodingUtil.base64Encode(
            Blob.valueOf('Dummy PDF')
        );
    }

    @IsTest
    static void testGetLeaseAgreement() {
        Lease_Agreement__c lease = createLease();
        Test.startTest();
        LeaseAgreementController.LeaseAgreementDTO dto =
            LeaseAgreementService.getLeaseAgreement(
                lease.Id
            );
        Test.stopTest();
        System.assertEquals(
            lease.Id,
            dto.id
        );
        System.assertEquals(
            lease.Name,
            dto.name
        );
    }

    @IsTest
    static void testGetLeaseAgreement_NullId() {
        try {
            LeaseAgreementService.getLeaseAgreement(null);
            System.assert(false);
        } catch (AuraHandledException ex) {
        }
    }

    @IsTest
    static void testSavePdf() {
        Lease_Agreement__c lease = createLease();
        Test.startTest();
        LeaseAgreementService.savePdf(
            lease.Id,
            'Lease.pdf',
            getPdfBase64()
        );
        Test.stopTest();
        System.assertEquals(1,
            [
                SELECT COUNT()
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :lease.Id
            ]
        );
    }

    @IsTest
    static void testMarkPdfGenerated() {
        Lease_Agreement__c lease = createLease();
        Test.startTest();
        LeaseAgreementService.markPdfGenerated(
            lease.Id
        );
        Test.stopTest();
        lease = [
            SELECT PDF_Generated__c
            FROM Lease_Agreement__c
            WHERE Id = :lease.Id
        ];
        System.assert(
            lease.PDF_Generated__c
        );
    }

    @IsTest
    static void testSendPdfToTenant() {
        Lease_Agreement__c lease = createLease();
        LeaseAgreementService.savePdf(
            lease.Id,
            'Lease.pdf',
            getPdfBase64()
        );
        Test.startTest();
        LeaseAgreementService.sendPdfToTenant(
            lease.Id
        );
        Test.stopTest();
        lease = [
            SELECT Email_Sent__c
            FROM Lease_Agreement__c
            WHERE Id = :lease.Id
        ];
        System.assert(
            lease.Email_Sent__c
        );
    }

    @IsTest
    static void testSendAgreementEmail() {
        Lease_Agreement__c lease = createLease();
        LeaseAgreementService.savePdf(
            lease.Id,
            'Lease.pdf',
            getPdfBase64()
        );
        Test.startTest();
        LeaseAgreementService.sendAgreementEmail(
            lease.Id
        );
        Test.stopTest();
        lease = [
            SELECT Email_Sent__c
            FROM Lease_Agreement__c
            WHERE Id = :lease.Id
        ];
        System.assertEquals(
            true,
            lease.Email_Sent__c
        );
    }

    @IsTest
    static void testSearchLeaseAgreements() {
        createLease();
        LeaseAgreementController.LeaseAgreementSearchRequest req =
            new LeaseAgreementController.LeaseAgreementSearchRequest();
        req.pageNumber = 1;
        req.pageSize = 10;
        req.sortBy = 'Name';
        req.sortDirection = 'ASC';
        Test.startTest();
        LeaseAgreementController.LeaseAgreementSearchResponse response =LeaseAgreementService.getLeaseAgreements(req);
        Test.stopTest();
        System.assertEquals(
            1,
            response.records.size()
        );
        System.assertEquals(
            1,
            response.totalRecords
        );
    }

    @IsTest
    static void testSearchNullRequest() {
        Test.startTest();
        LeaseAgreementController.LeaseAgreementSearchResponse response =
            LeaseAgreementService.getLeaseAgreements(
                null
            );
        Test.stopTest();
        System.assertNotEquals(
            null,
            response
        );
    }

    @IsTest
    static void testMaximumPageLimit() {
        LeaseAgreementController.LeaseAgreementSearchRequest req =
        new LeaseAgreementController.LeaseAgreementSearchRequest();
        req.pageNumber = 100;
        req.pageSize = 50;
        try {
            LeaseAgreementService.getLeaseAgreements(
                req
            );
            System.assert(false);
        } catch (AuraHandledException ex) {
        }
    }

    @IsTest
    static void testSavePdfValidation() {
        Lease_Agreement__c lease = createLease();
        try {
            LeaseAgreementService.savePdf(
                lease.Id,
                'Lease.pdf',
                null
            );
            System.assert(false);
        } catch (AuraHandledException ex) {
        }
    }

    @IsTest
    static void testSendPdfWithoutPdf() {
        Lease_Agreement__c lease = createLease();
        try {
            LeaseAgreementService.sendPdfToTenant(lease.Id);
            System.assert(false);
        } catch (AuraHandledException ex) {
        }
    }
}