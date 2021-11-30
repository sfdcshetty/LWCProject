import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { showToast } from "c/x7sShrUtils";
import userId from "@salesforce/user/Id";
import { refreshApex } from "@salesforce/apex";
import { loadStyle } from "lightning/platformResourceLoader";
import editBankAccount from "@salesforce/apex/x7sBankAccountController.editBankAccount";
import addBankAccount from "@salesforce/apex/x7sBankAccountController.addBankAccount";
//import getBankAccountType from '@salesforce/apex/x7sBankAccountController.getBankAccountType';
//import getCustodian from '@salesforce/apex/x7sBankAccountController.getCustodian';
import getBankAccountDetails from "@salesforce/apex/x7sBankAccountController.getBankAccountDetails";
import personalPropertyDataTableStyle from "@salesforce/resourceUrl/x7sWegPersonalPropertyDataTableStyle";
import getOwnerList from "@salesforce/apex/x7sOtherAssetsController.getOtherAssetsOwnerList";
import { fireEvent } from "c/x7sShrUtils";
import { CurrentPageReference } from "lightning/navigation";
import {
  getObjectInfo,
  getPicklistValuesByRecordType
} from "lightning/uiObjectInfoApi";

const USER_FIELDS = ["User.AccountId"];

const columns = [
  {
    label: "Edit",
    name: "Edit",
    hideDefaultActions: true,
    type: "button",
    initialWidth: 80,
    typeAttributes: {
      iconName: "utility:edit",
      name: "Edit",
      iconPosition: "left",
      title: "Edit"
    }
  },
  {
    label: "Account Name",
    fieldName: "Name",
    hideDefaultActions: true,
    initialWidth: 270
  },
  /*{ label: 'Custodian', fieldName: 'WEG_Custodian__c', hideDefaultActions: true ,
        cellAttributes:{ class:{ fieldName: 'CustodianColor'}},
    },*/
  {
    label: "Account Type",
    name: "FinServ__FinancialAccountType__c",
    fieldName: "FinServ__FinancialAccountType__c",
    hideDefaultActions: true,
    initialWidth: 200
  },
  {
    label: "Account Owner",
    fieldName: "WEGP1_Owner_Type__c",
    hideDefaultActions: true,
    initialWidth: 230
  },
  {
    label: "Account Number",
    fieldName: "FinServ__FinancialAccountNumber__c",
    hideDefaultActions: true,
    initialWidth: 170
  },
  {
    label: "As Of Date",
    fieldName: "WEG_As_of_Date__c",
    hideDefaultActions: true,
    type: "date-local",
    initialWidth: 100,
    typeAttributes: { month: "2-digit", day: "2-digit" }
  },
  {
    label: "Value",
    fieldName: "FinServ__Balance__c",
    hideDefaultActions: true,
    type: "currency",
    initialWidth: 150,
    //{ label: 'Value', fieldName: 'WEGP1_AccumulationValue__c', hideDefaultActions: true, type: 'currency', initialWidth : 200,
    typeAttributes: {
      currencyCode: "USD",
      minimumFractionDigits: "0",
      maximumFractionDigits: "0"
    },
    cellAttributes: { alignment: "right" },
    sortable: true,
    initialWidth: 150
  }
];

export default class X7sWegBankAccountListView extends LightningElement {
  debug = true;

  currentUserId = userId;
  //currentUserId = '0052f000001sMKHAA2'; // userId
  accountId;
  isDisplayComponent = false;
  columns = columns;
  totalAmt = 0;
  isModalOpen = false;
  bankAccountHeader = "";
  bankAccountBtnLabel = "";

  bankAccountTypeList;
  bankCustodianList;
  bankDetail;
  isLoading = false;

  bankAccountRespose;
  bankAccountId;
  bankAccountName;
  bankCustodian;
  bankAccountType;
  bankAccountOwner;
  bankAccountNumber;
  bankAsOfDate;
  bankAccountAmount;

  //defaultSortedBy = 'WEGP1_AccumulationValue__c';
  defaultSortedBy = "FinServ__Balance__c";

  sortedBy;
  defaultSortDirection = "desc";
  sortDirection = "desc";
  isRequiredFieldsFill = false;

  @track dataList;
  @api componentTitle = "Bank Account";
  @api buttonAddLabel = "Add Bank Account";
  @api buttonEditLabel = "Edit Account";
  @api headerEditBankAccount = "Save Bank Account";
  @api headerAddBankAccount = "Add Bank Account";
  @api cancelButtonLabel = "Cancel";
  @api requiredFieldValidationMessage = "Please fill all the required fields.";

  @api objectName = "FinServ__FinancialAccount__c";
  @api recTypeName = "Bank Account";
  @api fieldName = "FinServ__FinancialAccountType__c";
  bankRecordTypeId;

  @wire(CurrentPageReference) pageRef;

  renderedCallback() {
    Promise.all([loadStyle(this, personalPropertyDataTableStyle)]);
  }

