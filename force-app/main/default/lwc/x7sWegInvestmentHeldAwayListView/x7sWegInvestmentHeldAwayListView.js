import { LightningElement, wire, api, track } from "lwc";
import getInvestmentHeldAwayDetails from "@salesforce/apex/x7sInvestmentHeldAwayController.getInvestmentHeldAwayDetails";
import { getRecord } from "lightning/uiRecordApi";
import { loadStyle } from "lightning/platformResourceLoader";
import investmentDataTableStyle from "@salesforce/resourceUrl/x7sWebInvestmentDataTableStyle";
import userId from "@salesforce/user/Id";
import { refreshApex } from "@salesforce/apex";
import { fireEvent } from "c/x7sShrUtils";
import { CurrentPageReference } from "lightning/navigation";
import getOwnerList from "@salesforce/apex/x7sOtherAssetsController.getOtherAssetsOwnerList";
import getCustodian from "@salesforce/apex/x7sInvestmentHeldAwayController.getCustodian";
import getAccountType from "@salesforce/apex/x7sInvestmentHeldAwayController.getAccountType";
// import getInvestmentHeldAwayRecordType from '@salesforce/apex/x7sInvestmentHeldAwayController.getInvestmentHeldAwayRecordType';
import editInvestmentHeldAway from "@salesforce/apex/x7sInvestmentHeldAwayController.editInvestmentHeldAway";
import addInvestmentHeldAway from "@salesforce/apex/x7sInvestmentHeldAwayController.addInvestmentHeldAway";

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
    label: "Custodian",
    fieldName: "WEG_Custodian__c",
    hideDefaultActions: true,
    cellAttributes: { class: { fieldName: "CustodianColor" } }
  },
  {
    label: "Account Name",
    name: "Name",
    fieldName: "Name",
    hideDefaultActions: true
  },

  {
    label: "Account Type",
    name: "WEG_Registration_Type__c",
    fieldName: "WEG_Registration_Type__c",
    hideDefaultActions: true
  },
  //{ label: 'Is Other', name: 'FinServ__HeldAway__c',fieldName: 'FinServ__HeldAway__c', hideDefaultActions: true},
  {
    label: "Account Owner",
    fieldName: "WEGP1_Owner_Type__c",
    hideDefaultActions: true
  },
  {
    label: "Account Number",
    fieldName: "FinServ__FinancialAccountNumber__c",
    hideDefaultActions: true
  },
  {
    label: "As Of Date",
    fieldName: "WEG_As_of_Date__c",
    hideDefaultActions: true,
    type: "date-local",
    initialWidth: 150,
    typeAttributes: { month: "2-digit", day: "2-digit" }
  },
  {
    label: "Value",
    fieldName: "FinServ__Balance__c",
    hideDefaultActions: true,
    type: "currency",
    initialWidth: 200,
    typeAttributes: {
      currencyCode: "USD",
      minimumFractionDigits: "0",
      maximumFractionDigits: "0"
    },
    cellAttributes: { alignment: "right" },
    sortable: true,
    initialWidth: 100
  }
];

export default class X7sWegInvestmentHeldAwayListView extends LightningElement {
  debug = true;

  //currentUserId = '0052f000001sMKHAA2'; // userId
  currentUserId = userId;
  @api componentTitle = "Investments Held Away";
  @api introParagraph =
    "These accounts are not editable. Have questions? Contact your advisory team.";

  @track dataList;
  accountId;
  isDisplayComponent = false;
  isLoading = false;
  columns = columns;
  totalAmt = 0;

  defaultSortedBy = "FinServ__Balance__c";
  sortedBy;
  defaultSortDirection = "desc";
  sortDirection = "desc";

  row;
  investmentHeldAwayId;
  investmentHeldAwayCustodian;
  investmentHeldAwayAccountType;
  investmentHeldAwayOwner;
  investmentHeldAwayAccountNumber;
  investmentHeldAwayAsOfDate;
  investmentHeldAwayValue;
  // investmentHeldAwayrecordType = '';

