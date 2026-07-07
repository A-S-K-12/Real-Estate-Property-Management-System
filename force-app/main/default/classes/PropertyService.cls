public with sharing class PropertyService {

    /*
    *********************************************************
    * PUBLIC METHODS
    *********************************************************
    */

    public static Id createProperty(
        PropertyController.PropertyDTO dto,
        List<PropertyController.ImageWrapper> images
    ) {

        validateProperty(dto);
        validateImages(images);

        Savepoint sp = Database.setSavepoint();

        try {

            Property__c property = buildProperty(dto);

            insert property;

            uploadImages(property.Id, images);

            return property.Id;

        } catch (Exception ex) {

            Database.rollback(sp);

            throw new AuraHandledException(
                'Unable to create property. ' + ex.getMessage()
            );

        }

    }


    public static void updateProperty(
        PropertyController.PropertyDTO dto
    ) {

        if (dto == null || dto.id == null) {
            throw new AuraHandledException('Invalid Property.');
        }

        validateProperty(dto);

        try {

            Property__c property = [

                SELECT Id,
                       Name,
                       Address__c,
                       City__c,
                       State__c,
                       Postal_Code__c,
                       Country__c,
                       Property_Type__c,
                       Furnishing_Status__c,
                       Availability_Status__c,
                       Monthly_Rent__c,
                       Description__c,
                       Latitude__c,
                       Longitude__c

                FROM Property__c

                WHERE Id = :dto.id

                LIMIT 1

            ];

            mapDTO(property, dto);

            update property;

        } catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to update property. ' + ex.getMessage()
            );

        }

    }


    public static PropertyController.PropertyDTO getProperty(
        Id propertyId
    ) {

        if (propertyId == null) {
            throw new AuraHandledException(
                'Property Id is required.'
            );
        }

        try {

            Property__c property = [

                SELECT Id,
                       Name,
                       Address__c,
                       City__c,
                       State__c,
                       Postal_Code__c,
                       Country__c,
                       Property_Type__c,
                       Furnishing_Status__c,
                       Availability_Status__c,
                       Monthly_Rent__c,
                       Description__c,
                       Latitude__c,
                       Longitude__c

                FROM Property__c

                WHERE Id = :propertyId

                LIMIT 1

            ];

            return new PropertyController.PropertyDTO(property);

        } catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to retrieve property. ' + ex.getMessage()
            );

        }

    }


    public static void deleteProperty(
        Id propertyId
    ) {

        if (propertyId == null) {
            throw new AuraHandledException(
                'Property Id is required.'
            );
        }

        try {

            delete [

                SELECT Id

                FROM Property__c

                WHERE Id = :propertyId

                LIMIT 1

            ];

        } catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to delete property. ' + ex.getMessage()
            );

        }

    }


    /*
    *********************************************************
    * PRIVATE HELPERS
    *********************************************************
    */

    private static Property__c buildProperty(
        PropertyController.PropertyDTO dto
    ) {

        Property__c property = new Property__c();

        mapDTO(property, dto);

        return property;

    }


    private static void mapDTO(
        Property__c property,
        PropertyController.PropertyDTO dto
    ) {

        property.Name = dto.name;
        property.Address__c = dto.address;
        property.City__c = dto.city;
        property.State__c = dto.state;
        property.Postal_Code__c = dto.postalCode;
        property.Country__c = dto.country;
        property.Property_Type__c = dto.propertyType;
        property.Furnishing_Status__c = dto.furnishingStatus;
        property.Availability_Status__c = dto.status;
        property.Monthly_Rent__c = dto.rent;
        property.Description__c = dto.description;
        property.Latitude__c = dto.latitude;
        property.Longitude__c = dto.longitude;

    }

    // ===== Part 2 starts here =====
    /*
    *********************************************************
    * VALIDATIONS
    *********************************************************
    */

    private static void validateProperty(
        PropertyController.PropertyDTO dto
    ) {

        if (dto == null) {
            throw new AuraHandledException(
                'Property data is required.'
            );
        }

        if (String.isBlank(dto.name)) {
            throw new AuraHandledException(
                'Property Name is required.'
            );
        }

        if (String.isBlank(dto.address)) {
            throw new AuraHandledException(
                'Address is required.'
            );
        }

        if (String.isBlank(dto.city)) {
            throw new AuraHandledException(
                'City is required.'
            );
        }

        if (String.isBlank(dto.state)) {
            throw new AuraHandledException(
                'State is required.'
            );
        }

        if (String.isBlank(dto.postalCode)) {
            throw new AuraHandledException(
                'Postal Code is required.'
            );
        }

        if (String.isBlank(dto.country)) {
            throw new AuraHandledException(
                'Country is required.'
            );
        }

        if (String.isBlank(dto.propertyType)) {
            throw new AuraHandledException(
                'Property Type is required.'
            );
        }

        if (String.isBlank(dto.status)) {
            throw new AuraHandledException(
                'Availability Status is required.'
            );
        }

        if (dto.rent == null || dto.rent <= 0) {
            throw new AuraHandledException(
                'Monthly Rent must be greater than zero.'
            );
        }

        if (String.isBlank(dto.description)) {
            throw new AuraHandledException(
                'Description is required.'
            );
        }

    }


    private static void validateImages(
        List<PropertyController.ImageWrapper> images
    ) {

        if (images == null || images.isEmpty()) {

            throw new AuraHandledException(
                'Please upload at least one property image.'
            );

        }

        Set<String> allowedContentTypes = new Set<String>{
            'image/jpeg',
            'image/png'
        };

        for (PropertyController.ImageWrapper image : images) {

            if (image == null) {
                throw new AuraHandledException(
                    'Invalid image.'
                );
            }

            if (String.isBlank(image.fileName)) {
                throw new AuraHandledException(
                    'Image file name is required.'
                );
            }

            if (String.isBlank(image.base64)) {
                throw new AuraHandledException(
                    'Image data is missing.'
                );
            }

            if (String.isBlank(image.contentType)) {
                throw new AuraHandledException(
                    'Image type is required.'
                );
            }

            if (!allowedContentTypes.contains(image.contentType)) {
                throw new AuraHandledException(
                    'Only JPG and PNG images are allowed.'
                );
            }

        }

    }


    /*
    *********************************************************
    * FILE UPLOAD
    *********************************************************
    */

    private static void uploadImages(

        Id propertyId,

        List<PropertyController.ImageWrapper> images

    ) {

        if (images == null || images.isEmpty()) {
            return;
        }

        List<ContentVersion> versions =
            new List<ContentVersion>();

        for (PropertyController.ImageWrapper image : images) {

            ContentVersion cv = new ContentVersion();

            cv.Title = image.fileName.contains('.')
                ? image.fileName.substringBeforeLast('.')
                : image.fileName;

            cv.PathOnClient = image.fileName;

            cv.VersionData =
                EncodingUtil.base64Decode(image.base64);

            versions.add(cv);

        }

        insert versions;

        versions = [

            SELECT Id,
                   ContentDocumentId

            FROM ContentVersion

            WHERE Id IN :versions

        ];

        List<ContentDocumentLink> links =
            new List<ContentDocumentLink>();

        for (ContentVersion cv : versions) {

            links.add(

                new ContentDocumentLink(

                    LinkedEntityId = propertyId,

                    ContentDocumentId = cv.ContentDocumentId,

                    ShareType = 'V',

                    Visibility = 'AllUsers'

                )

            );

        }

        insert links;

    }

    // ===== Part 3 starts here =====
        /*
    *********************************************************
    * PROPERTY SEARCH
    *********************************************************
    */

    public static PropertyController.PropertySearchResponse getProperties(
        PropertyController.PropertySearchRequest request
    ) {

        if (request == null) {
            request = new PropertyController.PropertySearchRequest();
        }

        Integer pageSize =
            (request.pageSize == null || request.pageSize <= 0)
            ? 25
            : request.pageSize;

        // Prevent excessive page sizes
        pageSize = Math.min(pageSize, 100);

        Integer pageNumber =
            (request.pageNumber == null || request.pageNumber <= 0)
            ? 1
            : request.pageNumber;

        Integer offsetRows =
            (pageNumber - 1) * pageSize;

        // Salesforce OFFSET supports up to 2000 rows
        if (offsetRows > 2000) {
            throw new AuraHandledException(
                'Maximum page limit exceeded.'
            );
        }

        String whereClause = buildWhereClause(request);

        String orderBy = buildOrderBy(request);

        Integer totalRecords = Database.countQuery(
            'SELECT COUNT() FROM Property__c ' + whereClause
        );

        String query =
            'SELECT ' +
            'Id,' +
            'Name,' +
            'Address__c,' +
            'City__c,' +
            'State__c,' +
            'Postal_Code__c,' +
            'Country__c,' +
            'Property_Type__c,' +
            'Furnishing_Status__c,' +
            'Availability_Status__c,' +
            'Monthly_Rent__c,' +
            'Description__c,' +
            'Latitude__c,' +
            'Longitude__c ' +
            'FROM Property__c ' +
            whereClause +
            orderBy +
            ' LIMIT :pageSize ' +
            ' OFFSET :offsetRows';

        List<Property__c> properties =
            Database.query(query);

        List<PropertyController.PropertyDTO> records =
            new List<PropertyController.PropertyDTO>();

        for (Property__c property : properties) {

            records.add(
                new PropertyController.PropertyDTO(property)
            );

        }

        PropertyController.PropertySearchResponse response =
            new PropertyController.PropertySearchResponse();

        response.records = records;
        response.totalRecords = totalRecords;
        response.pageNumber = pageNumber;
        response.pageSize = pageSize;

        response.totalPages =
            totalRecords == 0
            ? 0
            : Integer.valueOf(
                Math.ceil(
                    ((Decimal) totalRecords) / pageSize
                )
            );

        return response;

    }


    /*
    *********************************************************
    * WHERE CLAUSE
    *********************************************************
    */

    private static String buildWhereClause(
        PropertyController.PropertySearchRequest request
    ) {

        List<String> conditions =
            new List<String>();

        if (request.minPrice != null) {

            conditions.add(
                'Monthly_Rent__c >= ' + request.minPrice
            );

        }

        if (request.maxPrice != null) {

            conditions.add(
                'Monthly_Rent__c <= ' + request.maxPrice
            );

        }

        if (!String.isBlank(request.status)) {

            conditions.add(
                'Availability_Status__c = \'' +
                String.escapeSingleQuotes(request.status) +
                '\''
            );

        }

        if (!String.isBlank(request.furnishingStatus)) {

            conditions.add(
                'Furnishing_Status__c = \'' +
                String.escapeSingleQuotes(
                    request.furnishingStatus
                ) +
                '\''
            );

        }

        if (conditions.isEmpty()) {
            return '';
        }

        return ' WHERE ' +
            String.join(conditions, ' AND ');

    }


    /*
    *********************************************************
    * ORDER BY
    *********************************************************
    */

    private static String buildOrderBy(
        PropertyController.PropertySearchRequest request
    ) {

        Set<String> allowedFields =
            new Set<String>{

                'Name',
                'Monthly_Rent__c',
                'CreatedDate',
                'City__c'

            };

        String sortBy = 'CreatedDate';

        if (
            !String.isBlank(request.sortBy) &&
            allowedFields.contains(request.sortBy)
        ) {

            sortBy = request.sortBy;

        }

        String direction = 'DESC';

        if (
            !String.isBlank(request.sortDirection) &&
            request.sortDirection.equalsIgnoreCase('ASC')
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