/**
 * Created by karolbrennan on 5/3/21.
 */

import {LightningElement, api} from 'lwc';
import getMyTeam from '@salesforce/apex/x7s_MyTeamController.getTeamMembersForCurrentUsersAdvisor';
import strUserId from '@salesforce/user/Id';

export default class X7SMyAdvisorTeam extends LightningElement {
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
        getMyTeam()
            .then((result) => {
                    myData = result;
                    console.log('advisorData2', myData);
                    for(let i=0; i<myData.length; i++){
                        let member = myData[i];

                        if(i==0){
                            this.advisorData.push(member);
                            this.showAdvisors = true;
                        } else if(i==1 && member.hasOwnProperty('type') && !member.type.toLowerCase().endsWith('list') && member.type === 'Secondary Advisor'){
                            this.advisorData.push(member);
                            this.showAdvisors = true;
                        } 
                        /*else if(member.hasOwnProperty('Title') && member.Title.toLowerCase().includes('Advisor')){
                            this.advisorData.push(member);
                        }*/ else {
                            this.serviceData.push(member);
                            this.showServiceData = true;
                        }
                        console.log('advisorData3', this.advisorData); 
                        this.advisorLength = this.advisorData.length;
                    }
                    
                
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