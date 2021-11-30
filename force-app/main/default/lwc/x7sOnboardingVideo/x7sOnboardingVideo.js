/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api } from 'lwc';

export default class X7sOnboardingVideo extends LightningElement {

    @api type ='YouTube';
	@api videoId = '';
	@api title = 'First Video';
	@api description = 'Some great first content!';
    @api videoAlign;
    @api videoIframeTitleForAria = 'First Video';
    
    get isTypeYoutube() {
        return this.type === 'YouTube';
    }

    get isTypeVimeo() {
        return this.type === 'Vimeo';
    }

    get isTypeWistia() {
        return this.type === 'Wistia';
    }

    get isInfo() {
        return this.title || this.description;
    }

    get infoClass() {
        return this.videoAlign === 'Vertical' ? 'slds-align_absolute-center' : '';
    }

    get youtubeUrl() {
        return 'https://www.youtube.com/embed/'+ this.videoId +'?rel=0&amp;showinfo=0';
    }

    get vimeoUrl() {
        return 'https://player.vimeo.com/video/'+ this.videoId +'?title=0&amp;byline=0&amp;portrait=0';
    }

    get wistiaUrl() {
        return 'https://fast.wistia.net/embed/iframe/'+ this.videoId +'?videoFoam=true';
    }

    get iframeTitle() {
        return this.title && this.title.length > 0 ? this.title : this.videoIframeTitleForAria;
    }
}