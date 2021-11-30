import { LightningElement, wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {CurrentPageReference} from 'lightning/navigation';
import getMyMemberDetails from '@salesforce/apex/x7s_MyTeamController.getTeamMemberDetailsByUserId';
import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";


export default class X7sWegMyTeamDetail extends NavigationMixin(LightningElement) {
    idToFetch;
    goBackToTeamsUrl;
    teamMemberName = "";
    teamMemberPosition = "";
    showPosition = false;
    emailIcon =  WEG_LOGO_PATH + '/WEG_Assets/icons/email-icon.png';
    phoneIcon = WEG_LOGO_PATH + '/WEG_Assets/icons/phone-icon.png';
    linkedInIcon = WEG_LOGO_PATH + '/WEG_Assets/icons/linked-in-icon.png';
    emailAddress = "";
    showEmail = false;
    phoneNumber = "";
    showPhone = false;
    linkedInProfile = "";
    showLinkedin = false;
    userBio = "";
    teamPhoto;
    
    recordId; // recordId from URL parameter
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        
        // get the value of the URL parameter(s) passing the 'state' attribute of the navigation mixin
        this.recordId = currentPageReference.state.recordId; 
        if(this.recordId) this.idToFetch = this.recordId;
        let recordSplit = this.idToFetch.split('-');
        this.idToFetch = recordSplit[0];
    }

    connectedCallback(){
        this.getMyMemberDetail();
        this.connected = true;

        this[NavigationMixin.GenerateUrl]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'My_Team__c'
                }
            
          }).then(result => {
            this.goBackToTeamsUrl = result;
        });
        this.checkDetails(); 
    }

    getMyMemberDetail(){
        getMyMemberDetails( {userId: this.idToFetch} )
        .then((result) => {
            if(result) {
                let myInfo = result;
                let photoUrl = '/clientportal/profilephoto/005/M';
                if(myInfo.Photo_URL__c){
                    photoUrl = myInfo.Photo_URL__c;
                    this.advisorPhoto = myInfo.Photo_URL__c;
                }
                
                //console.log('myinfo', myInfo);

                this.teamMemberName = myInfo.Name;
                
                if(myInfo.Team_Phone__c){
                    this.teamMemberPosition = myInfo.Portal_Team_Role__c;
                    this.showPosition = true;
                }
                if(myInfo.Email){
                    this.emailAddress = myInfo.Email;
                    this.showEmail = true;
                }
                if(myInfo.Team_Phone__c){
                    this.phoneNumber = myInfo.Team_Phone__c;
                    this.showPhone = true;
                }
                if(myInfo.LinkedIn_URL__c){
                    this.linkedInProfile = myInfo.LinkedIn_URL__c;
                    this.showLinkedin = true;
                }
                if(myInfo.Team_Bio__c){
                    this.userBio = myInfo.Team_Bio__c;
                }
            }
        })
        .catch((error) => {
            this.error = error;
            //console.log('error', error);
        });
    }

    checkDetails(){
        if(this.emailAddress.length > 0) {
            this.showEmail = true;
        }
        if(this.phoneNumber.length > 0) {
            this.showPhone = true;
        }
        if(this.linkedInProfile.length > 0) {
            this.showLinkedin = true;
        }   
    }

    goToLinkedInHref(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.linkedInProfile
            }
          }).then(result => {
            window.open(result, "_blank");
          });
    }
    
}