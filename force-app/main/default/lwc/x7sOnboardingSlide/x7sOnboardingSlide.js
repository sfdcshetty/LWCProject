/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api, track } from 'lwc';
import completeSlide from '@salesforce/apex/x7sOnboardingController.completeSlide';

export default class X7sOnboardingSlide extends LightningElement {

    @api className;
    @api layout = 'vertical';
    @api title = '';
    @api description = '';
    @api hideOnboardingModal = '';
    @api subText = '';
    @api hideHeader = false;
    @api closeModalByUser = false;
    @api primaryButtonLabel = 'Save &amp; Next';
    @api primaryButtonColor = '#333';
    @api primaryButtonLabelColor = '#fff';
    @api primaryButtonDisabled = false;
    @api backButtonLabel = 'Go Back';

    @track error;

    get slideClass() {
        return 'onboarding-slide ' + this.className + ' ' + (this.layout === 'Horizontal' ? 'onboarding-slide_horizontal ' : '');
    }

    get isHideHeader(){
        return !this.hideHeader;
    }

    get mediumDeviceSizeHeader() {
        return this.layout === 'Horizontal' ? '4' : '12';
    }

    get mediumDeviceSizeBody() {
        return this.layout === 'Horizontal' ? '8' : '12';
    }

    get primaryButtonLabelClassName() {
        return 'onboarding-slide__button primaryButtonLabelClass';
    }

    connectedCallback() {

        if( this.title && this.title.trim() === '' &&
            this.description && this.description.trim() === '' &&
            this.subText && this.subText.trim() === '' )
        {
            this.hideHeader = true;
        }       
    }

    renderedCallback() {
 
        let primaryClass = this.template.querySelector(".primaryButtonLabelClass");
        if(this.primaryButtonDisabled) {
            primaryClass.style = "background-color: "+ this.primaryButtonColor+'; opacity: 0.2;';
        }else{
            primaryClass.style = "background-color: "+ this.primaryButtonColor+';';
        } 
    }

    handlePrimaryClick() {

        const primarylickEvent = new CustomEvent('primaryclick', {
            detail: {
                        value: "primary"
                    }
        });
        this.dispatchEvent(primarylickEvent);
    }

    handleBackClick() {

        const backClickEvent = new CustomEvent('backclick', {
            detail: {
                        value: "back"
                    }
        });
        this.dispatchEvent(backClickEvent);
    }

    handleHideModal(evt) {

        let checked = evt.target.checked;
        this.closeModalByUser = checked;
        
        let param = (checked ? "hideModalByUser" :"showModalByUser");

        completeSlide({slide:param})
        .then(result =>{
            console.log('Success - handleHideModal');
        })
        .catch(err =>{
            this.error = err;
            console.log('handleHideModal Failed : '+err);
        });
    }

}