/*
 * Copyright (c) 2021. 7Summits, an IBM Company. All rights reserved.
 */


import {LightningElement, api, track, wire} from 'lwc';
import cureentDeviceScreen from '@salesforce/client/formFactor';

import {loadStyle} from 'lightning/platformResourceLoader';
import cssResource from '@salesforce/resourceUrl/x7sCommunityOnboardingResource';

import {CurrentPageReference} from 'lightning/navigation';
import {fireEvent} from 'c/x7sShrUtils';

import completeSlide from '@salesforce/apex/x7sOnboardingController.completeSlide';
import IsModalViewEnabled from '@salesforce/apex/x7sOnboardingController.getIsModalViewEnabled';
import grabTopics from '@salesforce/apex/x7sOnboardingController.grabTopics';
import currentUserRecord from '@salesforce/apex/x7sOnboardingController.getUserRecord';
import memberEmailPreference from '@salesforce/apex/x7sOnboardingController.getMemberEmailPreference';
import metaDisplayLimit from '@salesforce/apex/x7sOnboardingController.getDisplayLimit';
import termsAndConditions from '@salesforce/apex/x7sOnboardingController.getCommunityTermsAndConditions';

export default class X7sOnboarding extends LightningElement {

    @wire(CurrentPageReference) pageRef;

    @api recordId;
    @api currentUserRecord;
    @api userId = '';

    // Modal Display Limit
    @api userModalDisplayCount = 0;
    @api metaDisplayLimit;
    @api metaDisplayException;
    @api profileName;

    @api displayOnboardingSection = false;
    @api displaySteps;
    @api displayBye = false;
    @api page = '1';
    @api progressAndLabelColor = '#01a5b5';
    @api isModalViewEnabled = false;
    @api displayWelcome = false;
    @api emailPreference = false;
    @api closeModalByUser = false;
    @api totalSteps = 0;
    @api displayTopics = false;
    @api displayGroups = false;
    @api displayTours = false;
    @api displayCompleted = false;
    @api displayNotifications = false;
    @api notificationChkByUser;

    @api topicSlides = [];
    @api currentSlide;
    @api numberOfTopicSlides;
    @api topicSlideIndex;

    topicSlidesList = [];
    topicSlideNumber = 0;
    index = 0;

    /* ---- Builder Properties ---- */
    @api displayMode;
    @api usedOnProfilePage;
    @api linearNavigationOnly;
    @api showProgressWhenComplete;
    @api progressHeading;
    @api progressMessage;

    //Step 0 Attributes
    @api headerText;
    @api buttonColor;
    @api nextButtonLabel;
    @api backButtonLabel;
    @api byeForNowHeader;
    @api byeForNowMessage;
    @api hideOnboardingModal;
    @api closeButtonLabel;

    //Step 1 Attributes
    @api showStep1;
    @api step1Label;
    @api welcomeHeader;
    @api welcomeMessage;
    @api showTermsAndConditions;
    @api termsAndConditionsPrompt;
    @api agreeToTermsAndConditionsLabel;
    @api useCustomMetadataForTOC;
    @api termsAndConditionsText;
    @api beginButtonLabel;

    //Step 2 Attributes
    @api showStep2;
    @api step2Label;
    @api profileHeader;
    @api profileMessage;
    @api profileAction;
    @api showFirstName;
    @api firstNameLabel;
    @api showLastName;
    @api lastNameLabel;
    @api showTitle;
    @api titleLabel;
    @api showCompany;
    @api companyLabel;
    @api showEmail;
    @api emailLabel;
    @api showMobile;
    @api mobileLabel;
    @api showNickname;
    @api nicknameLabel;
    @api showAboutMe;
    @api aboutMeLabel;
    @api showAvatarUpload;
    @api dropFileLabel;
    @api acceptableAvatarFileTypes;

    //Step 3 Attributes
    @api showStep3;
    @api step3Label;
    @api additionalSlideHeader;
    @api additionalSlideMessage;
    @api additionalSlideLabel;
    @api additionalSlideUserFieldName1;
    @api additionalSlideUserFieldLabel1;
    @api additionalSlideUserFieldTooltip1;
    @api additionalSlideUserFieldName2;
    @api additionalSlideUserFieldLabel2;
    @api additionalSlideUserFieldTooltip2;

