import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class X7sMyAdvisorTeamItem extends NavigationMixin(LightningElement) {
    @api id;
    @api photourl;
    @api username;
    @api title;
    @api bio;
    @api email;
    @api maillink;
    @api teamphone;
    @api mode;
    isHomepage = false;
    isCompact = false;
    isHomepageOrCompact = false;
    
    profilelink;
    showProfileLink = false;
    recordId;

    connectedCallback(){
        if(this.bio && this.bio.length > 0){
            this.createProfileLink(this.id);
            this.showProfileLink = true;
        }

        if(this.mode === "Homepage" || this.mode === "Compact"){
            this.isHomepageOrCompact = true;
            if(this.mode === "Compact"){
                this.isCompact = true;
            }
            if(this.mode === "Homepage"){
                this.isHomepage = true;
            }
        }
        console.log('connected');
    }

    get mailToLink(){
        return "mailto:"+this.email;
    }

    navigateToProfile(){

        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'My_Team_Detail__c'
            },
            state: { 
                recordId: this.id 
            }
        });
    }

    sendToTeam(){
        console.log('send to team');
    }

    createProfileLink(id){
          this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                id: id,
                name: 'My_Team_Detail__c',
                actionName: 'view'
            }
        }).then(result => {
            this.profilelink = result;
        });
    }
}