/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import completeSlide from '@salesforce/apex/x7sOnboardingController.completeSlide';
import updatePreferences from '@salesforce/apex/x7sOnboardingController.updatePreferences';

export default class X7sOnboardingNotifications extends NavigationMixin(LightningElement) {

    @api notificationText;
    @api notificationMessage;
    @api notificationHeader;
    @api notificationAction;
    @api notificationInfoUrl;
    @api notificationLinkLabel;
    @api notificationChkByUser;
    @api notificationUser = '';
    @api emailPreference;
    @api getNotifications = 'false';
    @api buttonColor = '#ff8201';
    @api pageNumber = '6';
    @api nextButtonLabel;
    @api backButtonLabel;

    get showNotification() {
        return this.notificationInfoUrl && this.notificationLinkLabel;
    }

    handleLinkClick() {

        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.notificationInfoUrl
            }
        });
    }

    goToNext() {

        const notificationClick = new CustomEvent('notificationclick',{
            detail: {
                        message: '11',
                        slide: 'Notification'
                    }
        });
        this.dispatchEvent(notificationClick);
    }

    goBack() {

        const notificationBackClick = new CustomEvent('notificationbackclick',{
            detail: {
                        message: '9',
                        slide: ''
                    }
        });
        this.dispatchEvent(notificationBackClick);
    }

    notificationChange(evt) {

        let checked = evt.target.checked;
        let finalVal = (checked ? "showNotification" :"hideNotification");

        completeSlide({slide:finalVal})
            .then(result => {
                console.log('success - notificationChange');
            })
            .catch(err => {
                console.log('notificationChange Failed : '+err);
            });
    }

    updateEmailOptInOut(evt) {

        let checked = evt.target.checked;

        updatePreferences({decision:checked})
            .then(result => {
                console.log('success - updateEmailOptInOut');
            })
            .catch(err => {
                console.log('updateEmailOptInOut Failed : '+err);
            });
    }

}