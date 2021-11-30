import { LightningElement, wire, api, track } from "lwc";
import getInvestmentDetails from "@salesforce/apex/x7sInvestmentController.getInvestmentDetails";
import { getRecord } from "lightning/uiRecordApi";
import { loadStyle } from "lightning/platformResourceLoader";
import investmentDataTableStyle from "@salesforce/resourceUrl/x7sWebInvestmentDataTableStyle";
import userId from "@salesforce/user/Id";

const USER_FIELDS = ["User.AccountId"];

const columns = [
  {
    label: "Custodian",
    fieldName: "WEG_Custodian__c",
    hideDefaultActions: true,
    cellAttributes: { class: { fieldName: "CustodianColor" } }
  },
  {
    label: "Account Type",
    name: "WEG_Registration_Type__c",
    fieldName: "WEG_Registration_Type__c",
    hideDefaultActions: true,
    initialWidth: 170
  },
  {
    label: "Owner",
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
    initialWidth: 130
  }
];

export default class X7sInvestmentListView extends LightningElement {
  debug = true;

  //currentUserId = '0052f000001sMKHAA2'; // userId
  currentUserId = userId;
  @api componentTitle = "Investments With Us";
  @api introParagraph =
    "These accounts are automatically updated by us and are not editable. Have questions? Contact your advisory team.";

  @track dataList;
  accountId;
  isDisplayComponent = false;
  columns = columns;
  totalAmt = 0;

  defaultSortedBy = "FinServ__Balance__c";
  sortedBy;
  defaultSortDirection = "desc";
  sortDirection = "desc";

  renderedCallback() {
    Promise.all([loadStyle(this, investmentDataTableStyle)]);
  }

  @wire(getRecord, { recordId: "$currentUserId", fields: USER_FIELDS })
  wiredUserRecord({ error, data }) {
    if (error) {
      console.error("Error in getRecord:", error);
    } else if (data) {
      this.accountId = data.fields.AccountId.value;
      if (this.debug) console.log("this.accountId", this.accountId);
      if (this.accountId) {
        this.getInvestmentsDetails();
      }
    }
  }

  getInvestmentsDetails() {
    getInvestmentDetails({ accountId: this.accountId })
      .then((result) => {
        if (this.debug) console.log("investment data:", result);

        let mainData = [...result];
        let copyData = JSON.parse(JSON.stringify(mainData));
        copyData.forEach((element) => {
          element.FinServ__Balance__c = Math.round(element.FinServ__Balance__c);
          if (
            element.FinServ__Balance__c &&
            typeof element.FinServ__Balance__c === "number"
          )
            this.totalAmt = this.totalAmt + element.FinServ__Balance__c;
        });
        mainData = [...copyData];

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
        /*let copyData = JSON.parse(JSON.stringify(mainData));
            copyData.forEach(element => {
                element.CustodianColor = 'custodianColor';
                this.totalAmt += element.FinServ__Balance__c;
            });*/
        //this.totalAmt = mainData.reduce((acc,curr)=>acc+curr.FinServ__Balance__c,0);
        //this.isDisplayComponent = true;
        //this.dataList = [...copyData];;

        this.dataList = mainData.map((i) => ({
          ...i,
          CustodianColor: "custodianColor"
        }));

        if (this.debug)
          console.log("this.dataList = ", JSON.stringify(this.dataList));
        this.isDisplayComponent = true;
      })
      .catch((error) => {
        console.error("Investment Detail error::", error);
      });
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