/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import { LightningElement, api, track, wire } from 'lwc';

import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/x7sShrUtils';

import getUserRecord from '@salesforce/apex/x7sOnboardingController.getUserRecord';
import updateUserNames from '@salesforce/apex/x7sOnboardingController.updateUserNames';
import getTopicsList from '@salesforce/apex/x7sOnboardingController.getTopics';
import followTopic from '@salesforce/apex/x7sOnboardingController.followTopic';
import unfollowTopic from '@salesforce/apex/x7sOnboardingController.unfollowTopic';


export default class X7sOnboardingTopics extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    @api user;
    @api items = '';

    @api topicsMessage;
    @api topicsHeader;
    @api topicsAction;
    
    @api topics1Ids;
    @api topics1 = [];

    @api topics2Ids;
    @api topics2 = [];

    @api currentSlide;
    @api topicSlides=[];

    @api chosenTopics=[];
    @api remainingTopics=[];
    @api leftoverTopics=[];
    
    @api group1TopicLabel;
    @api group2TopicLabel;
    @api followButtonLabel = 'Follow';
    @api followButtonIcon = 'utility:add';
    @api followingButtonLabel = 'Following';
    @api followingButtonIcon = 'utility:check';
    @api buttonColor ='#ff8201';
    @api useTopicMetadata = false;
    @api nextButtonLabel;
    @api backButtonLabel;
    @api retrivedTopics;

    
    get chosenTopicsnotBlank() {
        return this.chosenTopics.length > 0;
    }

    get isTopics1() {
        return ( this.topics1 && this.topics1.length );
    }

    get isTopics2() {
        return ( this.topics2 && this.topics2.length );
    }

    connectedCallback() {
     
        registerListener("topicSlideEvent",  this.getTopicsData, this);

        this.getUpdatedUserRecord();
        
        if(this.useTopicMetadata) {

            this.topicsMessage = this.currentSlide.message;
            this.topicsHeader = this.currentSlide.label;
            this.topicsAction = this.currentSlide.action;
            this.getFollowingTopic();
            
        } else {
            this.getTopics();
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getTopicsData(slide) {

        this.currentSlide = slide;
        this.topicsMessage = slide.message;
        this.topicsHeader = slide.label;
        this.topicsAction = slide.action;

        this.getFollowingTopic();
    }

    goToNext() {

        let user = this.user;
		let followingTopics = this.topicSlides;

        for (let i = 0; i < followingTopics.length; i++) {
			user.X7S_Last_Topic_Slide_Completed__c = followingTopics[i].parentLabel;
		}
		this.user = user;

        updateUserNames({currentUser:this.user})
            .then(result => {
                console.log('Success - updateUserNames');
            })
            .catch(err => {
                console.log("updateUserNames Failed : " + JSON.stringify(err));
            });

        const topicClick = new CustomEvent('topicclick',{
            detail: {
                        message : '12',
                        slide : 'Topic'
                    }
        });
        this.dispatchEvent(topicClick);
    }

    getTopics() {
        
        this.getTopicList('topics1');
        this.getTopicList('topics2');
    }

    getTopicList(topicsToRetrieve) {

        let topicIDs;
        if( topicsToRetrieve === 'topics1' ) { topicIDs = this.topics1Ids; }
        else if( topicsToRetrieve === 'topics2' ) { topicIDs = this.topics2Ids; }

        if (topicIDs && topicIDs !== '') {
            let topicsList = topicIDs.replace(/\s/g, '').split(',');

            getTopicsList({topicIds:topicsList})
                .then(result =>{

                    if(result) {

                        fireEvent(this.pageRef, 'loadingEvent', this);
                        this.retrivedTopics = result;
                        
                        if( topicsToRetrieve === 'topics1' ) {
                            this.topics1 = this.retrivedTopics;
                        } else if(topicsToRetrieve === 'topics2') {
                            this.topics2 = this.retrivedTopics;
                        }
                    }
                })
                .catch(err => {
                    console.log("getTopicList Failed : " + JSON.stringify(err));
                });
        }
    }

    goBack() {

        const topicBackClick = new CustomEvent('topicbackclick',{
            detail: {
                        message : '10',
                        slide : ''
                    }
        });
        this.dispatchEvent(topicBackClick);
    }

    handleFollowTopic(event) {

        let reveivedTopicId = event.detail.id;
        this.userFollowTopic(reveivedTopicId);
    }

    userFollowTopic(topicId) {

        if (!topicId || topicId === '') {
			topicId = event.target.name;
        }

        followTopic({topicId:topicId})
            .then(result => {
                console.log('success - userFollowTopic');

                let useTopicMetadata = this.useTopicMetadata;
                if(useTopicMetadata) {

                    let chosenTopics = this.chosenTopics;
					let remainingTopics = this.remainingTopics;
                    let leftoverTopics = this.leftoverTopics;
                    
					for (let i = 0; i < remainingTopics.length; i++) {
						if (remainingTopics[i].id === topicId) {
							chosenTopics.push(remainingTopics[i]);
							if (leftoverTopics && leftoverTopics.length > 0) {
								remainingTopics.splice(i, 1, leftoverTopics[0]);
								leftoverTopics.splice(0, 1);
							} else {
								remainingTopics.splice(i, 1);
							}
						}
					}
					this.chosenTopics = chosenTopics;
					this.remainingTopics = remainingTopics;
					this.leftoverTopics = leftoverTopics;
                } else {
                    //after the topic follow is committed, re initialize the two lists in the component so the state updates to 'Follow' or 'Followed'
                    this.getTopics();
                }
            })
            .catch(err => {
                console.log("userFollowTopic Failed : " + err);
            });
    }

    handleUnfollowTopic(event) {

        let reveivedTopicId = event.detail.id;
        this.userUnfollowTopic(reveivedTopicId);

    }

    userUnfollowTopic(topicId) {
        
        unfollowTopic({topicId:topicId})
            .then(result => {
                console.log('success - userUnfollowTopic');
                //after the topic follow deletion is committed, re initialize the two lists in the component so the state updates to 'Follow' or 'Followed'

                if (!this.useTopicMetadata) {
					this.getTopics();
                }
            })
            .catch(err => {
                console.log("userUnfollowTopic Failed : " + err);
            });
    }

    handleRemove(event) {

        let topicId = event.target.name;
        let currentSlide = this.currentSlide;

        // Remove the pill from view
        let chosenTopics = this.chosenTopics;
        let remainingTopics = this.remainingTopics;
        let leftoverTopics = this.leftoverTopics;

        for(let i = 0; i < chosenTopics.length; i++) {

            if(chosenTopics[i].id === topicId) {

                let removeTopic = {
                    following:false,
                    id:chosenTopics[i].id,
                    name: chosenTopics[i].name
                };

                if(remainingTopics.length < currentSlide.maxTopics) {
                    remainingTopics.push(removeTopic);
                } else {
                    leftoverTopics.push(removeTopic);
                }
                chosenTopics.splice(i, 1);
            }
        }

        this.chosenTopics = chosenTopics;
        this.remainingTopics = remainingTopics;
        this.leftoverTopics = leftoverTopics;
        this.userUnfollowTopic(topicId);
    }

    setCurrentSlideData() {

        for (let i = 0; i < this.topicSlides.length; i++) {
			if (this.topicSlides[i].parentLabel === 'Topics') {
                this.currentSlide = this.topicSlides[i];
				break;
			}
		}
    }

    getFollowingTopic() {

        let currentSlide = this.currentSlide;

        let allTopics = currentSlide.topics;
        let remainingTopics = [];
        let chosenTopics = [];
        let leftoverTopics = [];

        for (let i = 0; i < allTopics.length; i++) {
            if (allTopics[i].following === true) {
                chosenTopics.push(allTopics[i]);
            } else {
                if (remainingTopics.length < currentSlide.maxTopics) {
                    remainingTopics.push(allTopics[i]);
                } else {
                    leftoverTopics.push(allTopics[i]);
                }
            }
        }

        this.remainingTopics = remainingTopics;
        this.chosenTopics = chosenTopics;
        this.leftoverTopics = leftoverTopics;

    }

    getUpdatedUserRecord() {
        //update user record so we do not lose any changes from previous step

        getUserRecord()
        .then(result =>{
            this.user = result;
            console.log('User ==> '+JSON.stringify(this.user));
        })
        .catch(err => {
            console.log("getUpdatedUserRecord Failed: " + err);
        });
    }

}