    //Step 4 Attributes
    @api showStep4;
    @api useTopicMetadata;
    @api step4Label;
    @api topicsHeader;
    @api topicsMessage;
    @api topicsAction;
    @api group1TopicLabel;
    @api topics;
    @api group2TopicLabel;
    @api topicsProduct;

    //Step 5 Attributes
    @api showStep5;
    @api step5Label;
    @api groupsHeader;
    @api groupsMessage;
    @api groupsAction;
    @api showGroupDescription;
    @api groupIDs;

    //Step 6 Attributes
    @api showStep6;
    @api step6Label;
    @api notificationHeader;
    @api notificationMessage;
    @api notificationAction;
    @api notificationInfoUrl;
    @api notificationLinkLabel;
    @api notificationUser;
    @api notificationText;

    //Step 7 Attributes
    @api showStep7;
    @api videoAlign;
    @api step7Label;
    @api toursHeader;
    @api toursMessage;
    @api videoType1;
    @api videoUrl1;
    @api videoTitle1;
    @api videoIframeTitleForAria;
    @api videoDescription1;
    @api tourEndButtonLabel;

    //Step 8 Attributes
    @api showStep8;
    @api newTabLink;
    @api step8Label;
    @api doneHeader;
    @api doneMessage;
    @api doneAction;
    @api action1Icon;
    @api action1Text;
    @api action1Description;
    @api action1Url;
    @api action1UseUserId;
    @api action2Icon;
    @api action2Text;
    @api action2Description;
    @api action2Url;
    @api action2UseUserId;
    @api action3Icon;
    @api action3Text;
    @api action3Description;
    @api action3Url;
    @api action3UseUserId;
    @api action4Icon;
    @api action4Text;
    @api action4Description;
    @api action4Url;
    @api action4UseUserId;
    @api completeButtonLabel;

    test;
    @track error;
    received = [];

    /*get allowComponentToRender() {
        return !((this.recordId === this.userId && this.usedOnProfilePage) || this.usedOnProfilePage);
    }*/
    get allowComponentToRender() {
        return ((this.recordId === this.userId && this.usedOnProfilePage) || !this.usedOnProfilePage);
    }

    get displayProgressSection() {
        return (this.displayMode === 'Show Progress On Page' && (this.showProgressWhenComplete || !this.currentUserRecord.X7S_Onboarding_Complete__c));
    }

    get progressMessageText() {
        return this.progressMessage;
    }

    get progressHeadingText() {
        return this.progressHeading;
    }

    get onboardingSectionContainerClass() {
        return this.isModalViewEnabled ? 'slds-modal slds-fade-in-open slds-modal_medium' : 'onboarding_on-page';
    }

    get stepsCloseButton() {
        return (this.displaySteps && this.page != '8');
    }

    get byeCloseButton() {
        return (this.displayBye && this.page != '8');
    }

    get modalCloseButton() {
        return (this.page === '8');
    }

    get slideClass() {
        // DESKTOP or PHONE
        return 'slds-modal__content ' + (cureentDeviceScreen === 'Large' ? 'slds-p-around_medium' : 'slds-p-around--small');
    }

    get indicatorClass() {
        return this.linearNavigationOnly ? 'pointerEvent' : '';
    }

    get isPage1() {
        return this.page === '1';
    }

    get isPage2() {
        return this.page === '2';
    }

    get isPage3() {
        return this.page === '3';
    }

    get isPage4() {
        return this.page === '4';
    }

    get isPage9() {
        return this.page === '9' && this.showStep5;
    }

    get isPage10() {
        return this.page === '10' && this.showStep6;
    }

    get isPage11() {
        return this.page === '11' && this.showStep7;
    }

    get isPage12() {
        return this.page === '12' && this.showStep8;
    }

    connectedCallback() {
        loadStyle(this, cssResource);
        this.displaySteps = true;
        this.retrieveIsModalViewEnabled();
    }

    retrieveIsModalViewEnabled() {
        IsModalViewEnabled()
            .then((result) => {
                console.log('modal view result: ' + result);
                if (typeof result === 'boolean') {
                    this.isModalViewEnabled = result;
                }

                this.getUserRecord();
            })
            .catch((err) => {
                this.error = err;
                console.error('IsModalViewEnabled Failed:' + JSON.stringify(err));
            });
    }

