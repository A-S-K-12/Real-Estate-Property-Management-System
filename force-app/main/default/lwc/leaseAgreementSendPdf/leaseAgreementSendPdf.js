import { LightningElement, api } from 'lwc';

import sendPdfToTenant
    from '@salesforce/apex/LeaseAgreementController.sendPdfToTenant';

import { ShowToastEvent }
    from 'lightning/platformShowToastEvent';

import { CloseActionScreenEvent }
    from 'lightning/actions';

export default class LeaseAgreementSendPdf extends LightningElement {

    @api recordId;

    isLoading = false;

    async sendPdf() {

        this.isLoading = true;

        try {

            await sendPdfToTenant({
                leaseAgreementId: this.recordId
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Lease Agreement has been emailed successfully.',
                    variant: 'success'
                })
            );

            setTimeout(() => {
                this.dispatchEvent(new CloseActionScreenEvent());
            }, 1000);

        }
        catch (error) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Email Failed',
                    message:
                        error.body?.message ||
                        'Unable to send Lease Agreement.',
                    variant: 'error'
                })
            );

        }
        finally {

            this.isLoading = false;

        }

    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}