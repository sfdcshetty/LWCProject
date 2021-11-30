import { api,LightningElement } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';


export default class X7sWegUnifiButton extends NavigationMixin(LightningElement) {
    isModalOpen = false;
    @api title = 'Assets Overview';
    @api notice = 'This information is only available to Wealth Enhancement Group clients.';
    @api buttonLabel = 'Complete Financial Profile';
    @api documentVaultPageApi = 'Docuvault_Test__c';
    
    connectedCallback(){
    }

    openModal() {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    goToUnifi() {
        this[NavigationMixin.GenerateUrl]({
          type: "comm__namedPage",
              attributes: {
            name: 'UniFi_Questionnaire__c',
          }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

}