  @wire(getObjectInfo, { objectApiName: "$objectName" })
  objectInfo({ data, error }) {
    if (error) console.error(error);
    if (data) {
      const bankRecordTypes = Object.values(data.recordTypeInfos).find(
        (i) => i.name === this.recTypeName
      ); // undefined if there's no matching record type
      this.bankRecordTypeId = bankRecordTypes
        ? bankRecordTypes.recordTypeId
        : "";
    }
  }

  @wire(getPicklistValuesByRecordType, {
    recordTypeId: "$bankRecordTypeId",
    objectApiName: "$objectName"
  })
  getPicklistValues({ data, error }) {
    if (error) console.error(error);
    if (data) {
      this.bankAccountTypeOptions =
        data.picklistFieldValues[this.fieldName].values;
    }
  }

  // @wire(getBankAccountType,{objectType: 'FinServ__FinancialAccount__c',recordTypeName: 'Bank Account', fieldName: 'FinServ__FinancialAccountType__c'})
  // bankAccountTypeRecord({ error, data }) {
  //     if (data) {
  //         if (this.debug) console.log('Account Type List:::', data);
  //         this.bankAccountTypeList = data;
  //     }
  //     else if (error) {
  //         console.error('Account Type List:::',error);
  //     }
  // }

  // @wire(getCustodian)
  // wiredCustodianRecord({ error, data }) {
  //      if (data) {
  //          this.bankCustodianList = data;
  //      }
  //      else if (error) {
  //          console.error(error);
  //      }
  // }

  @wire(getRecord, { recordId: "$currentUserId", fields: USER_FIELDS })
  wiredUserRecord({ error, data }) {
    if (error) {
      console.error("Error in getRecord:", error);
    } else if (data) {
      this.accountId = data.fields.AccountId.value;
    }
  }

  @wire(getOwnerList, { accountId: "$accountId" })
  wiredOwnerList(response) {
    if (response) {
      this.ownerList = response["data"];
      if (this.debug)
        console.log("ownerList = " + JSON.stringify(this.ownerList));
    } else if (error) {
      if (this.debug) console.log("ownerList error = " + error);
      console.error("Error in get owner lists:", error);
    }
  }

  @wire(getBankAccountDetails, { accountId: "$accountId" })
  wiredBankAccountDetails(response) {
    if (this.debug) console.log("my total amount is", this.totalAmt);
    this.isLoading = true;
    this.bankAccountRespose = response;
    let error = response && response.error;
    let result = response && response.data;
    if (result) {
      this.isDisplayComponent = true;
      const mainData = [...result];
      // pre-sort the data according to the field named in this.defaultSortedBy
      if (this.defaultSortedBy) {
        mainData.sort((a, b) => {
          let cmp =
            a[this.defaultSortedBy] < b[this.defaultSortedBy]
              ? -1
              : a[this.defaultSortedBy] > b[this.defaultSortedBy]
              ? 1
              : 0;
          if (this.defaultSortDirection === "desc") cmp *= -1;
          return cmp;
        });
      }
      for (let i = 0; i < mainData.length; i++) {
        if (this.debug)
          console.log("mainDataCheck", mainData[i].FinServ__Balance__c);
        if (
          mainData[i].FinServ__Balance__c &&
          typeof mainData[i].FinServ__Balance__c === "number"
        )
          this.totalAmt = this.totalAmt + mainData[i].FinServ__Balance__c;
      }
      this.dataList = mainData;
    } else if (error) {
      console.error("Error in getRecord:", error);
    }
    this.isLoading = false;
  }

  // get bankAccountTypeOptions() {
  //     var bankAccountTypeValues = [];
  //     for (let key in this.bankAccountTypeList) {
  //         bankAccountTypeValues.push({ label: this.bankAccountTypeList[key], value: this.bankAccountTypeList[key] });
  //     }
  //     return bankAccountTypeValues;
  // }

  get bankCustodianOptions() {
    var bankCustodianValues = [];
    for (let key in this.bankCustodianList) {
      bankCustodianValues.push({
        label: this.bankCustodianList[key],
        value: this.bankCustodianList[key]
      });
    }
    return bankCustodianValues;
  }

  get bankAccountOwnerOptions() {
    var ownerListValues = [];
    for (let key in this.ownerList) {
      ownerListValues.push({ label: this.ownerList[key], value: key });
    }
    return ownerListValues;
  }

  handleAddBankAccountClick(event) {
    this.clearFormData();
    this.isModalOpen = true;
    this.bankAccountHeader = this.headerAddBankAccount;
    this.bankAccountBtnLabel = this.buttonAddLabel;
  }

  closeModal() {
    this.clearFormData();
    this.isModalOpen = false;
  }

  getParam() {
    /*let amount=this.bankAccountAmount;
        amount=amount.replace(/\,/g,''); //convert it to number
        this.bankAccountAmount = amount;*/

    let params = {
      Name: this.bankAccountName,
      Type: this.bankAccountType,
      // Custodian : this.bankCustodian,
      AccountNumber: this.bankAccountNumber,
      Owner: this.bankAccountOwner,
      AsOfDate: this.bankAsOfDate,
      //Amount: Math.round(this.bankAccountAmount),
      Amount: Math.trunc(this.bankAccountAmount)
    };
    return params;
  }

