public with sharing class PropertyController {

    @AuraEnabled
    public static Id createProperty(
        PropertyDTO dto,
        List<ImageWrapper> images
    ) {
        return PropertyService.createProperty(dto, images);
    }

    @AuraEnabled
    public static void updateProperty(
        PropertyDTO dto
    ) {
        PropertyService.updateProperty(dto);
    }

    @AuraEnabled(cacheable=true)
    public static PropertyDTO getProperty(
        Id propertyId
    ) {
        return PropertyService.getProperty(propertyId);
    }

    @AuraEnabled(cacheable=true)
    public static PropertySearchResponse getProperties(
        PropertySearchRequest request
    ) {
        return PropertyService.getProperties(request);
    }

    @AuraEnabled
    public static void deleteProperty(
        Id propertyId
    ) {
        PropertyService.deleteProperty(propertyId);
    }

    public class PropertyDTO {

        @AuraEnabled
        public Id id { get; set; }

        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String address { get; set; }

        @AuraEnabled
        public String city { get; set; }

        @AuraEnabled
        public String state { get; set; }

        @AuraEnabled
        public String postalCode { get; set; }

        @AuraEnabled
        public String country { get; set; }

        @AuraEnabled
        public String propertyType { get; set; }

        @AuraEnabled
        public String furnishingStatus { get; set; }

        @AuraEnabled
        public String status { get; set; }

        @AuraEnabled
        public Decimal rent { get; set; }

        @AuraEnabled
        public String description { get; set; }

        @AuraEnabled
        public Decimal latitude { get; set; }

        @AuraEnabled
        public Decimal longitude { get; set; }

        @AuraEnabled
        public Decimal distance { get; set; }

        @AuraEnabled
        public String thumbnailUrl { get; set; }

        public PropertyDTO() {
        }

        public PropertyDTO(Property__c property) {

            if (property == null) {
                return;
            }

            id = property.Id;
            name = property.Name;
            address = property.Address__c;
            city = property.City__c;
            state = property.State__c;
            postalCode = property.Postal_Code__c;
            country = property.Country__c;

            propertyType = property.Property_Type__c;
            furnishingStatus = property.Furnishing_Status__c;
            status = property.Availability_Status__c;

            rent = property.Monthly_Rent__c;
            description = property.Description__c;

            latitude = property.Latitude__c;
            longitude = property.Longitude__c;
        }

    }

    public class ImageWrapper {

        @AuraEnabled
        public String fileName { get; set; }

        @AuraEnabled
        public String base64 { get; set; }

        @AuraEnabled
        public String contentType { get; set; }

        public ImageWrapper() {
        }

    }

    public class PropertySearchRequest {

        @AuraEnabled
        public Integer pageNumber { get; set; }

        @AuraEnabled
        public Integer pageSize { get; set; }

        @AuraEnabled
        public Decimal minPrice { get; set; }

        @AuraEnabled
        public Decimal maxPrice { get; set; }

        @AuraEnabled
        public String status { get; set; }

        @AuraEnabled
        public String furnishingStatus { get; set; }

        @AuraEnabled
        public Decimal latitude { get; set; }

        @AuraEnabled
        public Decimal longitude { get; set; }

        @AuraEnabled
        public Decimal distance { get; set; }

        @AuraEnabled
        public String sortBy { get; set; }

        @AuraEnabled
        public String sortDirection { get; set; }

        public PropertySearchRequest() {
        }

    }

    public class PropertySearchResponse {

        @AuraEnabled
        public List<PropertyDTO> records { get; set; }

        @AuraEnabled
        public Integer totalRecords { get; set; }

        @AuraEnabled
        public Integer totalPages { get; set; }

        @AuraEnabled
        public Integer pageNumber { get; set; }

        @AuraEnabled
        public Integer pageSize { get; set; }

        public PropertySearchResponse() {

            records = new List<PropertyDTO>();
            totalRecords = 0;
            totalPages = 0;
            pageNumber = 1;
            pageSize = 25;

        }

    }

    public class AddressWrapper {

        @AuraEnabled
        public String address { get; set; }

        @AuraEnabled
        public String city { get; set; }

        @AuraEnabled
        public String state { get; set; }

        @AuraEnabled
        public String postalCode { get; set; }

        @AuraEnabled
        public String country { get; set; }

        public AddressWrapper() {
        }

    }

    public class GeoLocationWrapper {

        @AuraEnabled
        public Decimal latitude { get; set; }

        @AuraEnabled
        public Decimal longitude { get; set; }

        public GeoLocationWrapper() {
        }

        public GeoLocationWrapper(
            Decimal latitude,
            Decimal longitude
        ) {
            this.latitude = latitude;
            this.longitude = longitude;
        }

    }

}