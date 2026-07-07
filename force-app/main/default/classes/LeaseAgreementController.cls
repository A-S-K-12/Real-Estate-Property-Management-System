public with sharing class LeaseAgreementController {

    @AuraEnabled(cacheable=true)
    public static LeaseAgreementDTO getLeaseAgreement(
        Id leaseAgreementId
    ) {
        return LeaseAgreementService.getLeaseAgreement(
            leaseAgreementId
        );
    }

    @AuraEnabled
    public static void savePdf(
        Id leaseAgreementId,
        String fileName,
        String base64Pdf
    ) {
        LeaseAgreementService.savePdf(
            leaseAgreementId,
            fileName,
            base64Pdf
        );
    }


    @AuraEnabled
    public static void sendPdfToTenant(
        Id leaseAgreementId
    ) {

        if (leaseAgreementId == null) {

            throw new AuraHandledException(
                'Lease Agreement Id is required.'
            );

        }

        LeaseAgreementService.sendPdfToTenant(
            leaseAgreementId
        );

    }

    public class LeaseAgreementDTO {

        @AuraEnabled
        public Id id { get; set; }

        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public Id propertyId { get; set; }

        @AuraEnabled
        public String propertyName { get; set; }

        @AuraEnabled
        public Id tenantId { get; set; }

        @AuraEnabled
        public String tenantName { get; set; }

        @AuraEnabled
        public Decimal monthlyRent { get; set; }

        @AuraEnabled
        public String terms { get; set; }

        @AuraEnabled
        public Date startDate { get; set; }

        @AuraEnabled
        public Date endDate { get; set; }

        @AuraEnabled
        public String status { get; set; }

        @AuraEnabled
        public Boolean pdfGenerated { get; set; }

        @AuraEnabled
        public Boolean emailSent { get; set; }

        public LeaseAgreementDTO() {
        }

        public LeaseAgreementDTO(
            Lease_Agreement__c agreement
        ) {

            id = agreement.Id;
            name = agreement.Name;

            propertyId = agreement.Property__c;

            if (agreement.Property__r != null) {

                propertyName =
                    agreement.Property__r.Name;

            }

            tenantId = agreement.Tenant__c;

            if (agreement.Tenant__r != null) {

                tenantName =
                    agreement.Tenant__r.Name;

            }

            monthlyRent =
                agreement.Monthly_Rent__c;

            terms =
                agreement.Terms__c;

            startDate =
                agreement.Start_Date__c;

            endDate =
                agreement.End_Date__c;

            status =
                agreement.Status__c;

            pdfGenerated =
                agreement.PDF_Generated__c;

            emailSent =
                agreement.Email_Sent__c;

        }

    }


    public class LeaseAgreementSearchRequest {

        @AuraEnabled
        public Integer pageNumber { get; set; }

        @AuraEnabled
        public Integer pageSize { get; set; }

        @AuraEnabled
        public String status { get; set; }

        @AuraEnabled
        public Id propertyId { get; set; }

        @AuraEnabled
        public Id tenantId { get; set; }

        @AuraEnabled
        public Date startDate { get; set; }

        @AuraEnabled
        public Date endDate { get; set; }

        @AuraEnabled
        public String sortBy { get; set; }

        @AuraEnabled
        public String sortDirection { get; set; }

    }

    public class LeaseAgreementSearchResponse {

        @AuraEnabled
        public List<LeaseAgreementDTO> records { get; set; }

        @AuraEnabled
        public Integer totalRecords { get; set; }

        @AuraEnabled
        public Integer totalPages { get; set; }

        @AuraEnabled
        public Integer pageNumber { get; set; }

        @AuraEnabled
        public Integer pageSize { get; set; }

    }

}