import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { loadStyle } from "lightning/platformResourceLoader";
import { refreshApex } from "@salesforce/apex";
import getInsuranceDetails from "@salesforce/apex/x7sInsuranceController.getInsuranceDetails";
import addInsurance from "@salesforce/apex/x7sInsuranceController.addInsurance";
import getCustodianType from "@salesforce/apex/x7sInsuranceController.getCustodianType";
// import getOwnerList from "@salesforce/apex/x7sInsuranceController.getOwnerList";
import getOwnerList from '@salesforce/apex/x7sOtherAssetsController.getOtherAssetsOwnerList';
import editInsurance from "@salesforce/apex/x7sInsuranceController.editInsurance";
import getProductType from "@salesforce/apex/x7sInsuranceController.getProductType";
import getInsuranceRecordType from "@salesforce/apex/x7sInsuranceController.getInsuranceRecordType";
import insuranceDataTableStyle from "@salesforce/resourceUrl/x7sWegInsuranceDataTableStyle";
import INSURANCE_OBJECT from '@salesforce/schema/FinServ__FinancialAccount__c';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

import userId from "@salesforce/user/Id";
const USER_FIELDS = ["User.AccountId"];

const columnsInsuranceLife = [
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
      title: "Edit",
    },
  },
  { label: 'Insurance Policy Name' , fieldName: 'InsuranceName', hideDefaultActions: true, initialWidth : 190 },
  { label: "Product Type", fieldName: "ProductType", hideDefaultActions: true },
  { label: "Service Provider", fieldName: "serviceProvider", hideDefaultActions: true, initialWidth : 150 },
  { label: "Primary Owner", fieldName: "OwnerName", hideDefaultActions: true },
  //{ label: "Carrier", fieldName: "Carrier", hideDefaultActions: true },
  //{ label: "Policy Number", fieldName: "Policy", hideDefaultActions: true },
  //{ label: "Insured", fieldName: "Insured", hideDefaultActions: true },
  {
    label: "Last Updated",
    fieldName: "AsOfDate",
    hideDefaultActions: true,
    type: "date-local",
    typeAttributes: { month: "2-digit", day: "2-digit" },
  },
  {
    label: "Death Benefit",
    fieldName: "DeathBenefit",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
    initialWidth : 130
  },
  {
    label: "Cash Value",
    fieldName: "CashValue",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
    //sortable: true,
  },
];

const columnsInsuranceLongTerm = [
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
      title: "Edit",
    },
  },
  { label: 'Insurance Policy Name' , fieldName: 'InsuranceName', hideDefaultActions: true, initialWidth : 190 },
  { label: "Product Type", fieldName: "ProductType", hideDefaultActions: true },
  { label: "Service Provider", fieldName: "serviceProvider", hideDefaultActions: true, initialWidth : 150 },
  { label: "Primary Owner", fieldName: "OwnerName", hideDefaultActions: true, initialWidth : 90 },
  // { label: "Carrier", fieldName: "Carrier", hideDefaultActions: true },
  //{ label: "Policy Number", fieldName: "Policy", hideDefaultActions: true },
  //{ label: "Insured", fieldName: "Insured", hideDefaultActions: true },
  {
    label: "Last Updated",
    fieldName: "AsOfDate",
    hideDefaultActions: true,
    type: "date-local",
    typeAttributes: { month: "2-digit", day: "2-digit" },
  },
  {
    label: "Benefit Amount",
    fieldName: "BenefitAmount",
    hideDefaultActions: true,
    cellAttributes: { alignment: "right" },
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
  },
  {
    label: "Death Benefit",
    fieldName: "DeathBenefit",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
    // sortable: true,
  },
  {
    label: "Cash Value",
    fieldName: "CashValue",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
    // sortable: true,
  },
];

const columnsInsuranceDisability = [
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
      title: "Edit",
    },
  },
  { label: 'Insurance Policy Name' , fieldName: 'InsuranceName', hideDefaultActions: true, initialWidth : 190 },
  { label: "Product Type", fieldName: "ProductType", hideDefaultActions: true, initialWidth : 150 },
  { label: "Service Provider", fieldName: "serviceProvider", hideDefaultActions: true, initialWidth : 180 },
  { label: "Primary Owner", fieldName: "OwnerName", hideDefaultActions: true },
  // { label: "Carrier", fieldName: "Carrier", hideDefaultActions: true },
  //{ label: "Policy Number", fieldName: "Policy", hideDefaultActions: true },
  //{ label: "Insured", fieldName: "Insured", hideDefaultActions: true },
  {
    label: "Last Updated",
    fieldName: "AsOfDate",
    hideDefaultActions: true,
    type: "date-local",
    typeAttributes: { month: "2-digit", day: "2-digit" },
  },
  {
    label: "Benefit Amount",
    fieldName: "BenefitAmount",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
  },
];

