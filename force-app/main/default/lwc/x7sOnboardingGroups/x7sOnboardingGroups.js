/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api } from 'lwc';

import currentUserId from '@salesforce/user/Id';
import updateFrequenv from '@salesforce/apex/x7sOnboardingController.updateFrequenv';
import joinGroup from '@salesforce/apex/x7sOnboardingController.joinGroup';
import leaveGroup from '@salesforce/apex/x7sOnboardingController.leaveGroup';
import getGroups from '@salesforce/apex/x7sOnboardingController.getGroups';

export default class X7sOnboardingGroups extends LightningElement {

    @api showUserSpecificGroups = false;
    @api groupsMessage;
    @api groupsHeader;
    @api groupsAction;
    @api showGroupDescription;
    @api groupIDs;
    @api groups;
    @api buttonColor = '#ff8201';
    @api userId = '';
    @api nextButtonLabel;
    @api backButtonLabel;

    connectedCallback() {

        this.showGroupDescription = 'true';
        this.userId = currentUserId;

        if(this.showUserSpecificGroups === true) {
            this.grabUserSpecific();
        } else {
            if(this.groupIDs && this.groupIDs !== '') {
                let groupIDsArray = this.groupIDs.split(",");

                if(groupIDsArray.length > 0) {
                    this.initGroups(groupIDsArray);
                }
            }
        }
    }

    goToNext() {
        const groupClickEvent = new CustomEvent ('groupclick', {
            detail: {
                        message: '10',
                        slide: 'Group'
                    }
        });
        this.dispatchEvent(groupClickEvent);
    }

    goBack() {
        const groupBackClickEvent = new CustomEvent ('groupbackclick', {
            detail: {
                        message: '4',
                        slide: ''
                    }
        });
        this.dispatchEvent(groupBackClickEvent);
    }

    handleGroupNotificationChange(event) {

        let groups = this.groups;
        const groupId = event.detail.id;
        const notificationFrequency = event.detail.value;

        groups.forEach(function(group) {
            if(group.id === groupId) {

                updateFrequenv({groupId : groupId, notification :notificationFrequency})
                    .then(result => {
                        console.log('Frequency: Updated Frequency');
                    })
                    .catch(err => {
                        console.log("handleGroupNotificationChange Failed : " + err);
                    });

                group.notificationFrequency = notificationFrequency;
            }
        });

        this.groups = groups;
    }

    handleGroupJoin(event) {

        let groups = this.groups;
        let receivedGroupId = event.detail.id;

        groups.forEach(function (group) {
            if(group.id === receivedGroupId) {

                joinGroup({groupId : receivedGroupId})
                    .then(result => {
                        console.log('Group: Joined Successfully');
                    })
                    .catch(err => {
                        console.log("handleGroupJoin Failed : " + err);
                    });
                
                group.following = true;
            }
        });

        this.groups = groups;
    }

    handleGroupRemove(event) {
        let groups = this.groups;
        const groupId = event.detail.id;

        groups.forEach(function (group) {
            if(group.id === groupId) {
                
                leaveGroup({groupId : groupId})
                    .then(result => {
                        console.log('Leave Group: Remove Successfully');
                    })
                    .catch(err => {
                        console.log("handleGroupRemove Failed : " + err);
                    });
                
                group.following = false;
            }
        });

        this.groups = groups;
    }

    initGroups(groupIds) {

        getGroups({groupIds:groupIds})
        .then(result => {
            let groups = result;
            if(groups.length > 0) {
                console.log('initGroups:groups', groups, groups.length);
                this.groups = groups;
            } else {
                console.log('No groups returned');
            }
        })
        .catch(err => {
            console.log("initGroups Failed : " + err);
        });
    }
}