  @api buttonLabel = "Add Account";
  @api cancelButtonLabel = "Cancel";
  @api editInvestmentHeldAwayHeader = "Edit Investment Held Away";
  @api editInvestmentHeldAwayBtnLabel = "Edit Investment Held Away";
  @api addInvestmentHeldAwayHeader = "Add Investment Held Away";
  @api addInvestmentHeldAwayBtnLabel = "Add Investment Held Away";

  investmentHeldAwayHeader;
  investmentHeldAwayBtnLabel;

  investmentHeldAwayResponse;
  investmentHeldAwayCustodianList;
  investmentHeldAwayAccountTypeList;
  investmentHeldOwnerList;
  // recordTypeList;
  validateRequireFields = true;
  isModalOpen = false;
  isDisplayRecordType = false;

  // investmentHeldAwayRecordType = [
  //     "Advisory Investment Account",
  //     "Annuity Investment Account",
  //     "Brokerage Investment Account",
  //     "ERP Investment Account",
  //     "Investment Account",
  //     "Other Investment Account"
  // ];

  @wire(CurrentPageReference) pageRef;

  renderedCallback() {
    Promise.all([loadStyle(this, investmentDataTableStyle)]);
  }

  // @wire(getInvestmentHeldAwayRecordType)
  // getInvestmentHeldAwayRecordType({ error, data }) {
  //     if (error) {
  //     console.error("Error in get Record Type:", error);
  //     } else if (data) {
  //     this.recordTypeList = data;
  //     }
  // }

  @wire(getRecord, { recordId: "$currentUserId", fields: USER_FIELDS })
  wiredUserRecord({ error, data }) {
    if (error) {
      console.error("Error in getRecord:", error);
    } else if (data) {
      this.accountId = data.fields.AccountId.value;
    }
  }

  @wire(getCustodian)
  wiredCustodianRecord({ error, data }) {
    if (data) {
      this.investmentHeldAwayCustodianList = data;
    } else if (error) {
      console.error(error);
    }
  }

  @wire(getAccountType)
  AccountTypeRecord({ error, data }) {
    if (data) {
      this.investmentHeldAwayAccountTypeList = data;
    } else if (error) {
      console.error(error);
    }
  }

  @wire(getOwnerList, { accountId: "$accountId" })
  wiredOwnerList(response) {
    if (response) {
      this.investmentHeldOwnerList = response["data"];
    } else if (error) {
      if (this.debug) console.log("ownerList error = " + error);
    }
  }

  @wire(getInvestmentHeldAwayDetails, { accountId: "$accountId" })
  wiredInvestmentsHeldAwayDetails(response) {
    this.isLoading = true;
    this.investmentHeldAwayResponse = response;
    this.totalAmt = 0.0;
    let error = response && response.error;
    let result = response && response.data;
    if (result) {
      let mainData = [...result];
      this.isDisplayComponent = true;
      for (let i = 0; i < mainData.length; i++) {
        if (
          mainData[i].FinServ__Balance__c &&
          typeof mainData[i].FinServ__Balance__c === "number"
        ) {
          this.totalAmt = this.totalAmt + mainData[i].FinServ__Balance__c;
        }
      }
      this.dataList = mainData.map((i) => ({
        ...i,
        CustodianColor: "custodianColor"
      }));
      if (this.debug) console.log("this.dataList", this.dataList);
    } else if (error) {
      console.error("Error in getRecord:", error);
    }
    this.isLoading = false;
  }

  get investmentHeldAwayCustodianOptions() {
    var investmentHeldAwayCustodianValues = [];
    for (let key in this.investmentHeldAwayCustodianList) {
      investmentHeldAwayCustodianValues.push({
        label: this.investmentHeldAwayCustodianList[key],
        value: this.investmentHeldAwayCustodianList[key]
      });
    }
    return investmentHeldAwayCustodianValues;
  }