const columnsInsuranceHealth = [
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
      title: "Edit",
    },
  },
  { label: 'Insurance Policy Name' , fieldName: 'InsuranceName', hideDefaultActions: true, initialWidth : 190 },
  { label: "Product Type", fieldName: "ProductType", hideDefaultActions: true, initialWidth : 150 },
  { label: "Service Provider", fieldName: "serviceProvider", hideDefaultActions: true, initialWidth : 150 },
  { label: "Primary Owner", fieldName: "OwnerName", hideDefaultActions: true, initialWidth : 150 },
  // { label: "Carrier", fieldName: "Carrier", hideDefaultActions: true },
  //{ label: "Policy Number", fieldName: "Policy", hideDefaultActions: true },
  //{ label: "Insured", fieldName: "Insured", hideDefaultActions: true },
  {
    label: "Last Updated",
    fieldName: "AsOfDate",
    hideDefaultActions: true,
    type: "date-local",
    typeAttributes: { month: "2-digit", day: "2-digit" },
  },
  {
    label: "Premium",
    fieldName: "Premium",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
  },
];

const columnsInsurancePropertyAndCasualty = [
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
      title: "Edit",
    },
  },
  { label: 'Insurance Policy Name' , fieldName: 'InsuranceName', hideDefaultActions: true, initialWidth : 190 },
  { label: "Product Type", fieldName: "ProductType", hideDefaultActions: true },
  { label: "Service Provider", fieldName: "serviceProvider", hideDefaultActions: true },
  { label: "Primary Owner", fieldName: "OwnerName", hideDefaultActions: true },
  {
    label: "Insured Asset",
    fieldName: "InsuredAsset",
    hideDefaultActions: true,
  },
  // { label: "Carrier", fieldName: "Carrier", hideDefaultActions: true },
  //{ label: "Policy Number", fieldName: "Policy", hideDefaultActions: true },
  {
    label: "Last Updated",
    fieldName: "AsOfDate",
    hideDefaultActions: true,
    type: "date-local",
    typeAttributes: { month: "2-digit", day: "2-digit" },
  },
  {
    label: "Coverage Amount",
    fieldName: "CoverageAmount",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
  },
];

const columnsInsuranceOther = [
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
      title: "Edit",
    },
  },
  { label: 'Insurance Policy Name' , fieldName: 'InsuranceName', hideDefaultActions: true, initialWidth : 190 },
  { label: "Product Type", fieldName: "ProductType", hideDefaultActions: true },
  { label: "Service Provider", fieldName: "serviceProvider", hideDefaultActions: true },
  { label: "Primary Owner", fieldName: "OwnerName", hideDefaultActions: true },
  // { label: "Carrier", fieldName: "Carrier", hideDefaultActions: true },
  //{ label: "Policy Number", fieldName: "Policy", hideDefaultActions: true },
  { label: "Insured", fieldName: "Insured", hideDefaultActions: true },
  {
    label: "Last Updated",
    fieldName: "AsOfDate",
    hideDefaultActions: true,
    type: "date-local",
    typeAttributes: { month: "2-digit", day: "2-digit" },
  },
  {
    label: "Amount",
    fieldName: "Amount",
    hideDefaultActions: true,
    type: "currency",
    typeAttributes: { currencyCode: 'USD', minimumFractionDigits: '0', maximumFractionDigits: '0'},
    cellAttributes: { alignment: "right" },
  },
];

export default class X7sWegInsuranceListView extends LightningElement {
  activeSections = [
    "AllInsurance",
    "InsuranceLife",
    "InsuranceLongTermCare",
    "InsuranceDisability",
    "InsuranceHealth",
    "InsurancePropertyAndCasualty",
    "InsuranceOther",
  ];
  currentUserId = userId;
  accountId;
  isDisplayComponent = false;
  totalAmt = 0;
  isModalOpen = false;

  insuranceHeader = "";
  insuranceBtnLabel = "";

  row;
  liabilityDescriptionList;
  liabilityDetail;
  isLoading = false;
  ownerList;

  insuranceId;
  insuranceResponse;

