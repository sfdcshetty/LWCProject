import PARAGRAPH from '@salesforce/label/c.x7sFinancialProfile_AdvisorInfo_Header';
import getTeamMembersForCurrentUsersAdvisor from '@salesforce/apex/x7s_MyTeamController.getTeamMembersForCurrentUsersAdvisor';
//import getTeamMemberDetailsByUserId from '@salesforce/apex/x7s_MyTeamController.getTeamMemberDetailsByUserId'; 
//import USER_ID from '@salesforce/user/Id';
import { track, LightningElement } from 'lwc';

export default class X7sFinancialProfileAdvisorInfo extends LightningElement {
    debug = true;
    advisorName;
    advisorTitle;
    advisorEmail;
    advisorPhone;
    advisorPhotoUrl;
    get advisorEmailUrl() { return `mailto:${this.advisorEmail}`; }
    //get advisorPhoneUrl() { return `tel:${this.advisorPhone}`; }
    paragraph = PARAGRAPH;

    connectedCallback() {
        getTeamMembersForCurrentUsersAdvisor().then(result => {
            if (this.debug) console.log('getTeamMembersForCurrentUsersAdvisor result:',result);
            // just grab the first item in the array for now
            const advisor = result[0];
            this.advisorName = advisor.User.Name;
            this.advisorTitle = advisor.Title;
            this.advisorEmail = advisor.User.Email;
            this.advisorPhone = advisor.User.Phone;
            this.advisorPhotoUrl = advisor.photoUrl; // advisor.User.FullPhotoUrl
        }).catch(error => {
            console.error(error);
        });
    }

}