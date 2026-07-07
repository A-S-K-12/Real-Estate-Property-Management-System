public with sharing class PropertyMapController {

    public class LocationWrapper {
        @AuraEnabled public Decimal latitude;
        @AuraEnabled public Decimal longitude;
        @AuraEnabled public String formattedAddress;
    }

    @AuraEnabled(cacheable=false)
    public static LocationWrapper getPropertyLocation(Id propertyId) {

        Property__c property = [
            SELECT Name,
                   Address__c,
                   City__c,
                   State__c,
                   Postal_Code__c,
                   Country__c
            FROM Property__c
            WHERE Id = :propertyId
            LIMIT 1
        ];

        String address = '';

        if(property.Address__c != null)
            address += property.Address__c + ', ';

        if(property.City__c != null)
            address += property.City__c + ', ';

        if(property.State__c != null)
            address += property.State__c + ', ';

        if(property.Postal_Code__c != null)
            address += property.Postal_Code__c + ', ';

        if(property.Country__c != null)
            address += property.Country__c;

        if(String.isBlank(address)){
            throw new AuraHandledException('Property address is empty.');
        }

        String endpoint =
            'https://maps.googleapis.com/maps/api/geocode/json?address='
            + EncodingUtil.urlEncode(address,'UTF-8')
            + '&key=YOUR_API_KEY';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(60000);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if(response.getStatusCode() != 200){
            throw new AuraHandledException('Unable to connect to Google Maps.');
        }

        Map<String,Object> result =
            (Map<String,Object>)JSON.deserializeUntyped(response.getBody());

        if((String)result.get('status') != 'OK'){
            throw new AuraHandledException('Address could not be geocoded.');
        }

        List<Object> results =
            (List<Object>)result.get('results');

        Map<String,Object> firstResult =
            (Map<String,Object>)results[0];

        Map<String,Object> geometry =
            (Map<String,Object>)firstResult.get('geometry');

        Map<String,Object> location =
            (Map<String,Object>)geometry.get('location');

        LocationWrapper wrapper = new LocationWrapper();

        wrapper.latitude =
            Decimal.valueOf(String.valueOf(location.get('lat')));

        wrapper.longitude =
            Decimal.valueOf(String.valueOf(location.get('lng')));

        wrapper.formattedAddress =
            (String)firstResult.get('formatted_address');

        return wrapper;
    }
}