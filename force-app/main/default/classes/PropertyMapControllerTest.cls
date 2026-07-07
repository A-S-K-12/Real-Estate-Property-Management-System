@IsTest
private class PropertyMapControllerTest {

    private class SuccessMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();

            res.setStatusCode(200);

            res.setBody(
                '{' +
                '"status":"OK",' +
                '"results":[{' +
                    '"formatted_address":"123 Main Street, Bangalore",' +
                    '"geometry":{' +
                        '"location":{' +
                            '"lat":12.9716,' +
                            '"lng":77.5946' +
                        '}' +
                    '}' +
                '}]' +
                '}'
            );

            return res;
        }
    }

   
    private class ErrorMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();

            res.setStatusCode(200);

            res.setBody(
                '{"status":"ZERO_RESULTS","results":[]}'
            );

            return res;
        }
    }

    private class HttpFailureMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();

            res.setStatusCode(500);

            return res;
        }
    }

    @IsTest
    static void testGetPropertyLocation() {

        Property__c property =
            TestDataFactory.createProperty(true);

        Test.setMock(
            HttpCalloutMock.class,
            new SuccessMock()
        );

        Test.startTest();

        PropertyMapController.LocationWrapper wrapper =
            PropertyMapController.getPropertyLocation(
                property.Id
            );

        Test.stopTest();

        System.assertEquals(
            12.9716,
            wrapper.latitude
        );

        System.assertEquals(
            77.5946,
            wrapper.longitude
        );

        System.assertEquals(
            '123 Main Street, Bangalore',
            wrapper.formattedAddress
        );
    }

    @IsTest
    static void testEmptyAddress() {

        Property__c property =
            TestDataFactory.createProperty(false);

        property.Address__c = null;
        property.City__c = null;
        property.State__c = null;
        property.Postal_Code__c = null;
        property.Country__c = null;

        insert property;

        try {

            PropertyMapController.getPropertyLocation(
                property.Id
            );

            System.assert(false);

        } catch (AuraHandledException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Property address is empty.'
                )
            );

        }
    }

    @IsTest
    static void testHttpFailure() {

        Property__c property =
            TestDataFactory.createProperty(true);

        Test.setMock(
            HttpCalloutMock.class,
            new HttpFailureMock()
        );

        try {

            PropertyMapController.getPropertyLocation(
                property.Id
            );

            System.assert(false);

        } catch (AuraHandledException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Unable to connect to Google Maps.'
                )
            );

        }
    }

    @IsTest
    static void testGoogleGeocodeFailure() {

        Property__c property =
            TestDataFactory.createProperty(true);

        Test.setMock(
            HttpCalloutMock.class,
            new ErrorMock()
        );

        try {

            PropertyMapController.getPropertyLocation(
                property.Id
            );

            System.assert(false);

        } catch (AuraHandledException ex) {

            System.assert(
                ex.getMessage().contains(
                    'Address could not be geocoded.'
                )
            );

        }
    }

}