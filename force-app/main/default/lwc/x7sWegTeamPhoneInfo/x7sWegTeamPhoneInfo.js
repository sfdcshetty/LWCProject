import {LightningElement, api} from 'lwc';
import getMyTeamInfo from '@salesforce/apex/x7s_MyTeamController.getTeamOwnerPhone';
import strUserId from '@salesforce/user/Id';

export default class X7sWegTeamPhoneInfo extends LightningElement {
    teamPhoneNumber;
    @api layoutType = 'homepage';
    @api myTeamLink = '/clientportal/s/my-team';
    @api secureMessagingLink;

    advisorData=[];
    count;
    showAdvisors = false;
    serviceData=[];
    showServiceData = false;
    myId;
    advisorLength;

    connectedCallback(){
        this.myId = strUserId;
        this.getTeamData();
        this.count = this.showAdvisorCount();
    }

    getTeamData(){
        let myData;
        getMyTeamInfo({userId:this.myId})
            .then((result) => {
                    myData = result;
                    this.teamPhoneNumber = myData[0].User.Team_Phone__c;
            })
            .catch((error) => {
                this.error = error;
                console.log('error', error);
            });

    }

    showAdvisorCount() {
        return this.advisorData.length;
    }

    get isHomepageLayout(){
        return this.layoutType === 'homepage';
    }

    get isFullLayout(){
        return this.layoutType === 'full';
    }

    get isCompactLayout(){
        return this.layoutType === 'compact';
    }
}