  insuranceId;
  insuranceName;
  insuranceProductType;
  insuranceServiceProvider;
  insuranceCarrier;
  insurancePolicy;
  insuranceOwnerName;
  insuranceInsured;
  insuranceInsuredAsset;
  insuranceAsOfDate;
  insuranceDeathBenefit = "";
  insuranceBenefitAmount = 0.0;
  insurancePremium = 0.0;
  insuranceCoverageAmount = 0.0;
  insuranceAmount = 0.0;
  insuranceCashValue = 0.0;
  insuranceRecordType;

  recordTypeList;
  bankCustodianList;

  //columns = columns;
  columnsInsuranceLife = columnsInsuranceLife;
  columnsInsuranceLongTerm = columnsInsuranceLongTerm;
  columnsInsuranceDisability = columnsInsuranceDisability;
  columnsInsuranceHealth = columnsInsuranceHealth;
  columnsInsurancePropertyAndCasualty = columnsInsurancePropertyAndCasualty;
  columnsInsuranceOther = columnsInsuranceOther;

  isDataListInsuranceLife = false;
  isDisplayDataList = false;
  isDataListInsuranceLongTerm = false;
  isDataListDisability = false;
  isDataListInsuranceHealth = false;
  isDataListInsurancePropertyAndCasualty = false;
  isDataListInsuranceOther = false;
  isDisplayRecordTypeSelection = false;
  hasRecordTypeSelection = false;

  @track dataList;
  @track dataListInsuranceLife;
  @track dataListInsuranceLongTerm;
  @track dataListDisability;
  @track dataListInsuranceHealth;
  @track dataListInsurancePropertyAndCasualty;
  @track dataListInsuranceOther;

  totalAmtInsuranceLife = 0;
  totalAmtInsuranceLongTerm = 0;
  totalAmtDisability = 0;
  totalAmtListInsuranceHealth = 0;
  totalAmtListPropertyAndCasualty = 0;
  totalAmtInsuranceOther = 0;

  isDisplayInsured = true;
  isDisplayInsuredAsset = true;
  isDisplayDeathBenefit = true;
  isDisplayCash = true;
  isDisplayPremium = true;
  isDisplayBenefitAmount = true;
  isDisplayCoverageAmount = true;
  isDisplayAmount = true;

  insuredList;
  productList;

  //insured
  insuredRecordTypeId;
  objectRecordTypeName = 'Insurance - Life';
  insuredPicklistFieldName = 'WEGP1_Insured__c';

  isRequiredFieldsFill = false;

  @api componentTitle = "Insurance";

  insuranceLifeProductType = [
    "Term",
    "Whole",
    "Universal",
    "Variable",
    "Variable Universal",
    "Indexed Universal",
    "Other",
  ];
  insuranceLongTermCareProductType = ["Traditional", "Hybrid", "Other"];
  insuranceDisabilityProductType = ["Short Term", "Long Term", "Other"];
  insuranceHealthProductType = ["Medical", "Dental", "Vision", "Other"];
  insurancePropertyProductType = [
    "Auto",
    "Homeowner's",
    "Umbrella",
    "Jewelry",
    "Other",
  ];
  insuranceOtherProductType = ["Burial", "Identity Protection", "Other"];

  renderedCallback() {
    Promise.all([loadStyle(this, insuranceDataTableStyle)]);
    if(this.template.querySelector('.RecordType')){
      this.template
        .querySelector('.RecordType')
        .classList.add('record-type-combobox');
    }
    
  }

  // get object info for unifi questionnaire
  @wire(getObjectInfo, { objectApiName: INSURANCE_OBJECT })
  objectInfo({data,error}) {
      if (error) console.error(error);
      if (data) {
          const insuredRecordTypes = Object.values(data.recordTypeInfos).find(i=>i.name===this.objectRecordTypeName); // undefined if there's no matching record type
          this.insuredRecordTypeId = insuredRecordTypes ? insuredRecordTypes.recordTypeId : '';
          //console.log('this.insuredRecordTypeId',this.insuredRecordTypeId);
      }
  };

  // get Insured picklist values using objectInfo
  @wire(getPicklistValuesByRecordType, {
      recordTypeId: '$insuredRecordTypeId',
      objectApiName: INSURANCE_OBJECT,
  })
  getPicklistValues({ data, error }) {
      if (error) console.error(error);
      if (data) {
          this.insuredListOptions = data.picklistFieldValues[this.insuredPicklistFieldName].values; 
      }
  }

  

  @wire(getProductType)
  wiredProductTypeRecord({ error, data }) {
    if (data) {
      this.productList = data;
    } else if (error) {
      console.error(error);
    }
  }