  get investmentHeldAwayAccountTypeOptions() {
    var investmentHeldAwayAccountTypeValues = [];
    for (let key in this.investmentHeldAwayAccountTypeList) {
      investmentHeldAwayAccountTypeValues.push({
        label: this.investmentHeldAwayAccountTypeList[key],
        value: this.investmentHeldAwayAccountTypeList[key]
      });
    }
    return investmentHeldAwayAccountTypeValues;
  }

  get investmentHeldAwayOwnerOptions() {
    var ownerListValues = [];
    for (let key in this.investmentHeldOwnerList) {
      ownerListValues.push({
        label: this.investmentHeldOwnerList[key],
        value: key
      });
    }
    return ownerListValues;
  }

  // get investmentHeldAwayRecordTypeOptions() {
  //     var investmentHeldAwayRecordType = [];
  //     for (var i = 0; i < this.recordTypeList.length; i++) {
  //         if (this.investmentHeldAwayRecordType.includes(this.recordTypeList[i].Name)) {
  //             investmentHeldAwayRecordType.push({
  //                 label: this.recordTypeList[i].Name,
  //                 value: this.recordTypeList[i].Name,
  //               });
  //         }
  //     }
  //     return investmentHeldAwayRecordType;
  // }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.dataList];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.dataList = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  handleRowAction(event) {
    this.isModalOpen = true;

    this.investmentHeldAwayHeader = this.editInvestmentHeldAwayHeader;
    this.investmentHeldAwayBtnLabel = this.editInvestmentHeldAwayBtnLabel;

    this.isDisplayRecordType = false;
    this.row = event.detail.row;
    this.investmentHeldAwayId = event.detail.row.Id;
    this.investmentHeldAwayCustodian = event.detail.row.WEG_Custodian__c;
    this.investmentHeldAwayAccountType =
      event.detail.row.WEG_Registration_Type__c;
    console.log(
      "this.investmentHeldAwayAccountType",
      event.detail.row.FinServ__Registration_Type__c
    );
    //this.investmentHeldAwayAccountType = 'IRA';

