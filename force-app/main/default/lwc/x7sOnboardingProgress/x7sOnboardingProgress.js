/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */

 
import { LightningElement, api } from 'lwc';

export default class X7sOnboardingProgress extends LightningElement {

    @api completedSteps;
    @api progressHeading = 'Getting Started Guide';
    @api progressMessage = 'With this guide, you can tailor your experience to take full advantage of everything the community has to offer. Just a few quick steps and you will be on your way.';
    @api user;

    @api step1Label;
    @api step2Label;
    @api step3Label;
    @api step4Label;
    @api step5Label;
    @api step6Label;
    @api step7Label;
    @api step8Label;

    @api showStep1;
    @api showStep2;
    @api showStep3;
    @api showStep4;
    @api showStep5;
    @api showStep6;
    @api showStep7;
    @api showStep8;

    @api step1Number;
    @api step2Number;
    @api step3Number;
    @api step4Number;
    @api step5Number;
    @api step6Number;
    @api step7Number;
    @api step8Number;

    @api useTopicMetadata;
    @api topicSlides = [];
    @api topicSlideIndex = 0;

    topicSlidesList = [];
    index = 0;
    page = 0;

    
    connectedCallback() {

        this.topicSlidesList = this.topicSlides.map((parentLabel,pageIndex) => {
            return {parentLabel, pageNo : pageIndex + 4 + ''};
        });
    }

    get metaIsCompleted() {
        return (this.topicSlideIndex > this.index || this.user.X7S_Completed_Topics_Slide__c);
    }

    handlePageChange(event) {
        event.preventDefault();
        console.log('pageChange event data => '+JSON.stringify(event.detail));

        const progressStepClickEvent = new CustomEvent('progressstepclick', {
            detail: {
                        message:event.detail.message, 
                        slide:event.detail.slide
                    }
        });
        this.dispatchEvent(progressStepClickEvent);
    }
}