  @wire(getCustodianType)
  wiredCustodianRecord({ error, data }) {
    if (data) {
      this.bankCustodianList = data;
    } else if (error) {
      console.error(error);
    }
  }

  @wire(getInsuranceRecordType)
  wiredInsuranceRecordType({ error, data }) {
    if (error) {
      console.error("Error in get Record Type:", error);
    } else if (data) {
      this.recordTypeList = data;
      //console.log("this.recordTypeList", this.recordTypeList);
    }
  }

  @wire(getRecord, { recordId: "$currentUserId", fields: USER_FIELDS })
  wiredUserRecord({ error, data }) {
    if (error) {
      console.error("Error in getRecord:", error);
    } else if (data) {
      this.accountId = data.fields.AccountId.value;
    }
    console.log("AccountId = " + this.accountId);
  }

  @wire(getInsuranceDetails, { accountId: "$accountId" })
  wiredProfileDetails(response) {
    this.isLoading = true;
    this.isDisplayComponent = true;
    this.insuranceResponse = response;
    let error = response && response.error;
    let result;
    if (response && response["data"]) {
      if (response["data"]["all"]) {
        //console.log("riddhi insurance = " + JSON.stringify(response["data"]["all"]) );
        result = response["data"]["all"];
      }
      if (response["data"]["insuranceLife"]) {
        console.log(
          "###Insurance Life ==> " +
            JSON.stringify(response["data"]["insuranceLife"])
        );
        this.dataListInsuranceLife = JSON.parse(
          JSON.stringify(response["data"]["insuranceLife"])
        );
        if (this.dataListInsuranceLife.length > 0) {
          this.isDataListInsuranceLife = true;
          this.totalAmtInsuranceLife = this.dataListInsuranceLife.reduce(
            (acc, curr) => acc + curr.CashValue,
            0
          );
        }
      }

      if (response["data"]["insuranceLongTermCare"]) {
        //console.log("janavi insuranceLongTermCare = " + JSON.stringify(response["data"]["insuranceLongTermCare"]));
        this.dataListInsuranceLongTerm = JSON.parse(
          JSON.stringify(response["data"]["insuranceLongTermCare"])
        );
        if (this.dataListInsuranceLongTerm.length > 0) {
          this.isDataListInsuranceLongTerm = true;
          this.totalAmtInsuranceLongTerm =
            this.dataListInsuranceLongTerm.reduce(
              (acc, curr) => acc + curr.CashValue,
              0
            );
        }
      }

      if (response["data"]["insuranceDisability"]) {
        //console.log("janavi insuranceDisability = " + JSON.stringify(response["data"]["insuranceDisability"]));
        this.dataListDisability = JSON.parse(
          JSON.stringify(response["data"]["insuranceDisability"])
        );
        if (this.dataListDisability.length > 0) {
          this.isDataListDisability = true;
          this.totalAmtDisability = this.dataListDisability.reduce(
            (acc, curr) => acc + curr.BenefitAmount,
            0
          );
        }
      }

      if (response["data"]["insuranceHealth"]) {
        //console.log("janavi insuranceHealth = " + JSON.stringify(response["data"]["insuranceHealth"]));
        this.dataListInsuranceHealth = JSON.parse(
          JSON.stringify(response["data"]["insuranceHealth"])
        );
        if (this.dataListInsuranceHealth.length > 0) {
          this.isDataListInsuranceHealth = true;
          this.totalAmtListInsuranceHealth =
            this.dataListInsuranceHealth.reduce(
              (acc, curr) => acc + curr.Premium,
              0
            );
        }
      }

      if (response["data"]["insurancePropertyAndCasualty"]) {
        //console.log("janavi insurancePropertyAndCasualty = " + JSON.stringify(response["data"]["insurancePropertyAndCasualty"]));
        this.dataListInsurancePropertyAndCasualty = JSON.parse(
          JSON.stringify(response["data"]["insurancePropertyAndCasualty"])
        );
        if (this.dataListInsurancePropertyAndCasualty.length > 0) {
          this.isDataListInsurancePropertyAndCasualty = true;
          this.totalAmtListPropertyAndCasualty =
            this.dataListInsurancePropertyAndCasualty.reduce(
              (acc, curr) => acc + curr.CoverageAmount,
              0
            );
        }
      }

      if (response["data"]["insuranceOther"]) {
        //console.log("janavi insuranceOther = " + JSON.stringify(response["data"]["insuranceOther"]));
        this.dataListInsuranceOther = JSON.parse(
          JSON.stringify(response["data"]["insuranceOther"])
        );
        if (this.dataListInsuranceOther.length > 0) {
          this.isDataListInsuranceOther = true;
          this.totalAmtInsuranceOther = this.dataListInsuranceOther.reduce(
            (acc, curr) => acc + curr.Amount,
            0
          );
        }
      }
    }

    //this.totalAmt = this.totalAmtInsuranceLife + this.totalAmtInsuranceLongTerm + this.totalAmtInsuranceLongTerm + this.totalAmtDisability + this.totalAmtListInsuranceHealth + this.totalAmtListPropertyAndCasualty + this.totalAmtInsuranceOther;

    //let result = response && response.data;
    //let result = response['data']['all'];

    //console.log('riddhi insurance = '+ JSON.stringify(response.all));
    if (result) {
      this.dataList = [...result];
      let copyData = JSON.parse(JSON.stringify(this.dataList));
      this.dataList = [...copyData];
      if (this.dataList.length > 0) {
        this.isDisplayDataList = true;
      }
      console.log("this.dataList", this.dataList);
    } else if (error) {
      console.error("Error in getRecord:", error);
    }
    this.isLoading = false;
  }

