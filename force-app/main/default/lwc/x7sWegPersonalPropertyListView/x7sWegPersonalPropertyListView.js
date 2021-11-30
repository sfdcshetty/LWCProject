import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { loadStyle } from "lightning/platformResourceLoader";
import { refreshApex } from "@salesforce/apex";
import editProperty from "@salesforce/apex/x7sPersonalPropertyController.editProperty";
import addProperty from "@salesforce/apex/x7sPersonalPropertyController.addProperty";
import getPropertyType from "@salesforce/apex/x7sPersonalPropertyController.getPropertyType";
import getPersonalPropertyDetails from "@salesforce/apex/x7sPersonalPropertyController.getPersonalPropertyDetails";
import personalPropertyDataTableStyle from "@salesforce/resourceUrl/x7sWegPersonalPropertyDataTableStyle";
import getTheOwnerList from "@salesforce/apex/x7sOtherAssetsController.getOtherAssetsOwnerList";
import userId from "@salesforce/user/Id";
import { fireEvent } from "c/x7sShrUtils";
import { CurrentPageReference } from "lightning/navigation";

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
    label: "Property Name",
    fieldName: "Name",
    hideDefaultActions: true,
    initialWidth: 300
  },
  {
    label: "Property Type",
    fieldName: "FinServ__AssetsAndLiabilitiesType__c",
    hideDefaultActions: true,
    initialWidth: 200
  },
  {
    label: "Property Owner",
    fieldName: "WEGP1_Owner_Type__c",
    hideDefaultActions: true,
    initialWidth: 225
  },
  {
    label: "As Of Date",
    fieldName: "WEGP1_AsOfDate__c",
    hideDefaultActions: true,
    type: "date-local",
    initialWidth: 200,
    typeAttributes: { month: "2-digit", day: "2-digit" },
    initialWidth: 280
  },
  {
    label: "Value",
    fieldName: "FinServ__Amount__c",
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
    initialWidth: 110
  }
];

export default class X7sInvestmentListView extends LightningElement {
  //debug = true;
  //currentUserId = '0052f000001sMKHAA2'; // userId
  currentUserId = userId; //
  accountId;
  isDisplayComponent = false;
  columns = columns;
  totalAmt = 0;
  isModalOpen = false;
  propertyHeader = "";
  propertyBtnLabel = "";

  propertyTypeList;
  propertyDetail;
  isLoading = false;
  ownerList;

  propertyRespose;
  propertyId;
  propertyName;
  propertyType;
  propertyOwner;
  propertyAsOfDt;
  propertyAmount;

  defaultSortedBy = "FinServ__Amount__c";
  sortedBy;
  defaultSortDirection = "desc";
  sortDirection = "desc";
  isRequiredFieldsFill = false;

  @track dataList;
  @api componentTitle = "Personal Property";
  @api buttonAddLabel = "Add Property";
  @api buttonEditLabel = "Save Property";
  @api headerEditPrivateProperty = "Edit Personal Property";
  @api headerAddPrivateProperty = "Add Personal Property";
  @api cancelButtonLabel = "Cancel";
  @wire(CurrentPageReference) pageRef;

  renderedCallback() {
    Promise.all([loadStyle(this, personalPropertyDataTableStyle)]);
  }

  @wire(getPropertyType)
  wiredPropertyTypeRecord({ error, data }) {
    if (data) {
      this.propertyTypeList = data;
    } else if (error) {
      console.error("Property Type Error::::::", error);
    }
  }

  @wire(getRecord, { recordId: "$currentUserId", fields: USER_FIELDS })
  wiredUserRecord({ error, data }) {
    if (error) {
      console.error("Error in getRecord:", error);
    } else if (data) {
      this.accountId = data.fields.AccountId.value;
    }
  }

  @wire(getTheOwnerList, { accountId: "$accountId" })
  wiredOwnerList(response) {
    if (response) {
      this.ownerList = response["data"];
    } else if (error) {
      if (this.debug) console.log("ownerList error = " + error);
      console.error("Error in get owner lists:", error);
    }
  }

  @wire(getPersonalPropertyDetails, { accountId: "$accountId" })
  wiredProfileDetails(response) {
    this.isLoading = true;
    this.propertyRespose = response;
    let error = response && response.error;
    let result = response && response.data;
    if (result) {
      this.isDisplayComponent = true;
      const mainData = [...result];
      // pre-sort the data according to the field named in this.defaultSortedBy
      this.totalAmt = 0;
      for (let i = 0; i < mainData.length; i++) {
        if ( mainData[i].FinServ__Amount__c && typeof mainData[i].FinServ__Amount__c === 'number' ) {
          this.totalAmt = this.totalAmt + mainData[i].FinServ__Amount__c;
        }
      }

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
      this.dataList = mainData;
      if (this.debug) console.log("this.dataList", this.dataList);
    } else if (error) {
      //console.error('Error in getRecord:', error);
    }
    this.isLoading = false;
  }