    if (event.detail.row.WEGP1_Owner_Type__c === "Joint") {
      this.investmentHeldAwayOwner = "Joint";
    } else {
      this.investmentHeldAwayOwner = event.detail.row.FinServ__PrimaryOwner__c;
    }
    this.investmentHeldAwayAccountName = event.detail.row.Name;
    this.investmentHeldAwayAccountNumber =
      event.detail.row.FinServ__FinancialAccountNumber__c;
    this.investmentHeldAwayAsOfDate = event.detail.row.WEG_As_of_Date__c;
    this.investmentHeldAwayValue = event.detail.row.FinServ__Balance__c;
  }

  getParam() {
    let params = {
      AccountName: this.investmentHeldAwayAccountName,
      Custodian: this.investmentHeldAwayCustodian,
      AccountType: this.investmentHeldAwayAccountType,
      Owner: this.investmentHeldAwayOwner,
      AccountNumber: this.investmentHeldAwayAccountNumber,
      AsOfDate: this.investmentHeldAwayAsOfDate,
      Value: Math.round(this.investmentHeldAwayValue)
    };
    return params;
  }

  clearFormData() {
    this.investmentHeldAwayAccountName = "";
    this.investmentHeldAwayId = "";
    this.investmentHeldAwayId = "";
    this.investmentHeldAwayCustodian = "";
    this.investmentHeldAwayAccountType = "";
    this.investmentHeldAwayOwner = "";
    this.investmentHeldAwayAccountNumber = "";
    this.investmentHeldAwayAsOfDate = "";
    this.investmentHeldAwayValue = 0.0;
    this.isDisplayRecordType = false;
  }

  validateHeldawayRequiredFields() {
    var validateCmp = "";
    // console.log('!this.investmentHeldAwayrecordType', !this.investmentHeldAwayrecordType);

    // if ((!this.investmentHeldAwayrecordType) && (this.isDisplayRecordType)) {
    //     validateCmp = ".validateHeldAwayRecordType";
    // } else
    if (!this.investmentHeldAwayOwner) {
      validateCmp = ".validateHeldAwayOwner";
    }
    //
    else {
      this.isRequiredFieldsFill = true;
    }
    if (validateCmp != "") {
      console.log("Janavi>>>>>", validateCmp);
      var inputCmp = this.template.querySelector(validateCmp);
      inputCmp.reportValidity();
      this.template.querySelector(validateCmp).focus();
      this.validateRequireFields = false;
    }
  }

  handleHeldAwayAccountNameChange(event) {
    this.investmentHeldAwayAccountName = event.target.value;
  }
  handleHeldAwayCustodianChange(event) {
    this.investmentHeldAwayCustodian = event.target.value;
  }
  handleHeldAwayAccountTypeChange(event) {
    console.log("fire");
    this.investmentHeldAwayAccountType = event.target.value;
  }
  handleHeldAwayOwnerChange(event) {
    this.investmentHeldAwayOwner = event.target.value;
  }
  handleHeldAwayAccountNumberChange(event) {
    this.investmentHeldAwayAccountNumber = event.target.value;
  }
  handleHeldAwayAsOfDateChange(event) {
    this.investmentHeldAwayAsOfDate = event.target.value;
  }
  handleHeldAwayValueChange(event) {
    this.investmentHeldAwayValue = event.target.value;
  }
  // handleHeldAwayRecordTypeChange(event){  this.investmentHeldAwayrecordType = event.target.value; }

  handleAddInvestmentHeldAwayClick(event) {
    this.clearFormData();
    this.isModalOpen = true;
    this.isDisplayRecordType = true;
    this.investmentHeldAwayHeader = this.addInvestmentHeldAwayHeader;
    this.investmentHeldAwayBtnLabel = this.addInvestmentHeldAwayBtnLabel;
  }

  closeModal() {
    this.clearFormData();
    this.isModalOpen = false;
  }

  submitDetails() {
    //console.log('janavi....='+this.validateRequireFields);
    this.isLoading = true;
    this.validateHeldawayRequiredFields();
    if (!this.isRequiredFieldsFill) {
      this.isLoading = false;
      return false;
    }

    console.log(
      "JSON.stringify(this.getParam())",
      JSON.stringify(this.getParam())
    );
    if (this.investmentHeldAwayId) {
      console.log("has id...lets go edit");
      this.isLoading = true;
      console.log("investmentHeldAwayId=" + this.investmentHeldAwayId);
      console.log("investmentHeldAwayId=" + this.accountId);
      console.log("investmentHeldAwayId=" + JSON.stringify(this.getParam()));
      editInvestmentHeldAway({
        investmentHeldAwayId: this.investmentHeldAwayId,
        accountId: this.accountId,
        investmentHeldAwayInfo: JSON.stringify(this.getParam())
      })
        .then((result) => {
          this.totalAmt = 0.0;
          refreshApex(this.investmentHeldAwayResponse);
          console.log("has result", this.investmentHeldAwayResponse);

          fireEvent(this.pageRef, "changeInvestmentHeldAwayNetWorth", {
            value: this.totalAmt
          });
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Held away Detail error::", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    } else {
      console.log("has NO id...lets go create");
      this.isLoading = true;
      console.log("accountId=" + this.accountId);
      console.log("investmentHeldAwayInfo=" + JSON.stringify(this.getParam()));
      addInvestmentHeldAway({
        accountId: this.accountId,
        investmentHeldAwayInfo: JSON.stringify(this.getParam())
      })
        .then((result) => {
          this.totalAmt = 0.0;
          console.log("has result", result);
          refreshApex(this.investmentHeldAwayResponse);
          fireEvent(this.pageRef, "changeInvestmentHeldAwayNetWorth", {
            value: this.totalAmt
          });
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Held away Detail error::", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    }
    this.isModalOpen = false;
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