  @wire(getOwnerList, { accountId : '$accountId' })
  wiredOwnerRecord({ error, data }) {
    if (data) {
      this.ownerList = data;
    } else if (error) {
      console.error(error);
    }
  }
  // @wire(getOwnerList, { accountId : '$accountId' })
  //   wiredOwnerList(response) {
  //       if (response) {

  //           this.ownerList = response['data'];
  //           if (this.debug) console.log('ownerList = '+JSON.stringify(this.ownerList));
  //       } else if (error) {
  //           if (this.debug) console.log('ownerList error = '+error);
  //           console.error('Error in get owner lists:', error);

  //       }
  //   }

  get insuranceRecordTypeOptions() {
    var insuranceRecordType = [];
    for (var i = 0; i < this.recordTypeList.length; i++) {
      insuranceRecordType.push({
        label: this.recordTypeList[i].Name.substring(12),
        value: this.recordTypeList[i].Name.substring(12),
      });
      // insuranceRecordType.push({
      //   label: this.recordTypeList[i].Name,
      //   value: this.recordTypeList[i].Name,
      // });
    }
    return insuranceRecordType;
  }

  get insuranceCustodianOptions() {
    var CustodianValues = [];
    for (let key in this.bankCustodianList) {
      CustodianValues.push({
        label: this.bankCustodianList[key],
        value: this.bankCustodianList[key],
      });
    }
    return CustodianValues;
  }

  get insuranceOwnerOptions() {
    var ownerValues = [];
    for (let key in this.ownerList) {
          ownerValues.push({
            label: this.ownerList[key],
            value: this.ownerList[key],
          });
    }
    return ownerValues;
  }

  get productListOptions() {
    var productTypeValues = [];
    for (let key in this.productList) {
      if (this.insuranceRecordType === "Life") {
        if (this.insuranceLifeProductType.includes(this.productList[key])) {
          productTypeValues.push({
            label: this.productList[key],
            value: this.productList[key],
          });
        }
      } else if (this.insuranceRecordType === "Long Term Care") {
        if (
          this.insuranceLongTermCareProductType.includes(this.productList[key])
        ) {
          productTypeValues.push({
            label: this.productList[key],
            value: this.productList[key],
          });
        }
      } else if (this.insuranceRecordType === "Disability") {
        if (
          this.insuranceDisabilityProductType.includes(this.productList[key])
        ) {
          productTypeValues.push({
            label: this.productList[key],
            value: this.productList[key],
          });
        }
      } else if (this.insuranceRecordType === "Health") {
        if (this.insuranceHealthProductType.includes(this.productList[key])) {
          productTypeValues.push({
            label: this.productList[key],
            value: this.productList[key],
          });
        }
      } else if (
        this.insuranceRecordType === "Property & Casualty"
      ) {
        if (this.insurancePropertyProductType.includes(this.productList[key])) {
          productTypeValues.push({
            label: this.productList[key],
            value: this.productList[key],
          });
        }
      } else if (this.insuranceRecordType === "Other") {
        if (this.insuranceOtherProductType.includes(this.productList[key])) {
          productTypeValues.push({
            label: this.productList[key],
            value: this.productList[key],
          });
        }
      } else {
        productTypeValues.push({
          label: this.productList[key],
          value: this.productList[key],
        });
      }
    }
    //console.log('PROD TYPE VALUES', productTypeValues);
    return productTypeValues;
  } 