    getUserRecord() {
        this.getEmailPreference();
        this.getMetaDisplayLimit();
        this.getTermsAndConditions();

        currentUserRecord()
            .then(result => {
                console.log(result);
                if (result) {
                    this.currentUserRecord = result;
                    this.userId = this.currentUserRecord.Id.substring(0, 15);

                    //get onboarding modal display count from user
                    this.userModalDisplayCount = this.currentUserRecord.X7S_Onboarding_Modal_Display_Count__c;
                    this.profileName = this.currentUserRecord.Profile.Name;
                    this.closeModalByUser = this.currentUserRecord.X7S_Hide_Modal_Onboarding__c;
                    this.notificationChkByUser = this.currentUserRecord.X7S_Notification_Confirmation__c;

                    if(this.currentUserRecord.X7S_Onboarding_Complete__c) {
                        this.displayOnboardingSection = false;
                        return;
                    }
                    if (this.userModalDisplayCount === undefined) {
                        this.displayOnboardingSection = true;
                        this.setUserModalDisplayCount();
                        return;
                    }
                    if (this.isModalViewEnabled) {
                        if (this.userModalDisplayCount <= this.metaDisplayLimit &&
                            !this.showProgressWhenComplete && // WEG-1290 - don't auto-display modal on profile page - martin.blase
                            this.closeModalByUser === false &&
                            (this.metaDisplayException === undefined || this.metaDisplayException.includes(this.profileName))) {

                            this.displayOnboardingSection = true;
                            this.displayLimit();
                            return;
                        }
                        if (this.userModalDisplayCount >= this.metaDisplayLimit || this.closeModalByUser === true) {
                            this.displayOnboardingSection = false;
                            return;
                        }
                    }
                    // if user is on the own page for Onboarding, the flow should always start at screen 1
                    if (this.displayMode === 'Always Show Onboarding') {
                        this.displayOnboardingSection = true;
                        this.page = '1';
                    }
                    // if user is on home page, flow should only pop up if the user hasn't completed it.  The user should also be directed to the first slide they haven't completed (if they login, complete part of the onboarding process, then log back in later)
                    else if (!this.currentUserRecord.X7S_Onboarding_Complete__c) {
                        this.displayOnboardingSection = true;

                        //set the current page to the first uncompleted page
                        if (!this.currentUserRecord.X7S_Completed_Welcome_Slide__c) {
                            this.page = '1';
                        } else if (!this.currentUserRecord.X7S_Completed_Profile_Slide__c) {
                            this.page = '2';
                        } else if (!this.currentUserRecord.X7S_Completed_Additional_User_Data__c) {
                            this.page = '3';
                        } else if (!this.currentUserRecord.X7S_Completed_Topics_Slide__c) {
                            this.page = '4';
                        } else if (!this.currentUserRecord.X7S_Completed_Groups_Slide__c) {
                            this.page = '9';
                        } else if (!this.currentUserRecord.X7S_Completed_Notification_Slide__c) {
                            this.page = '10';
                        } else if (!this.currentUserRecord.X7S_Completed_Tours_Slide__c) {
                            this.page = '11';
                        } else if (!this.currentUserRecord.X7S_Onboarding_Complete__c) {
                            this.page = '12';
                        } else {
                            this.page = '1';
                        }
                    }

                    this.topicSlideRetrieval();
                }
            })
            .catch(err => {
                this.error = err;
                console.log('getUserRecord Failed:' + JSON.stringify(err));
            });

        let excludeSteps = '';

        if (!this.showStep1) {
            excludeSteps += "Welcome "
            console.log("Marking step 1 (Welcome) as complete.");
        }
        if (!this.showStep2) {
            excludeSteps += "Profile "
            console.log("Marking step 2 (Profile) as complete.");
        }
        if (!this.showStep3) {
            excludeSteps += "Additional "
            console.log("Marking step 3 (Additional User Data) as complete.");
        }
        if (!this.showStep4) {
            excludeSteps += "Topic "
            console.log("Marking step 4 (Topic) as complete.");
        }
        if (!this.showStep5) {
            excludeSteps += "Group "
            console.log("Marking step 5 (Group) as complete.");
        }
        if (!this.showStep6) {
            excludeSteps += "Notification "
            console.log("Marking step 6 (Notification) as complete.");
        }
        if (!this.showStep7) {
            excludeSteps += "Tours "
            console.log("Marking step 7 (Tours) as complete.");
        }
        if (!this.showStep8) {
            excludeSteps += "Done "
            console.log("Marking step 8 (Done) as complete.");
        }

        if (excludeSteps && excludeSteps !== "") {
            let stepList = [] = excludeSteps.trim().split(" ");
            let currentStep;

            if (stepList.length > 0) {
                for (currentStep = 0; currentStep < stepList.length; currentStep++) {

                    completeSlide({slide: stepList[currentStep]})
                        .then(() => {
                        })
                        .catch((err) => {
                            this.error = err;
                            console.log('excludeSteps Failed:' + JSON.stringify(err));
                        });
                }
            }
        }
    }

