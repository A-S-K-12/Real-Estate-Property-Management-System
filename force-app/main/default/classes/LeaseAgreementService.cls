public with sharing class LeaseAgreementService {

    public static LeaseAgreementController.LeaseAgreementDTO
    getLeaseAgreement(
        Id leaseAgreementId
    ) {

        if (leaseAgreementId == null) {

            throw new AuraHandledException(
                'Lease Agreement Id is required.'
            );

        }

        try {

            Lease_Agreement__c agreement = [

                SELECT
                    Id,
                    Name,
                    Property__c,
                    Property__r.Name,
                    Tenant__c,
                    Tenant__r.Name,
                    Monthly_Rent__c,
                    Terms__c,
                    Start_Date__c,
                    End_Date__c,
                    Status__c,
                    PDF_Generated__c,
                    Email_Sent__c

                FROM Lease_Agreement__c

                WHERE Id = :leaseAgreementId

                LIMIT 1

            ];

            return new LeaseAgreementController.LeaseAgreementDTO(agreement);

        }
        catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to retrieve Lease Agreement. ' +
                ex.getMessage()
            );

        }

    }


    public static void savePdf(

        Id leaseAgreementId,

        String fileName,

        String base64Pdf

    ) {

        if (leaseAgreementId == null) {

            throw new AuraHandledException(
                'Lease Agreement Id is required.'
            );

        }

        if (String.isBlank(base64Pdf)) {

            throw new AuraHandledException(
                'PDF data is missing.'
            );

        }

        ContentVersion version =
            new ContentVersion();

        version.Title =
            fileName.replace('.pdf', '');

        version.PathOnClient =
            fileName;

        version.VersionData =
            EncodingUtil.base64Decode(base64Pdf);

        insert version;

        version = [

            SELECT
                Id,
                ContentDocumentId

            FROM ContentVersion

            WHERE Id = :version.Id

        ];

        ContentDocumentLink link =
            new ContentDocumentLink(

                LinkedEntityId = leaseAgreementId,

                ContentDocumentId =
                    version.ContentDocumentId,

                ShareType = 'V',

                Visibility = 'AllUsers'

            );

        insert link;

    }

    public static void sendPdfToTenant(
        Id leaseAgreementId
    ) {

        if (leaseAgreementId == null) {

            throw new AuraHandledException(
                'Lease Agreement Id is required.'
            );

        }

        try {

            Lease_Agreement__c agreement = [

                SELECT
                    Id,
                    Name,
                    Tenant__c,
                    Tenant__r.Name,
                    Tenant__r.Email__c

                FROM Lease_Agreement__c

                WHERE Id = :leaseAgreementId

                LIMIT 1

            ];

            if (
                agreement.Tenant__r == null ||
                String.isBlank(
                    agreement.Tenant__r.Email__c
                )
            ) {

                throw new AuraHandledException(
                    'Tenant email is missing.'
                );

            }

            List<ContentDocumentLink> links = [

                SELECT
                    ContentDocumentId

                FROM ContentDocumentLink

                WHERE LinkedEntityId = :leaseAgreementId

                ORDER BY SystemModstamp DESC

                LIMIT 1

            ];

            if (links.isEmpty()) {

                throw new AuraHandledException(
                    'No PDF has been generated.'
                );

            }

            ContentVersion version = [

                SELECT
                    Id,
                    Title,
                    FileExtension,
                    VersionData

                FROM ContentVersion

                WHERE
                    ContentDocumentId =
                        :links[0].ContentDocumentId

                AND
                    IsLatest = true

                LIMIT 1

            ];

            Messaging.EmailFileAttachment attachment =
                new Messaging.EmailFileAttachment();

            attachment.setFileName(
                version.Title +
                '.' +
                version.FileExtension
            );

            attachment.setBody(
                version.VersionData
            );

            Messaging.SingleEmailMessage email =
                new Messaging.SingleEmailMessage();

            email.setToAddresses(
                new String[]{
                    agreement.Tenant__r.Email__c
                }
            );

            email.setSubject(
                'Lease Agreement - ' +
                agreement.Name
            );

            email.setPlainTextBody(
                'Dear ' +
                agreement.Tenant__r.Name +
                ',\n\n' +
                'Please find your Lease Agreement attached.' +
                '\n\nRegards,\nProperty Management'
            );

            email.setFileAttachments(
                new Messaging.EmailFileAttachment[]{
                    attachment
                }
            );

            Messaging.sendEmail(
                new Messaging.SingleEmailMessage[]{
                    email
                }
            );

            agreement.Email_Sent__c = true;

            update agreement;

        }
        catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to send PDF. ' +
                ex.getMessage()
            );

        }

    }


    public static void markPdfGenerated(
        Id leaseAgreementId
    ) {

        if (leaseAgreementId == null) {

            throw new AuraHandledException(
                'Lease Agreement Id is required.'
            );

        }

        update new Lease_Agreement__c(

            Id = leaseAgreementId,

            PDF_Generated__c = true

        );

    }


    public static void sendAgreementEmail(
        Id leaseAgreementId
    ) {

        sendPdfToTenant(
            leaseAgreementId
        );

    }


    private static Lease_Agreement__c
    buildLeaseAgreement(
        LeaseAgreementController.LeaseAgreementDTO dto
    ) {

        Lease_Agreement__c agreement =
            new Lease_Agreement__c();

        mapDTO(
            agreement,
            dto
        );

        return agreement;

    }

    private static void mapDTO(

        Lease_Agreement__c agreement,

        LeaseAgreementController.LeaseAgreementDTO dto

    ) {

        agreement.Name = dto.name;

        agreement.Property__c =
            dto.propertyId;

        agreement.Tenant__c =
            dto.tenantId;

        agreement.Monthly_Rent__c =
            dto.monthlyRent;

        agreement.Terms__c =
            dto.terms;

        agreement.Start_Date__c =
            dto.startDate;

        agreement.End_Date__c =
            dto.endDate;

        agreement.Status__c =
            dto.status;

    }

    private static void validateLeaseAgreement(
        LeaseAgreementController.LeaseAgreementDTO dto
    ) {

        if (dto == null) {

            throw new AuraHandledException(
                'Lease Agreement data is required.'
            );

        }

        if (dto.propertyId == null) {

            throw new AuraHandledException(
                'Property is required.'
            );

        }

        if (dto.tenantId == null) {

            throw new AuraHandledException(
                'Tenant is required.'
            );

        }

        if (dto.monthlyRent == null ||
            dto.monthlyRent <= 0) {

            throw new AuraHandledException(
                'Monthly Rent must be greater than zero.'
            );

        }

        if (String.isBlank(dto.terms)) {

            throw new AuraHandledException(
                'Terms are required.'
            );

        }

        if (dto.startDate == null) {

            throw new AuraHandledException(
                'Start Date is required.'
            );

        }

        if (dto.endDate == null) {

            throw new AuraHandledException(
                'End Date is required.'
            );

        }

        if (dto.endDate <= dto.startDate) {

            throw new AuraHandledException(
                'End Date must be after Start Date.'
            );

        }

    }
    
    public static LeaseAgreementController.LeaseAgreementSearchResponse
    getLeaseAgreements(
        LeaseAgreementController.LeaseAgreementSearchRequest request
    ) {

        if (request == null) {

            request =
                new LeaseAgreementController.LeaseAgreementSearchRequest();

        }

        Integer pageSize =
            (request.pageSize == null ||
             request.pageSize <= 0)
            ? 25
            : request.pageSize;

        pageSize = Math.min(
            pageSize,
            100
        );

        Integer pageNumber =
            (request.pageNumber == null ||
             request.pageNumber <= 0)
            ? 1
            : request.pageNumber;

        Integer offsetRows =
            (pageNumber - 1) * pageSize;

        if (offsetRows > 2000) {

            throw new AuraHandledException(
                'Maximum page limit exceeded.'
            );

        }

        String whereClause =
            buildWhereClause(request);

        String orderBy =
            buildOrderBy(request);

        Integer totalRecords =
            Database.countQuery(

                'SELECT COUNT() ' +
                'FROM Lease_Agreement__c ' +
                whereClause

            );

        String query =

            'SELECT ' +
            'Id,' +
            'Name,' +
            'Property__c,' +
            'Property__r.Name,' +
            'Tenant__c,' +
            'Tenant__r.Name,' +
            'Monthly_Rent__c,' +
            'Terms__c,' +
            'Start_Date__c,' +
            'End_Date__c,' +
            'Status__c,' +
            'PDF_Generated__c,' +
            'Email_Sent__c ' +

            'FROM Lease_Agreement__c ' +

            whereClause +

            orderBy +

            ' LIMIT :pageSize ' +

            ' OFFSET :offsetRows';

        List<Lease_Agreement__c> agreements =
            Database.query(query);

        List<LeaseAgreementController.LeaseAgreementDTO>
            records =
            new List<
                LeaseAgreementController.LeaseAgreementDTO>();

        for (
            Lease_Agreement__c agreement :
            agreements
        ) {

            records.add(

                new LeaseAgreementController.LeaseAgreementDTO(agreement)

            );

        }

        LeaseAgreementController.LeaseAgreementSearchResponse response =
            new LeaseAgreementController.LeaseAgreementSearchResponse();

        response.records = records;

        response.totalRecords =
            totalRecords;

        response.pageNumber =
            pageNumber;

        response.pageSize =
            pageSize;

        response.totalPages =
            totalRecords == 0
            ? 0
            : Integer.valueOf(
                Math.ceil(
                    ((Decimal)totalRecords)
                    / pageSize
                )
            );

        return response;

    }


    private static String buildWhereClause(

        LeaseAgreementController.LeaseAgreementSearchRequest request

    ) {

        List<String> conditions =
            new List<String>();

        if (
            !String.isBlank(
                request.status
            )
        ) {

            conditions.add(

                'Status__c = \'' +

                String.escapeSingleQuotes(
                    request.status
                ) +

                '\''

            );

        }

        if (
            request.propertyId != null
        ) {

            conditions.add(

                'Property__c = \'' +

                request.propertyId +

                '\''

            );

        }

        if (
            request.tenantId != null
        ) {

            conditions.add(

                'Tenant__c = \'' +

                request.tenantId +

                '\''

            );

        }

        if (
            request.startDate != null
        ) {

            conditions.add(

                'Start_Date__c >= ' +

                request.startDate

            );

        }

        if (
            request.endDate != null
        ) {

            conditions.add(

                'End_Date__c <= ' +

                request.endDate

            );

        }

        if (
            conditions.isEmpty()
        ) {

            return '';

        }

        return

            ' WHERE ' +

            String.join(
                conditions,
                ' AND '
            );

    }


    private static String buildOrderBy(

        LeaseAgreementController.LeaseAgreementSearchRequest request

    ) {

        Set<String> allowedFields =
            new Set<String>{

                'Name',
                'CreatedDate',
                'Start_Date__c',
                'End_Date__c',
                'Monthly_Rent__c',
                'Status__c'

            };

        String sortBy =
            'CreatedDate';

        if (

            !String.isBlank(
                request.sortBy
            ) &&

            allowedFields.contains(
                request.sortBy
            )

        ) {

            sortBy =
                request.sortBy;

        }

        String direction =
            'DESC';

        if (

            !String.isBlank(
                request.sortDirection
            ) &&

            request.sortDirection
                .equalsIgnoreCase(
                    'ASC'
                )

        ) {

            direction = 'ASC';

        }

        return

            ' ORDER BY ' +

            sortBy +

            ' ' +

            direction;

    }


}