  clearFormData() {
    this.insuranceId = "";
    this.insuranceName = "";
    this.insuranceProductType = "";
    this.insuranceServiceProvider = "";
    this.insuranceCarrier = "";
    this.insurancePolicy = "";
    this.insuranceOwnerName = "";
    this.insuranceInsured = "";
    this.insuranceInsuredAsset = "";
    this.insuranceAsOfDate = "";
    this.insuranceDeathBenefit = "";
    this.insuranceBenefitAmount = 0.0;
    this.insurancePremium = 0.0;
    this.insuranceCoverageAmount = 0.0;
    this.insuranceAmount = 0.0;
    this.insuranceCashValue = 0.0;
    this.insuranceRecordType = "";
    this.hasRecordTypeSelection = false;
    this.isRequiredFieldsFill = false;

  }

  handleRowAction(event) {
    this.isModalOpen = true;

    this.insuranceHeader = "Edit Insurance";
    this.insuranceBtnLabel = "Save Insurance";

    this.insuranceRecordType = event.detail.row.RecordType;
    this.insuranceRecordType = this.insuranceRecordType.substring(12);
    this.hasRecordTypeSelection = true;
    this.handleFieldDisplay(this.insuranceRecordType);
    
    console.log('###Insurance Record ==> ', event.detail.row);
    this.isDisplayRecordTypeSelection = false;
    this.row = event.detail.row;
    this.insuranceId = event.detail.row.Id;
    this.insuranceName = event.detail.row.InsuranceName;
    this.insuranceProductType = event.detail.row.ProductType;
    this.insuranceServiceProvider = event.detail.row.serviceProvider;
    this.insuranceCarrier = event.detail.row.serviceProvider;
    //this.insuranceCarrier = event.detail.row.Carrier;
    this.insurancePolicy = event.detail.row.Policy;
    this.insuranceOwnerName = event.detail.row.OwnerName;
    this.insuranceInsured = event.detail.row.Insured;
    this.insuranceInsuredAsset = event.detail.row.InsuredAsset;
    this.insuranceAsOfDate = event.detail.row.AsOfDate;
    this.insuranceDeathBenefit = event.detail.row.DeathBenefit;
    this.insuranceBenefitAmount = event.detail.row.BenefitAmount;
    this.insurancePremium = event.detail.row.Premium;
    this.insuranceCoverageAmount = event.detail.row.CoverageAmount;
    this.insuranceAmount = event.detail.row.Amount;
    this.insuranceCashValue = event.detail.row.CashValue;
  }

  handleinsuranceNameChange(event) {
    this.insuranceName = event.target.value;
  }
  handleinsuranceProductTypeChange(event) {
    this.insuranceProductType = event.target.value;
  }
  handleinsuranceServiceProviderChange(event) {
    this.insuranceServiceProvider = event.target.value;
  }
  handleinsuranceCarrierChange(event) {
     this.insuranceCarrier = event.target.value;
     this.insuranceServiceProvider = event.target.value;
  }
  handleinsurancePolicyChange(event) {
    this.insurancePolicy = event.target.value;
  }
  handleinsuranceOwnerNameChange(event) {
    this.insuranceOwnerName = event.target.value;
  }
  handleinsuranceInsuredChange(event) {
    this.insuranceInsured = event.target.value;
  }
  handleinsuranceInsuredAssetChange(event) {
    this.insuranceInsuredAsset = event.target.value;
  }
  handleinsuranceAsOfDateChange(event) {
    this.insuranceAsOfDate = event.target.value;
  }
  handleinsuranceDeathBenefitChange(event) {
    this.insuranceDeathBenefit = event.target.value;
  }
  handleinsuranceBenefitAmountChange(event) {
    this.insuranceBenefitAmount = event.target.value;
  }
  handleinsurancePremiumChange(event) {
    this.insurancePremium = event.target.value;
  }
  handleinsuranceCoverageAmountChange(event) {
    this.insuranceCoverageAmount = event.target.value;
  }
  handleinsuranceAmountChange(event) {
    this.insuranceAmount = event.target.value;
  }
  handleinsuranceCashValueChange(event) {
    this.insuranceCashValue = event.target.value;
  }