    topicSlideRetrieval() {
        this.page = '1';
        let useMetadata = this.useTopicMetadata;
        if (useMetadata) {

            grabTopics()
                .then((result) => {
                    let topics = result;
                    this.topicSlides = topics;
                    let numberTopicSlides = topics.length;
                    this.numberOfTopicSlides = topics.length;
                    if (numberTopicSlides > 0) {
                        this.currentSlide = topics[0];
                        this.topicSlideIndex = 0;
                    }

                    this.topicSlidesList = this.topicSlides.map((parentLabel, pageIndex) => {
                        return {parentLabel, pageNo: pageIndex + 4 + ''};
                    });

                    this.countTotalSteps();
                })
                .catch((err) => {
                    this.error = err;
                    console.log('topicSlideRetrieval Failed:' + JSON.stringify(err));
                });

        } else {
            this.countTotalSteps();
        }
    }

    handlePageChange(event) {

        let completedSlide = event.detail.slide;
        let pageNumber = event.detail.message;
        console.log('handlePageChange :' + completedSlide, pageNumber);

        // if "message" equals "close", the user has just completed the entire modal, so the 'Complete_Modal__c' field should be checked and the modal closed
        if (pageNumber === 'Close') {

            completeSlide({slide: completedSlide})
                .then((result) => {
                    console.log('success:pageChange:close');
                    this.page = pageNumber;
                })
                .catch((err) => {
                    this.error = err;
                    console.log('handlePageChange Failed:' + JSON.stringify(err));

                });

            this.closeModal(event);

            // if "slide' is not blank, the user just completed a slide, and the database needs to be called to check the corresponding field on the User record
        } else if (completedSlide !== '') {

            if (completedSlide === 'Topic') {
                let topicSlides = this.topicSlides;
                let topicIndex = this.topicSlideIndex;

                topicIndex = topicIndex + 1;
                if (topicIndex < topicSlides.length) {
                    this.topicIndex = topicIndex;
                    this.handleNextStepChange(pageNumber);
                    return;
                }
            }
            completeSlide({slide: completedSlide})
                .then((result) => {
                    console.log('success:pageChange:' + completedSlide);
                    this.handleNextStepChange(pageNumber);
                })
                .catch((err) => {
                    this.error = err;
                    console.log('handlePageChange Failed:' + err);

                });

            // if "slide" is blank, the user is going back to a previous screen and therefore the database doesn't need to be called to check a slide complete field on the User record.
        } else {
            this.handlePreviousStepChange(pageNumber);
            // this.page = pageNumber);
        }
    }

    handleProgressClick(event) {

        if (this.isModalViewEnabled) {
            this.openSlide(event);
            if (this.closeModalByUser !== true) {
                this.openSlide(event);
                if (this.metaDisplayLimit === 0 || this.metaDisplayLimit === undefined) {
                    this.openSlide(event);
                } else if (this.metaDisplayLimit > 1) {
                    if (this.userModalDisplayCount < this.metaDisplayLimit) {
                        if (!this.metaDisplayException || !this.metaDisplayException.includes(this.profileName)){
                            this.userModalDisplayCount += 1;
                            console.log('====After Increment====' + this.userModalDisplayCount);
                            this.displayLimit();
                            this.openSlide(event);
                        } else {
                            this.openSlide(event);
                        }
                    }
                }
            }
        } else {
            this.openSlide(event);
        }
    }

