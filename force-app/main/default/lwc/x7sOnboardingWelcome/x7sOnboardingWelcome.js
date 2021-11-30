/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api, track } from 'lwc';
import setAgreedTermsAndConditions from '@salesforce/apex/x7sOnboardingController.setAgreedTermsAndConditions';
import id from '@salesforce/user/Id';

export default class X7sOnboardingWelcome extends LightningElement {

    @api welcomeMessage;
    @api welcomeHeader;
    @api buttonColor = '#ff8201';
    @api beginButtonLabel;
    @api showTermsAndConditions;
    @api termsAndConditionsPrompt;
    @api agreeToTermsAndConditionsLabel;
    @api termsAndConditions;
    @api agreedToTerms = false;

    @api videoType1;
    @api videoUrl1;
    @api videoTitle1;
    @api videoIframeTitleForAria;
    @api videoDescription1;
    @api videoAlign;
    //@api showWelcomeVideo;
    
    

    @track error;

    get primaryButtonSetting() {
        return this.showTermsAndConditions && !this.agreedToTerms;
    }

    goToNext(evt) {
        const welcomeClickEvent = new CustomEvent('welcomeclick', {
            detail: {
                        message: '2',
                        slide: 'Welcome'
                    }
        });
        this.dispatchEvent(welcomeClickEvent);
    }

    handleAgreedCheck(event) {

        this.agreedToTerms = event.target.checked;
 
        setAgreedTermsAndConditions({agreed:this.agreedToTerms})
            .then(result => {
                console.log('Success - AgreedTermsAndConditions');
            })
            .catch(err => {
                this.error = err;
            });

        this.agreedToTerms = this.agreedToTerms;
    }
}