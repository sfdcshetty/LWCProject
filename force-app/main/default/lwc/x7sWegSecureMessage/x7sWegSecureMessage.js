import { LightningElement, api } from 'lwc';
import getMyTeam from '@salesforce/apex/x7s_MyTeamController.getTeamMembersForCurrentUsersAdvisor';
import getMessages from '@salesforce/apex/wv6_NewAndReplyToSMCtrl.getClonedRecordByUser';
import getUserInfo from '@salesforce/apex/x7sWEGUtilities.getUserInfo';
import getAccountInfo from '@salesforce/apex/x7sWEGUtilities.getAccountInfo';
import saveSMRecord from '@salesforce/apex/wv6_NewAndReplyToSMCtrl.saveNewSMRecord';
import strUserId from '@salesforce/user/Id';
import { showToast } from 'c/x7sShrUtils';

//import WEG_LOGO_PATH from "@salesforce/resourceUrl/WEG_Assets";

export default class X7sWegSecureMessage extends LightningElement {
    @api myparam;
    @api recordid;
    myId; 
    myMessages;
    seeMessageMode = true;
    sendMessageMode = false;
    isModalOpen = false;
    messageAuthor = "test";
    messageAuthorEmail = "test";
    messageSubject = "test";
    messageTarget = "test";

    Contact__c;
    Customer_User__c;
    Household_Account__c;
    Household_Account__r;
    Message__c;
    Name;
    Owner;
    OwnerId;
    OwnerName;
    AccountId;
    AccountName;

    //infoIcon = WEG_LOGO_PATH + "/WEG_Assets/icons/secure-message-info.png";
    //trashIcon = WEG_LOGO_PATH + "/WEG_Assets/icons/secure-message-trash.png";

    connectedCallback(){
        this.myId = strUserId;
        console.log('callback', this.myId);
        this.getMyUserAccountInfo();
        this.getMyTeamInfo();
        this.getMyMessages();
    }

    getMyUserAccountInfo(){
        getUserInfo()
        .then((result) => {
            let myUserInfo = result;
            //console.log('my User Info', myUserInfo);
            this.Contact__c = myUserInfo.ContactId;
            this.Customer_User__c = myUserInfo.Id;
            this.AccountId = myUserInfo.Contact.AccountId;
            this.Household_Account__c = myUserInfo.Contact.Account.WEGP1_Primary_Household__c;
            this.OwnerId = myUserInfo.Contact.Account.OwnerId; 
            this.getMyAccountInfo();
        })
        .catch((error) => {
            this.error = error;
            console.log('error in getMyUserAccountInfo', error);
        });
    }

    getMyAccountInfo(){
        //console.log('sending in', this.Household_Account__c);
        getAccountInfo({ accountId: this.Household_Account__c})
        .then((result) => {
            let myAccountInfo = result;
            this.AccountName = myAccountInfo.Name;
            //console.log('my Account Info', myAccountInfo);
        })
        .catch((error) => {
            this.error = error;
            //console.log('error', error);
        });
    }

    openModal(event) {
        //console.log('open modal', event.currentTarget.dataset.message);
        let idToCheck = event.currentTarget.dataset.message;
        this.messageTarget = event.currentTarget.dataset.message;
        
        for(let i=0; i<this.myMessages.length; i++){
            if(this.myMessages[i].Id === idToCheck){
                this.messageAuthor = this.myMessages[i].Created_By__c;
                this.messageAuthorEmail = this.myMessages[i].Created_By_Username__c;
                this.messageSubject = this.myMessages[i].Name;
                this.messageTarget = this.myMessages[i].Message__c;
            }
        }
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    getMyTeamInfo(){
        getMyTeam()
        .then((result) => {
            let myTeam = result;
            for(let i=0; i< myTeam.length; i++){
                if(myTeam[i].Title === "Primary Advisor"){
                    this.OwnerName = myTeam[i].User.Name
                }
            }
        })
        .catch((error) => {
            this.error = error;
            console.log('error', error);
        });

    }

    getMyMessages(){
        getMessages({contactId: this.Contact__c})
        .then((result) => {
            this.myMessages = result;
            console.log('mymessages', this.myMessages);
        })
        .catch((error) => {
            this.error = error;
            //console.log('error', error);
        });
    }

    sendNewMessage(){
        this.sendMessageMode = true;
        this.seeMessageMode = false;
    }

    seeMessages(){
        this.sendMessageMode = false;
        this.seeMessageMode = true;
    }

    sendMessage(){
        let mySubject = this.template.querySelector("[data-id='message-subject']");
        let myMessage = this.template.querySelector("[data-id='message-body']");
        
        let thisSm = {
        Contact__c: this.Contact__c,
        //Customer_User__c: this.Customer_User__c,
        Customer_User__c: this.OwnerId,
        Household_Account__c: this.Household_Account__c,
        Household_Account__r: {OwnerId: this.OwnerId, Name: this.AccountName, Id: this.Household_Account__c},
        Message__c: myMessage.value,
        Name: mySubject.value,
        Owner: {Name: this.OwnerName, Id: this.OwnerId},
        OwnerId: this.OwnerId
        };

        console.log('this is my secure message', thisSm);
        saveSMRecord({SMRecord:thisSm})
        .then((result) => {
            let myReturn = result;
            showToast('Successfully sent','Message sent.','success','pester');
            this.getMyMessages();
            console.log('apex res', myReturn);
        })
        .catch((error) => {
            console.log('fail', error);
            this.error = error;
            showToast('Problem with sending this message','Message not sent.','error','pester');
            console.log('error', error);
        });
        this.seeMessageMode = true;
        this.sendMessageMode = false;
    }

    showAdvisorCount() {
        return this.advisorData.length;
    }  
}