    handleNextStepChange(pageNumber) {

        console.log('handleNextStepChange:pageNumber ==> ', pageNumber);

        let topicSlides = this.topicSlides;
        let current = this.currentSlide;

        if ((pageNumber === '1' || pageNumber === '0') && this.showStep1) {
            this.page = '1';
            this.displayTopics = false;
        } else if (pageNumber <= 2 && this.showStep2) {
            this.page = '2';
            this.displayTopics = false;
        } else if (pageNumber <= 3 && this.showStep3) {
            this.page = '3';
            this.displayTopics = false;
        } else if (pageNumber <= 4 && this.showStep4) {
            this.page = '5';
            this.page = '4';
            this.displayTopics = true;
            if (this.useTopicMetadata) {
                this.topicSlideIndex = 0;
                this.currentSlide = topicSlides[0];
            }
        } else if (pageNumber === 5 || pageNumber === '5') {

            if (this.useTopicMetadata) {
                let topicIndex = this.topicSlideIndex;

                if (topicIndex + 1 < this.numberOfTopicSlides) {
                    let newTopicIndex = topicIndex + 1;
                    this.currentSlide = topicSlides[newTopicIndex];

                    fireEvent(this.pageRef, 'topicSlideEvent', this.currentSlide);

                    this.topicSlideIndex = newTopicIndex;
                    newTopicIndex = newTopicIndex + 4;
                    let topicIndexString = newTopicIndex.toString();

                    this.page = topicIndexString;
                    this.displayTopics = false;
                    this.displayTopics = true;
                } else {
                    this.displayTopics = false;
                    if (this.showStep5) {
                        this.page = '9';
                    } else if (this.showStep6) {
                        this.page = '10';
                    } else if (this.showStep7) {
                        this.page = '11';
                    } else if (this.showStep8) {
                        this.page = '12';
                    }
                }
            } else {
                this.displayTopics = false;
                if (this.showStep5) {
                    this.page = '9';
                } else if (this.showStep6) {
                    this.page = '10';
                } else if (this.showStep7) {
                    this.page = '11';
                } else if (this.showStep8) {
                    this.page = '12';
                }

            }
        } else if (pageNumber <= 9 && this.showStep5) {
            this.page = '9';
            this.displayTopics = false;
        } else if (pageNumber <= 10 && this.showStep6) {
            this.page = '10';
        } else if (pageNumber <= 11 && this.showStep7) {
            this.page = '11';
        } else if (pageNumber <= 12 && this.showStep8) {
            this.page = '12';
        }
    }

    handlePreviousStepChange(pageNumber) {

        console.log('handlePreviousStepChange:pageNumber', pageNumber);

        let useTopicMetadata = this.useTopicMetadata;
        let topicIndex = this.topicSlideIndex;
        let topicSlides = this.topicSlides;

        if (pageNumber >= 11 && this.showStep7) {
            this.displayTopics = false;
            this.page = '11';
        } else if (pageNumber >= 10 && this.showStep6) {
            this.displayTopics = false;
            this.page = '10';
        } else if (pageNumber >= 9 && this.showStep5) {
            this.displayTopics = false;
            this.page = '9';
        } else if (pageNumber >= 4 && this.showStep4) {

            if (useTopicMetadata) {
                let numberOfTopicSlides = this.numberOfTopicSlides;
                if (numberOfTopicSlides > 0) {
                    topicIndex = numberOfTopicSlides - 1;
                    this.topicSlideIndex = topicIndex;
                    this.currentSlide = topicSlides[topicIndex];

                    let topicSlideIndexString = (topicIndex + 4).toString();
                    this.page = topicSlideIndexString;
                }
            } else {
                this.page = '4';
            }
            this.displayTopics = true;
        } else if ((pageNumber >= 3 && this.showStep3) ||
            (pageNumber >= 3 && useTopicMetadata && topicIndex > 0)) {

            this.page = '3';
            this.displayTopics = false;
            if (useTopicMetadata && topicIndex > 0) {

                topicIndex = topicIndex - 1;
                this.topicSlideIndex = topicIndex;
                topicSlides = this.topicSlides;
                this.currentSlide = topicSlides[topicIndex];

                fireEvent(this.pageRef, 'topicSlideEvent', this.currentSlide);

                topicIndex = topicIndex + 4;
                let topicSlideIndexString = topicIndex.toString();
                this.page = topicSlideIndexString;
                this.displayTopics = true;
            }
        } else if (pageNumber >= 2 && this.showStep2) {
            this.displayTopics = false;
            this.page = '2';
        } else if (pageNumber >= 1 && this.showStep1) {
            this.displayTopics = false;
            this.page = '1';
        }
    }

