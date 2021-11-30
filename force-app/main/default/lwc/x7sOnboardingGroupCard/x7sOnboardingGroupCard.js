/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api } from 'lwc';

export default class X7sOnboardingGroupCard extends LightningElement {

    @api groupId;
    @api name;
    @api description;
    @api userId;
    @api ownerId;
    @api showGroupDescription;
    @api joined;
    @api notificationSetting = 'P';

    get options() {
        
        return [
            { label: 'On Every Post', value: 'P' },
            { label: 'Daily', value: 'D' },
            { label: 'Weekly', value: 'W' },
            { label: 'Never', value: 'N' }
        ];
    }

    connectedCallback() {
        this.showGroupDescription = true;
    }

    get showDescription() {
        return (this.description && this.showGroupDescription);
    }

    get notOwner() {
        return this.userId !== this.ownerId;
    }

    handleRemove() {
        const removeclickEvent = new CustomEvent ('removeclick', {
            detail: {
                        value: 'remove',
                        id: this.groupId
                    }
        });
        this.dispatchEvent(removeclickEvent);
    }

    handleJoin() {
        const joinClickEvent = new CustomEvent ('joinclick', {
            detail: {
                        value: 'join',
                        id: this.groupId
                    }
        });
        this.dispatchEvent(joinClickEvent);
    }

    handleNotificationSettingChange(evt) {
        const changeClickEvent = new CustomEvent ('changeclick', {
            detail: {
                        value: evt.detail.value,
                        id: evt.detail.groupId
                    }
        });
        this.dispatchEvent(changeClickEvent);
    }
}