import { LightningElement, api, wire } from 'lwc';
import getPropertyLocation from '@salesforce/apex/PropertyMapController.getPropertyLocation';

export default class PropertyMap extends LightningElement {

    @api recordId;

    mapMarkers = [];

    @wire(getPropertyLocation, { propertyId: '$recordId' })
    wiredLocation({ data, error }) {

        if(data){

            this.mapMarkers = [
                {
                    location: {
                        Latitude: data.latitude,
                        Longitude: data.longitude
                    },
                    title: 'Property',
                    description: data.formattedAddress
                }
            ];

        } else if(error){
            console.error(error);
        }
    }
}