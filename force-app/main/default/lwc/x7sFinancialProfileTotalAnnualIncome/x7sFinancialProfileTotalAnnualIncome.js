import HEADER from '@salesforce/label/c.x7sFinancialProfile_TotalAnnualIncome_Header';
import { api, LightningElement } from 'lwc';

export default class X7sFinancialProfileTotalAnnualIncome extends LightningElement {
  @api debug = false;
  header = HEADER;

  @api coClientId = '';
  @api coClientData = {};
  @api firstName = '';
  @api coClientName = '';
  @api incomePrimary = 0;
  @api incomeSecondary = 0;
  
  get labelPrimary() { return this.firstName+"'s annual income"; }
  get labelSecondary() { return this.coClientName+"'s annual income"; }

  /**
   * dispatch form data to the parent component for saving as temp data
   */
  dispatchData() {
    const obj = {
      Total_Annual_Income__c: this.incomePrimary,
      Co_Client_Total_Annual_Income__c: this.incomeSecondary,
      Combined_Annual_Income__c : (this.incomeSecondary)? this.incomePrimary + this.incomeSecondary : this.incomePrimary,
    };
    this.dispatchEvent(
        new CustomEvent('savetempdata', {
            detail: { personalInfo: obj },
        })
    );
  }

  handleChangeIncomePrimary(event) {
      this.incomePrimary = parseInt(event.detail.value, 10);
      this.dispatchData();
  }
  handleChangeIncomeSecondary(event) {
      this.incomeSecondary = parseInt(event.detail.value, 10);
      this.dispatchData();
  }
}