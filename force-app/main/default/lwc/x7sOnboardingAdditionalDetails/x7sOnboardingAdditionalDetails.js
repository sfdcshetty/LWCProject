/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */

 
import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class X7sOnboardingAdditionalDetails extends LightningElement {

    @api buttonColor = '#ff8201';
    @api recordId;
    @api err;
    @api additionalSlideHeader;
    @api additionalSlideMessage;
    @api additionalSlideLabel;
    @api additionalSlideUserFieldName1;
    @api additionalSlideUserFieldLabel1;
    @api additionalSlideUserFieldTooltip1;
    @api additionalSlideUserFieldName2;
    @api additionalSlideUserFieldLabel2;
    @api additionalSlideUserFieldTooltip2;
    @api nextButtonLabel;
    @api backButtonLabel;


    connectedCallback() {

        this.recordId = userId;
    }

    goToNext(event) {
        this.handleSubmit(event);

        const additionalDetailsClick = new CustomEvent('additionaldetailsclick',{
            detail: {
                        message: '4',
                        slide: 'Additional'
                    }
        });
        this.dispatchEvent(additionalDetailsClick);
    }

    goBack() {

        const additionalDetailsBackClick = new CustomEvent('additionaldetailsbackclick',{
            detail: {
                        message: '2',
                        slide: ''
                    }
        });
        this.dispatchEvent(additionalDetailsBackClick);
    }

    handleSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);

    }

    handleOnSuccess() {

        const successToast = new ShowToastEvent({
            message: 'Record Saved Sucessfully',
            variant: 'success',
            mode: 'dismissable',
        });
        this.dispatchEvent(successToast);
    }

    handleOnError() {

        const errorToast = new ShowToastEvent({
            message: 'Something went wrong! Record not Saved.',
            variant: 'error',
            mode: 'dismissable',
        });
        this.dispatchEvent(errorToast);
    }
}