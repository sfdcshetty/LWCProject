/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api } from 'lwc';

export default class X7sOnboardingTours extends LightningElement {

    @api toursMessage;
    @api toursHeader;
    @api displayTours;
    @api displayDone = false;
    @api doneMessage;
    @api buttonColor = '#ff8201';
    @api videoType1 = 'YouTube';
    @api videoUrl1;
    @api videoTitle1 = "First Video";
    @api videoDescription1 ='Some great first content!';
    @api videoIframeTitleForAria = 'First Video';
    @api videoAlign;
    @api tourEndButtonLabel;
    @api backButtonLabel;

    connectedCallback() {

        this.displayTours = true;
        console.log('displayTours = '+this.displayTours);
    }

    goToNext() {    

        const tourClick = new CustomEvent('tourclick', {
            detail: {
                        message: '5',
                        slide: 'Tours'
                    }
        });
        this.dispatchEvent(tourClick);
    }

    goBack() {

        const tourBackClick = new CustomEvent('tourbackclick', {
            detail: {
                        message: '3',
                        slide: ''
                    }
        });
        this.dispatchEvent(tourBackClick);
    }

    completeOnboarding() {

        const completeClick = new CustomEvent('completeclick', {
            detail: {
                        message: 'Close',
                        slide: 'Done'
                    }
        });
        this.dispatchEvent(completeClick);
    }

    goBackToTours() {

        const backToToursClick = new CustomEvent('backtotoursclick', {
            detail: {
                        message: '4',
                        slide: ''
                    }
        });
        this.dispatchEvent(backToToursClick);
    }
}