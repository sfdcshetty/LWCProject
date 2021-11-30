/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */

import { LightningElement, api, wire } from 'lwc';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/x7sShrUtils';

export default class X7sOnboardingTopicButton extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    @api topicId;
    @api name;
    @api reveivedClass;
    @api following;
    @api followLabel = 'Follow topic';
    @api followIcon = 'utility:add';
    @api unfollowLabel = 'Unfollow topic';
    @api unfollowIcon = 'utility:check';
    @api loadingIcon = 'utility:spinner';
    @api _loading = false;

    connectedCallback() {
        registerListener("loadingEvent",  this.topicActionCompleted, this);
    }

    topicActionCompleted() {
        this._loading = false;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    get topicButtonClass() {
        return 'onboarding-topic ' + (this.following ? 'following' : 'follow') + ' ' + (this._loading ? '_loading' :  '');
    }

    get topicButtonAriaLabel() {
        return (this.following ? this.unfollowLabel : this.followLabel) + ' ' +this.name;
    }

    get topicButtonIconName() {
        return (this._loading ? this.loadingIcon : (this.following ? this.unfollowIcon : this.followIcon));
    }

    handleClick() {

        if(this.following) {
            this.handleUnfollow();
        } else {
            this.handleFollow();
        }
    }

    handleFollow() {

        this._loading = true;
        const followClick = new CustomEvent('followclick',{
            detail: {
                        value: 'follow',
                        id: this.topicId
                    }
        });
        this.dispatchEvent(followClick);
    }

    handleUnfollow() {

        this._loading = true;
        const unFollowClick = new CustomEvent('unfollowclick',{
            detail: {
                        value: 'unfollow',
                        id: this.topicId
                    }
        });
        this.dispatchEvent(unFollowClick);
    }
}