  get propertyTypeOptions() {
    var propertTypeValues = [];
    for (let key in this.propertyTypeList) {
      propertTypeValues.push({
        label: this.propertyTypeList[key],
        value: this.propertyTypeList[key]
      });
    }
    return propertTypeValues;
  }

  get propertyOwnerOptions() {
    var ownerListValues = [];

    for (let key in this.ownerList) {
      ownerListValues.push({ label: this.ownerList[key], value: key });
    }
    return ownerListValues;
  }

  getParam() {
    if (this.debug) console.log("GET PARAMS...");
    let amount = this.propertyAmount;
    //amount=amount.replace(/\,/g,''); //convert it to number
    this.propertyAmount = amount;

    let params = {
      Name: this.propertyName,
      Type: this.propertyType,
      Owner: this.propertyOwner,
      AsOfDate: this.propertyAsOfDt,
      Amount: Math.round(this.propertyAmount)
    };
    if (this.debug) console.log("params=" + params);
    return params;
  }

  clearFormData() {
    this.propertyId = "";
    this.propertyName = "";
    this.propertyAmount = 0.0;
    this.propertyOwner = "";
    this.propertyAsOfDt = "";
    this.propertyType = "";
  }

  handleRowAction(event) {
    this.isModalOpen = true;

    this.propertyHeader = this.headerEditPrivateProperty;
    this.propertyBtnLabel = this.buttonEditLabel;

    this.row = event.detail.row;
    this.propertyId = event.detail.row.Id;
    this.propertyName = event.detail.row.Name;
    this.propertyType = event.detail.row.FinServ__AssetsAndLiabilitiesType__c;
    if (event.detail.row.WEGP1_Owner_Type__c === "Joint") {
      this.propertyOwner = "Joint";
    } else {
      this.propertyOwner = event.detail.row.FinServ__PrimaryOwner__c;
    }
    //this.propertyOwner = event.detail.row.FinServ__PrimaryOwner__c;
    this.propertyAsOfDt = event.detail.row.WEGP1_AsOfDate__c;
    this.propertyAmount = event.detail.row.FinServ__Amount__c;

    if (this.debug)
      console.log(
        "Primary",
        event.detail.row.FinServ__Household__r.WEGP1_Primary_Individual__r.Name
      );
    if (this.debug)
      console.log(
        "Secondary",
        event.detail.row.FinServ__Household__r.WEGP1_Secondary_Individual__r
          .Name
      );
  }

  validateAccountRequiredFields() {
    var validateCmp = "";
    if (!this.propertyName) {
      validateCmp = ".validatePropertyName";
    } else if (!this.propertyType) {
      validateCmp = ".validatePropertyType";
    } else if (!this.propertyOwner) {
      validateCmp = ".validatePropertyOwner";
    }
    // else if (!this.propertyAmount) {
    //     validateCmp = ".validatePropertyAmount";
    // }
    // else if (!this.propertyAsOfDt) {
    //     validateCmp = ".validatePropertyAsOfDt";
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

  handlePropertyNameChange(event) {
    this.propertyName = event.target.value;
  }
  handlePropertyTypeChange(event) {
    this.propertyType = event.target.value;
  }
  handlePropertyAsOfDtChange(event) {
    this.propertyAsOfDt = event.target.value;
  }
  handleAmountChange(event) {
    this.propertyAmount = event.target.value;
  }
  handlePropertyOwnerChange(event) {
    this.propertyOwner = event.target.value;
  }

  handleAddPropertyClick(event) {
    this.clearFormData();
    this.isModalOpen = true;
    this.propertyHeader = this.headerAddPrivateProperty;
    this.propertyBtnLabel = this.buttonAddLabel;
  }

  closeModal() {
    this.clearFormData();
    this.isModalOpen = false;
  }

  submitDetails() {
    //console.log('propertyid='+this.propertyId);
    this.isLoading = true;
    this.validateAccountRequiredFields();
    if (!this.isRequiredFieldsFill) {
      this.isLoading = false;
      return false;
    }

    if (this.propertyId) {
      if (this.debug) console.log("Inside Edit");
      if (this.debug) console.log(JSON.parse(JSON.stringify(this.getParam())));
      editProperty({
        propertyId: this.propertyId,
        accountId: this.accountId,
        propertyInfo: JSON.stringify(this.getParam())
      })
        .then((result) => {
          refreshApex(this.propertyRespose);
          fireEvent(this.pageRef, "changePersonalPropertytNetWorth", {
            value: this.totalAmt
          });
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Personal Property Detail error::", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    } else {
      if (this.debug)
        console.log("Inside Add", JSON.parse(JSON.stringify(this.getParam())));
      addProperty({
        accountId: this.accountId,
        propertyInfo: JSON.stringify(this.getParam())
      })
        .then((result) => {
          refreshApex(this.propertyRespose);
          fireEvent(this.pageRef, "changePersonalPropertytNetWorth", {
            value: this.totalAmt
          });
          if (this.debug)
            console.log("Personal Property Respose:::", this.propertyRespose);
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Personal Property Detail error::", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    }
    this.isModalOpen = false;
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