  handleInsuranceRecordTypeChange(event) {
    this.insuranceRecordType = event.target.value;
    if(this.insuranceRecordType){
      this.template.querySelector('.RecordType').classList.add('record-type-combobox-1');
    }
    console.log('###Insurance Record Type ==> ' + this.insuranceRecordType);
    this.handleFieldDisplay(this.insuranceRecordType);
  }

  validateInsuranceRequiredFields() {
    var validateCmp = '';
    /* if(!this.insuranceName){
        validateCmp = ".insuranceName";} 
    else if(!this.insuranceProductType){
      validateCmp = ".insuranceProductType";} 
    else if(!this.insuranceCarrier){
      validateCmp = ".insuranceCarrier";} 
    else if(!this.insurancePolicy){
      validateCmp = ".insurancePolicy";} 
    else if(!this.insuranceOwnerName){
      validateCmp = ".insuranceOwnerName";} 
    else if((!this.insuranceInsured) && (this.isDisplayInsured)){
      validateCmp = ".insuranceInsured";} 
    else if((!this.insuranceInsuredAsset) && (this.isDisplayInsuredAsset)){
      validateCmp = ".insuranceInsuredAsset";} 
    else if(!this.insuranceAsOfDate){
      validateCmp = ".insuranceAsOfDate";} 
    else if((!this.insuranceDeathBenefit) && (this.isDisplayDeathBenefit)){
      validateCmp = ".insuranceDeathBenefit";} 
    else if((!this.insuranceBenefitAmount) && (this.isDisplayBenefitAmount)){
      validateCmp = ".insuranceBenefitAmount";} 
    else if((!this.insurancePremium) && (this.isDisplayPremium)){
      validateCmp = ".insurancePremium";} 

    else if((!this.insuranceCoverageAmount)  && (this.isDisplayCoverageAmount)){
      validateCmp = ".insuranceCoverageAmount";}
    else if((!this.insuranceAmount)  && (this.isDisplayAmount)){
      validateCmp = ".insuranceAmount";} 
    else if((!this.insuranceCashValue)  && (this.isDisplayCash)){
      validateCmp = ".insuranceCashValue";} */
    if(!this.insuranceName){
      validateCmp = ".insuranceName";} 
    else if(!this.insuranceOwnerName){
        validateCmp = ".insuranceOwnerName";} 
    else {
        this.isRequiredFieldsFill = true;}
    if (validateCmp != '' ) {
        var inputCmp = this.template.querySelector(validateCmp);
        inputCmp.reportValidity();
        this.template.querySelector(validateCmp).focus();
        this.validateRequireFields = false;
    }
  }

  handleFieldDisplay(insuranceRecordType) {
    //console.log('insuranceRecordType',insuranceRecordType);
    if (insuranceRecordType === "Life") {
        this.isDisplayInsured = true;
        this.isDisplayInsuredAsset = false;
        this.isDisplayCash = true;
        this.isDisplayDeathBenefit = true;
        this.isDisplayPremium = false;
        this.isDisplayBenefitAmount = false;
        this.isDisplayCoverageAmount = false;
        this.isDisplayAmount = false;
        this.hasRecordTypeSelection = true;
      } else if (insuranceRecordType === "Long Term Care") {
        this.isDisplayInsured = true;
        this.isDisplayInsuredAsset = false;
        this.isDisplayCash = true;
        this.isDisplayDeathBenefit = true;
        this.isDisplayBenefitAmount = true;
        this.isDisplayPremium = false;
        this.isDisplayCoverageAmount = false;
        this.isDisplayAmount = false;
        this.hasRecordTypeSelection = true;
      } else if (insuranceRecordType === "Disability") {
        this.isDisplayInsured = true;
        this.isDisplayInsuredAsset = false;
        this.isDisplayBenefitAmount = true;
        this.isDisplayDeathBenefit = false;
        this.isDisplayCash = false;
        this.isDisplayPremium = false;
        this.isDisplayCoverageAmount = false;
        this.isDisplayAmount = false;
        this.hasRecordTypeSelection = true;
      } else if (insuranceRecordType === "Health") {
        this.isDisplayInsured = true;
        this.isDisplayInsuredAsset = false;
        this.isDisplayPremium = true;
        this.isDisplayDeathBenefit = false;
        this.isDisplayCash = false;
        this.isDisplayBenefitAmount = false;
        this.isDisplayCoverageAmount = false;
        this.isDisplayAmount = false;
        this.hasRecordTypeSelection = true;
      } else if (insuranceRecordType === "Property & Casualty") {
        this.isDisplayInsured = false;
        this.isDisplayInsuredAsset = true;
        this.isDisplayCoverageAmount = true;
        this.isDisplayDeathBenefit = false;
        this.isDisplayCash = false;
        this.isDisplayPremium = false;
        this.isDisplayBenefitAmount = false;
        this.isDisplayAmount = false;
        this.hasRecordTypeSelection = true;
      } else if (insuranceRecordType === "Other") {
        this.isDisplayInsured = true;
        this.isDisplayInsuredAsset = false;
        this.isDisplayAmount = true;
        this.isDisplayDeathBenefit = false;
        this.isDisplayCash = false;
        this.isDisplayPremium = false;
        this.isDisplayBenefitAmount = false;
        this.isDisplayCoverageAmount = false;
        this.hasRecordTypeSelection = true;
      }
  }

