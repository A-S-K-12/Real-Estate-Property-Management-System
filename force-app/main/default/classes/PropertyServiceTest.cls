@IsTest
private class PropertyServiceTest {

    private static PropertyController.PropertyDTO buildDTO() {

        Property__c property = TestDataFactory.createProperty(false);

        PropertyController.PropertyDTO dto =
            new PropertyController.PropertyDTO();

        dto.name = property.Name;
        dto.address = property.Address__c;
        dto.city = property.City__c;
        dto.state = property.State__c;
        dto.postalCode = property.Postal_Code__c;
        dto.country = property.Country__c;
        dto.propertyType = property.Property_Type__c;
        dto.furnishingStatus = property.Furnishing_Status__c;
        dto.status = property.Availability_Status__c;
        dto.rent = property.Monthly_Rent__c;
        dto.description = property.Description__c;
        dto.latitude = 12.9716;
        dto.longitude = 77.5946;

        return dto;
    }

    private static List<PropertyController.ImageWrapper> buildImages() {

        PropertyController.ImageWrapper img =
            new PropertyController.ImageWrapper();

        img.fileName = 'property.png';
        img.contentType = 'image/png';
        img.base64 =
            EncodingUtil.base64Encode(
                Blob.valueOf('Test Image')
            );

        return new List<PropertyController.ImageWrapper>{ img };
    }

    @IsTest
    static void testCreateProperty() {

        Test.startTest();

        Id propertyId =
            PropertyService.createProperty(
                buildDTO(),
                buildImages()
            );

        Test.stopTest();

        Property__c property = [
            SELECT Name, Monthly_Rent__c
            FROM Property__c
            WHERE Id = :propertyId
        ];

        System.assertEquals('Sunrise Villas', property.Name);
        System.assertEquals(25000, property.Monthly_Rent__c);

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :propertyId
            ]
        );
    }

    @IsTest
    static void testUpdateProperty() {

        Id propertyId =
            PropertyService.createProperty(
                buildDTO(),
                buildImages()
            );

        PropertyController.PropertyDTO dto =
            buildDTO();

        dto.id = propertyId;
        dto.name = 'Updated Property';
        dto.rent = 30000;

        Test.startTest();
        PropertyService.updateProperty(dto);
        Test.stopTest();

        Property__c property = [
            SELECT Name, Monthly_Rent__c
            FROM Property__c
            WHERE Id = :propertyId
        ];

        System.assertEquals('Updated Property', property.Name);
        System.assertEquals(30000, property.Monthly_Rent__c);
    }

    @IsTest
    static void testGetProperty() {

        Id propertyId =
            PropertyService.createProperty(
                buildDTO(),
                buildImages()
            );

        Test.startTest();
        PropertyController.PropertyDTO dto =
            PropertyService.getProperty(propertyId);
        Test.stopTest();

        System.assertEquals(propertyId, dto.id);
        System.assertEquals('Sunrise Villas', dto.name);
    }

    @IsTest
    static void testDeleteProperty() {

        Id propertyId =
            PropertyService.createProperty(
                buildDTO(),
                buildImages()
            );

        Test.startTest();
        PropertyService.deleteProperty(propertyId);
        Test.stopTest();

        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM Property__c
                WHERE Id = :propertyId
            ]
        );
    }

    @IsTest
    static void testGetProperties() {

        for (Integer i = 0; i < 5; i++) {

            PropertyController.PropertyDTO dto =
                buildDTO();

            dto.name = 'Property ' + i;
            dto.rent = 10000 + i;

            PropertyService.createProperty(
                dto,
                buildImages()
            );
        }

        PropertyController.PropertySearchRequest req =
            new PropertyController.PropertySearchRequest();

        req.pageNumber = 1;
        req.pageSize = 10;
        req.sortBy = 'Name';
        req.sortDirection = 'ASC';

        Test.startTest();

        PropertyController.PropertySearchResponse response =
            PropertyService.getProperties(req);

        Test.stopTest();

        System.assertEquals(5, response.records.size());
        System.assertEquals(5, response.totalRecords);
        System.assertEquals(1, response.pageNumber);
    }

    @IsTest
    static void testValidationFailure() {

        PropertyController.PropertyDTO dto =
            buildDTO();

        dto.name = null;

        try {

            PropertyService.createProperty(
                dto,
                buildImages()
            );

            System.assert(false);

        } catch (AuraHandledException ex) {

        
        }
    }

    @IsTest
    static void testImageValidationFailure() {

        try {

            PropertyService.createProperty(
                buildDTO(),
                new List<PropertyController.ImageWrapper>()
            );

            System.assert(false);

        } catch (AuraHandledException ex) {

       
        }
    }

    @IsTest
    static void testMaximumPageLimit() {

        PropertyController.PropertySearchRequest req =
            new PropertyController.PropertySearchRequest();

        req.pageNumber = 100;
        req.pageSize = 50;

        try {

            PropertyService.getProperties(req);

            System.assert(false);

        } catch (AuraHandledException ex) {

          
        }
    }

    @IsTest
    static void testNullSearchRequest() {

        Test.startTest();

        PropertyController.PropertySearchResponse response =
            PropertyService.getProperties(null);

        Test.stopTest();

    }
}