  clearFormData() {
    this.bankAccountId = "";
    this.bankAccountName = "";
    // this.bankCustodian = '';
    this.bankAccountType = "";
    this.bankAccountOwner = "";
    this.bankAccountNumber = "";
    this.bankAsOfDate = "";
    this.bankAccountAmount = 0;
  }

  handleRowAction(event) {
    this.isModalOpen = true;
    this.bankAccountHeader = this.headerEditBankAccount;
    this.bankAccountBtnLabel = this.buttonEditLabel;
    this.bankAccountId = event.detail.row.Id;
    this.bankAccountName = event.detail.row.Name;
    // this.bankCustodian = event.detail.row.WEG_Custodian__c;
    this.bankAccountType = event.detail.row.FinServ__FinancialAccountType__c;
    if (event.detail.row.WEGP1_Owner_Type__c === "Joint") {
      this.bankAccountOwner = "Joint";
    } else {
      this.bankAccountOwner = event.detail.row.FinServ__PrimaryOwner__c;
    }
    this.bankAccountNumber =
      event.detail.row.FinServ__FinancialAccountNumber__c;
    this.bankAsOfDate = event.detail.row.WEG_As_of_Date__c;
    //this.bankAccountAmount = event.detail.row.WEGP1_AccumulationValue__c;
    this.bankAccountAmount = event.detail.row.FinServ__Balance__c;
  }

  validateAccountRequiredFields() {
    var validateCmp = "";
    if (!this.bankAccountName) {
      validateCmp = ".validateAccountName";
    }
    // else if (!this.bankCustodian) {
    //     validateCmp = ".validateCustodian";
    // }
    // else if (!this.bankAccountType) {
    //     validateCmp = ".validateType";
    // }
    else if (!this.bankAccountOwner) {
      validateCmp = ".validateOwner";
    }
    // else if (!this.bankAccountNumber) {
    //     validateCmp = ".validateAccountNumber";
    // } else if (!this.bankAsOfDate) {
    //     validateCmp = ".validateAsOfDate";
    // } else if (!this.bankAccountAmount) {
    //     validateCmp = ".validateBankAccountAmount";
    // }
    else {
      this.isRequiredFieldsFill = true;
    }
    if (validateCmp != "") {
      var inputCmp = this.template.querySelector(validateCmp);
      inputCmp.reportValidity();
      this.template.querySelector(validateCmp).focus();
      this.validateRequireFields = false;
    }
  }

  submitDetails() {
    //console.log('details');
    this.isLoading = true;
    this.validateAccountRequiredFields();
    if (!this.isRequiredFieldsFill) {
      this.isLoading = false;
      return false;
    }

    //console.log('JSON.stringify(this.getParam())', JSON.stringify(this.getParam()));

    if (this.bankAccountId) {
      console.log("is Edit");
      console.log("this.bankAccountId=====>" + this.bankAccountId);
      console.log("this.accountId=====>" + this.accountId);
      console.log(
        "JSON.stringify(this.getParam())=====>" +
          JSON.stringify(this.getParam())
      );
      editBankAccount({
        bankAccountId: this.bankAccountId,
        accountId: this.accountId,
        bankAccountInfo: JSON.stringify(this.getParam())
      })
        .then((result) => {
          this.totalAmt = 0;
          refreshApex(this.bankAccountRespose);
          fireEvent(this.pageRef, "changeBankAccountNetWorth", {
            value: this.totalAmt
          });
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Bank account Edit error", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    } else {
      console.log("is add");
      if (this.debug) console.log("Account Id ==> " + this.accountId);
      if (this.debug)
        console.log("bankAccountInfo ==> " + JSON.stringify(this.getParam()));
      addBankAccount({
        accountId: this.accountId,
        bankAccountInfo: JSON.stringify(this.getParam())
      })
        .then((result) => {
          this.totalAmt = 0;
          refreshApex(this.bankAccountRespose);
          fireEvent(this.pageRef, "changeBankAccountNetWorth", {
            value: this.totalAmt
          });
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Bank account Insert error", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    }
    this.isModalOpen = false;
  }

  handleAccountNameChange(event) {
    this.bankAccountName = event.target.value;
  }
  // handleCustodianChange(event){  this.bankCustodian = event.target.value; }
  handleAccountTypeChange(event) {
    this.bankAccountType = event.target.value;
  }
  handleBankOwnerChange(event) {
    this.bankAccountOwner = event.target.value;
  }
  handleAccountNumberChange(event) {
    this.bankAccountNumber = event.target.value;
  }
  handleAsOfDateChange(event) {
    this.bankAsOfDate = event.target.value;
  }
  handleAmountChange(event) {
    this.bankAccountAmount = event.target.value;
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.dataList];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.dataList = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }
}