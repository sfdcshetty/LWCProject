/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class X7sOnboardingDone extends NavigationMixin(LightningElement) {

    @api doneMessage;
    @api doneHeader;
    @api doneAction;
    @api LinkToProfile = '';
    @api LinkToSettings = '';
    @api user;
    @api buttonColor = '#ff8201';
    @api newTabLink = 'false';
    @api action1Icon;
    @api action1Text;
    @api action1Description;
    @api action1Url;
    @api action1UseUserId = 'false';
    @api action2Icon;
    @api action2Text;
    @api action2Description;
    @api action2Url;
    @api action2UseUserId = 'false';
    @api action3Icon;
    @api action3Text;
    @api action3Description;
    @api action3Url;
    @api action3UseUserId = 'false';
    @api action4Icon;
    @api action4Text;
    @api action4Description;
    @api action4Url;
    @api action4UseUserId = 'false';
    @api completeButtonLabel;
    @api backButtonLabel;

    get isAction1() {
        return this.action1Url && this.action1Text;
    }

    get isAction2() {
        return this.action2Url && this.action2Text;
    }

    get isAction3() {
        return this.action3Url && this.action3Text;
    }

    get isAction4() {
        return this.action4Url && this.action4Text;
    }

    get action1Link() {
        return this.action1Url +''+ (this.action1UseUserId ? '/'+this.user.Id : '');
    }

    get action2Link() {
        return this.action2Url +''+ (this.action2UseUserId ? '/'+this.user.Id : '');
    }

    get action3Link() {
        return this.action3Url +''+ (this.action3UseUserId ? '/'+this.user.Id : '');
    }

    get action4Link() {
        return this.action4Url +''+ (this.action4UseUserId ? '/'+this.user.Id : '');
    }

    handleClick(evt) {

        let link = evt.detail.url;
        this.completeOnboarding();
        this.goToUrl(link);
    }

    completeOnboarding() {

        const doneClickEvent = new CustomEvent('doneclick', {
            detail: {
                        message: 'Close',
                        slide: 'Done'
                    }
        });
        this.dispatchEvent(doneClickEvent);
    }

    goBack() {

        const doneBackClickEvent = new CustomEvent('donebackclick', {
            detail: {
                        message: '12',
                        slide: ''
                    }
        });
        this.dispatchEvent(doneBackClickEvent);
    }

    goToProfile() {

        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "/s/profile/" + this.user.Id
            }
        });
    }

    goToUrl(link) {

        this[NavigationMixin.GenerateUrl]({
            "type": "standard__webPage",
            "attributes": {
                "url": link
            }
        });
    }
}