  getParam() {

    // if(this.isDisplayBenefitAmount){
    //   this.insuranceBenefitAmount  = this.getAmountFormatting(this.insuranceBenefitAmount);}
    // if(this.isDisplayPremium){
    //   this.insurancePremium  = this.getAmountFormatting(this.insurancePremium);}
    // if(this.isDisplayCoverageAmount){
    //   this.insuranceCoverageAmount  = this.getAmountFormatting(this.insuranceCoverageAmount);}
    // if(this.isDisplayAmount){
    //   this.insuranceCoverageAmount  = this.getAmountFormatting(this.insuranceAmount);}
    // if(this.isDisplayCash){
    //   this.insuranceCashValue  = this.getAmountFormatting(this.insuranceCashValue);}

    let params = {
      Id: "",
      InsuranceRecordType: this.insuranceRecordType,
      InsuranceName: this.insuranceName,
      ProductType: this.insuranceProductType,
      serviceProvider: this.insuranceServiceProvider,
      Carrier: this.insuranceServiceProvider,
      Policy: this.insurancePolicy,
      OwnerName: this.insuranceOwnerName,
      Insured: this.insuranceInsured,
      InsuredAsset: this.insuranceInsuredAsset,
      AsOfDate: this.insuranceAsOfDate,
      BenefitAmount: Math.round(this.insuranceBenefitAmount),
      DeathBenefit: Math.round(this.insuranceDeathBenefit),
      Premium: Math.round(this.insurancePremium),
      CoverageAmount: Math.round(this.insuranceCoverageAmount),
      Amount: Math.round(this.insuranceAmount),
      CashValue: Math.round(this.insuranceCashValue),
    };
    console.log('submit params', params);
    console.log('Asofdate:', params.AsOfDate);
    if(params.AsOfDate===""){
      params.AsOfDate = null;
    }
    return params;
  }

  getAmountFormatting(amount){
    let amt = amount;
    amt=amt.replace(/\,/g,''); //convert it to number
    return amt;
  }

  handleAddInsuranceClick(event) {
    this.clearFormData();
    this.isModalOpen = true;
    this.isDisplayRecordTypeSelection = true;
    this.insuranceHeader = "Add Insurance";
    this.insuranceBtnLabel = "Add Insurance";
    // if(this.template.querySelector('lightning-combobox[data-id="RecordType"]')){
    //   console.log('Inside my new Query selector');
    // }
  }

  closeModal() {
    this.clearFormData();
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

  /*submitDetails(){
    console.log('fire',this.getParam());
  }*/

  submitDetails() {
    this.isLoading = true;
    this.validateInsuranceRequiredFields();
    if (!this.isRequiredFieldsFill) {
        this.isLoading = false;
        return false;
    }
    if (this.insuranceId) { //we're editing
      console.log('###Inside Edit ==> ' + JSON.stringify(this.getParam()));
      editInsurance({
        insuranceId: this.insuranceId,
        accountId: this.accountId,
        insuranceInfo: JSON.stringify(this.getParam()),
      })
        .then((result) => {
          refreshApex(this.insuranceResponse);
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Insurance Update error::", JSON.stringify(error));
        })
        .finally(() => {
          this.isLoading = false;
        });
    } else {
      this.insuranceRecordType = 'Insurance - ' + this.insuranceRecordType;
      console.log('this.insuranceRecordType',this.getParam());
      addInsurance({
        accountId: this.accountId,
        insuranceInfo: JSON.stringify(this.getParam()),
        recordType: this.insuranceRecordType,
      })
        .then((result) => {
          refreshApex(this.insuranceResponse);
          this.clearFormData();
        })
        .catch((error) => {
          console.error("Insurance Insertionerror::", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    }
    this.isModalOpen = false;
  }
}