    openSlide(event) {

        this.displayBye = false;
        this.displaySteps = true;

        let completedSlide = event.detail.slide;
        let pageNumber = event.detail.message;

        if (completedSlide === 'Topic') {

            if (this.useTopicMetadata) {
                let topicSlides = this.topicSlides;

                let topicIndex = pageNumber - 5;
                this.topicSlideIndex = topicIndex;

                if (topicIndex < topicSlides.length) {
                    let topicPageNo = '5';
                    this.handleNextStepChange(topicPageNo);
                    this.displayOnboardingSection = true;
                    return;
                }
            }
        }

        completeSlide({slide: completedSlide})
            .then((result) => {
                console.log('success:openSlide:' + completedSlide);
                this.handleNextStepChange(pageNumber);
                this.displayOnboardingSection = true;
            })
            .catch((err) => {
                this.error = err;
                console.log('openSlide Failed:' + err);
            });
    }

    countTotalSteps() {

        let count = 0;
        if (this.showStep1) {
            count++;
        }
        if (this.showStep2) {
            count++;
        }
        if (this.showStep3) {
            count++;
        }
        if (this.showStep4) {
            if (this.useTopicMetadata) {
                count = count + this.numberOfTopicSlides;
            } else {
                count++;
            }
        }
        if (this.showStep5) {
            count++;
        }
        if (this.showStep6) {
            count++;
        }
        if (this.showStep7) {
            count++;
        }
        if (this.showStep8) {
            count++;
        }
        this.totalSteps = count;
    }

    setUserModalDisplayCount() {

        completeSlide({slide: 'setDisplay'})
            .then((result) => {
                console.log('success:ModalDisplayCount');
            })
            .catch((err) => {
                this.error = err;
                console.log('ModalDisplayCount Failed:' + JSON.stringify(err));
            });
    }

    displayLimit() {

        completeSlide({slide: 'displayLimit'})
            .then((result) => {
                //console.log('success:displayLimit');
            })
            .catch((err) => {
                this.error = err;
                console.error('displayLimit Failed:' + JSON.stringify(err));
            });
    }

    getEmailPreference() {

        memberEmailPreference()
            .then((result) => {
                this.emailPreference = result.PreferencesDisableAllFeedsEmail;
            })
            .catch((err) => {
                this.error = err;
                console.log('getEmailPreference Failed:' + err);
            });
    }

    getMetaDisplayLimit() {

        metaDisplayLimit()
            .then((result) => {
                this.metaDisplayLimit = result.Modal_Display_Limit__c;
                this.metaDisplayException = result.Modal_Display_Limit_Exception__c;
            })
            .catch((err) => {
                this.error = err;
                console.log('getMetaDisplayLimit Failed:' + err);
            });
    }

    getTermsAndConditions() {

        if (this.useCustomMetadataForTOC) {
            if (this.showTermsAndConditions) {
                termsAndConditions()
                    .then((result) => {
                        this.termsAndConditionsText = result;
                    })
                    .catch((err) => {
                        this.error = err;
                        console.log('getTermsAndConditions Failed:' + err);
                    });
            }
        }
    }

    closeModal() {
        this.displayOnboardingSection = false;
    }

    closeModalFinal() {

        this.displayOnboardingSection = false;
        completeSlide({slide: 'Done'})
            .then((result) => {
                console.log('modal completed');
            })
            .catch((err) => {
                this.error = err;
                console.log('closeModal Failed ' + err);
            });
    }

    handleWelcomeClick() {
        this.page = '1';
        this.displayTopics = false;
    }

    handleProfileClick() {
        this.page = '2';
        this.displayTopics = false;
    }

    handleshowAdditionUserDataLabelClick() {
        this.page = '3';
        this.displayTopics = false;
    }

    handleTopicsClick(event) {
        console.log(event.target.value);
        let pageStep = event.target.value;

        if (this.useTopicMetadata) {

            this.currentSlide = this.topicSlides[pageStep - 4];
            fireEvent(this.pageRef, 'topicSlideEvent', this.currentSlide);

            this.displayTopics = false;
            this.page = pageStep;
            this.displayTopics = true;

        } else {
            this.page = '11';
        }
    }

    handleGroupsClick() {
        this.page = '9';
        this.displayTopics = false;
    }

    handleNotificationClick() {
        this.page = '10';
        this.displayTopics = false;
    }

    handleToursClick() {
        this.page = '4';
        this.displayTopics = false;
    }

    handleFinalizeClick() {
        this.page = '12';
        this.displayTopics = false;
    }

    toByeScreen() {
        this.displaySteps = false;
        this.displayBye = true;
    }

    goBackToOnboarding() {
        this.displaySteps = true;
        this.displayBye = false;
    }

}