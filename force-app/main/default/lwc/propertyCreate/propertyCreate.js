import { LightningElement } from 'lwc';
import createProperty from '@salesforce/apex/PropertyController.createProperty';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class PropertyCreate extends NavigationMixin(LightningElement) {

MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB
SUPPORTED_TYPES = [
    'image/jpeg',
    'image/jpg',
    'image/png'
];
state = {
        property: {
            id: null,
            name: '',
            address: '',
            city: '',
            state: '',
            postalCode: '',
            country: '',
            propertyType: '',
            furnishingStatus: '',
            status: '',
            rent: null,
            description: '',
            latitude: null,
            longitude: null
        },

        images: [],

        markers: [],

        isLoading: false,

        showMap: false
    };

    get property() {
        return this.state.property;
    }

    get images() {
        return this.state.images;
    }

    get markers() {
        return this.state.markers;
    }

    get isLoading() {
        return this.state.isLoading;
    }

    get showMap() {
        return this.state.showMap;
    }

    get hasImages() {
        return this.state.images.length > 0;
    }

    get imageCount() {
        return this.state.images.length;
    }

    get propertyTypes() {
        return [
            {
                label: 'Residential',
                value: 'Residential'
            },
            {
                label: 'Commercial',
                value: 'Commercial'
            }
        ];
    }

    get furnishingOptions() {
        return [
            {
                label: 'Furnished',
                value: 'Furnished'
            },
            {
                label: 'Semi Furnished',
                value: 'Semi Furnished'
            },
            {
                label: 'Unfurnished',
                value: 'Unfurnished'
            }
        ];
    }

    get statusOptions() {
        return [
            {
                label: 'Available',
                value: 'Available'
            },
            {
                label: 'Occupied',
                value: 'Occupied'
            }
        ];
    }

    setLoading(value) {

        this.state = {
            ...this.state,
            isLoading: value
        };

    }

    updateProperty(field, value) {

        this.state = {
            ...this.state,
            property: {
                ...this.state.property,
                [field]: value
            }
        };

        console.log(JSON.stringify(this.state.property));
    }

    setImages(images) {
        this.state = {
            ...this.state,
            images
        };
    }

    setMarkers(markers) {
        this.state = {
            ...this.state,
            markers,
            showMap: markers.length > 0
        };
    }

    resetForm() {
        this.state = {
            property: {
                id: null,
                name: '',
                address: '',
                city: '',
                state: '',
                postalCode: '',
                country: '',
                propertyType: '',
                furnishingStatus: '',
                status: '',
                rent: null,
                description: '',
                latitude: null,
                longitude: null
            },
            images: [],
            markers: [],
            isLoading: false,
            showMap: false
        };
        this.resetFileInput();
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        let value = event.target.value;

        console.log(field, value);

        if (field === 'rent') {
            value = value === '' ? null : Number(value);
        }

        this.updateProperty(field, value);
    }

    resetFileInput(){
        const input = this.template.querySelector(
            'lightning-input[name="propertyImages"]'
        );
        if(input){
            input.value = null;
        }
    }

    clearForm(){
        this.resetForm();
        this.resetFileInput();
    }

    cancel(){
        this.clearForm();
    }

    buildPropertyDTO(){
        return {
            ...this.property
        };
    }
   
    buildImageDTO(){
        return this.images.map(image => {
            return {
                fileName: image.fileName,
                base64: image.base64,
                contentType: image.contentType,
                fileSize: image.fileSize
            };
        });
    }

    async handleFiles(event) {
        const selectedFiles = [...event.target.files];
        if (!selectedFiles.length) {
            return;
        }
        const images = [...this.images];
        for (const file of selectedFiles) {
        try{
            const image = await this.processFile(file);
            if(image){
                images.push(image);
            }
            }
            catch(error){
                this.showError(error.message);
            }
        }
        this.setImages(images);
    }

    async processFile(file) {
        if (!this.validateFile(file)) {
            return null;
        }
        const exists = this.images.some(image =>
        image.fileName === file.name &&
        image.fileSize === file.size
        );

        if (exists) {

            this.showWarning(
                'Image already selected.'
            );

            return null;

        }

        const base64 = await this.readFile(file);
        return {
            fileName: file.name,
            fileSize: file.size,
            contentType: file.type,
            base64,
            preview: `data:${file.type};base64,${base64}`
        };
        
    }
   
    readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = () => {
                reject(new Error('Unable to read file.'));
            };
            reader.readAsDataURL(file);
        });
    }
   

    validateFile(file) {
        if (!this.SUPPORTED_TYPES.includes(file.type)) {
            this.showError(
                'Only JPG and PNG images are supported.'
            );
            return false;
        }
        if (file.size > this.MAX_FILE_SIZE) {
            this.showError(
                'Maximum image size is 5 MB.'
            );
           return false;
        }
        return true;
    }

    removeImage(event) {
        const index = Number(
            event.currentTarget.dataset.index
        );
        const images = [...this.images];
        images.splice(index, 1);
        this.setImages(images);
        if (images.length === 0) {
            this.resetFileInput();
        }
    }
  
    clearImages() {
        this.setImages([]);
        this.resetFileInput();

    }

    validateForm() {
        const errors = [];
        this.validateProperty(errors);
        this.validateImages(errors);
        return errors;
    }
   
    validateProperty(errors) {
        const property = this.property;
        if (!property.address?.trim()) {
            errors.push('Address is required.');
        }
        if (!property.city?.trim()) {
            errors.push('City is required.');
        }
        if (!property.state?.trim()) {
            errors.push('State is required.');
        }
        if (!property.postalCode?.trim()) {
            errors.push('Postal Code is required.');
        }
        if (!property.country?.trim()) {
            errors.push('Country is required.');
        }
        if (!property.propertyType) {
            errors.push('Property Type is required.');
        }
        if (!property.status) {
            errors.push('Availability Status is required.');
        }
        if (
            property.rent === null ||
            property.rent === undefined ||
            property.rent <= 0
        ) {
            errors.push('Rent must be greater than zero.');
        }
        if (!property.description?.trim()) {
            errors.push('Description is required.');
        }
    }

    validateImages(errors) {
        if (this.images.length === 0) {
            errors.push(
              'Please upload at least one property image.'
            );
        }
    }

    focusFirstInvalidField() {
        const inputs = this.template.querySelectorAll(
            'lightning-input, lightning-combobox, lightning-textarea'
        );
        for (const input of inputs) {
            if (!input.reportValidity()) {
                input.focus();
                return;
            }
        }
    }

    reportValidity() {
        let valid = true;
        const inputs = this.template.querySelectorAll(
            'lightning-input, lightning-combobox, lightning-textarea'
        );
        inputs.forEach(input => {
            if (!input.reportValidity()) {
                valid = false;
            }
        });
        return valid;
    }

    isValid() {
        if (!this.reportValidity()) {
            this.focusFirstInvalidField();
            return false;
        }
        const errors = this.validateForm();
        if (errors.length) {
            this.showError(
                errors.join('\n')
            );
            return false;
        }
        return true;
    }

    async save() {

        if (this.isLoading) {
            return;
        }

        if (!this.isValid()) {
            return;
        }

        this.setLoading(true);
        try {
            const propertyId = await this.createProperty();
            this.handleSuccess(propertyId);
        }
        catch(error){
            this.handleError(error);
        }
        finally{
            this.setLoading(false);
        }
    }

    async createProperty(){
        const dto = this.buildPropertyDTO();
        console.log(JSON.stringify(dto));
        const images = this.buildImageDTO();
        return await createProperty({
            dto,
            images
        });
    }

    handleSuccess(propertyId){
        this.showSuccess(
            'Property created successfully.'
        );
        this.navigateToRecord(propertyId);
    }

    handleError(error){
        let message =
            'Something went wrong.';
        if(error?.body?.message){
            message = error.body.message;
        }
        else if(error?.message){
            message = error.message;
        }
        this.showError(message);
    }

    showSuccess(message){
        this.dispatchEvent(
            new ShowToastEvent({
                title:'Success',
                message,
                variant:'success'
          })
        );
    }

    showError(message){
        this.dispatchEvent(
            new ShowToastEvent({
                title:'Error',
                message,
                variant:'error',
                mode:'sticky'
            })
        );
    }

    showWarning(message){
        this.dispatchEvent(
            new ShowToastEvent({
                title:'Warning',
                message,
                variant:'warning'
            })
        );
    }

    navigateToRecord(recordId){
        this[NavigationMixin.Navigate](
            {
                type:'standard__recordPage',
                attributes:{
                    recordId,
                    objectApiName:'Property__c',
                    actionName:'view'
                }
            }
        );
    }
}