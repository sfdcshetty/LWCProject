import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getQuickLinks from "@salesforce/apex/WEG_GetQuickLinksMetadata.getQuickLinks";
import USER_ID from "@salesforce/user/Id";

export default class X7sWegQuickLinks extends NavigationMixin(
  LightningElement
) {
  recordId;
  menuVisible = false;
  linksToPresentRaw = [];
  linksToPresentShowSecondRow = false;
  linksToPresentShowThirdRow = false;

  linksToPresent1 = [];
  linksToPresent2 = [];
  linksToPresent3 = [];

  linksToPresentShowSecondRow;
  linksToPresentThirdRow;

  connectedCallback() {
    let quicks;
    let quickLinks = [];
    this.recordId = USER_ID;
    getQuickLinks()
      .then((result) => {
        quicks = result;
        quicks.sort((a, b) =>
          a.Display_Order__c > b.Display_Order__c ? 1 : -1
        );
        for (let i = 0; i < quicks.length; i++) {
          quickLinks[i] = quicks[i];
        }
        this.linksToPresentRaw = quickLinks;
        this.linksToPresent1 = this.linksToPresentRaw.slice(0, 3);
        if (this.linksToPresentRaw.length > 3) {
          //we need to present a second row
          this.linksToPresent2 = this.linksToPresentRaw.slice(3, 8);
          this.linksToPresentShowSecondRow = true;
        }
        if (this.linksToPresentRaw.length > 8) {
          //we need to present a third row
          this.linksToPresent3 = this.linksToPresentRaw.slice(8, 12);
          this.linksToPresentShowThirdRow = true;
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  checkLink(linkObj) {
    if (
      linkObj.quicklinkTitle &&
      linkObj.quicklinkDestination &&
      linkObj.quicklinkIntOrExt
    ) {
      //check to make sure all values are populated
      return {
        title: linkObj.quicklinkTitle,
        destination: linkObj.quicklinkDestination,
        intOrExt: linkObj.quicklinkIntOrExt
      };
    }
    return null;
  }

  openLinks() {
    console.log("openLinks: " + this.menuVisible);
    if (this.menuVisible === false) {
      //treat the menu and icon after the click
      console.log("isfalse");
      this.menuVisible = true;
      this.template.querySelector(".drop-menu").classList.add("opaque-menu");
      this.template.querySelector(".chev-container").classList.add("rotated");
      this.template.querySelector(".list-open").classList.add("rotated");
    } else if (this.menuVisible === true) {
      console.log("istrue");
      this.menuVisible = false;
      this.template.querySelector(".drop-menu").classList.remove("opaque-menu");
      this.template
        .querySelector(".chev-container")
        .classList.remove("rotated");
      this.template.querySelector(".list-open").classList.remove("rotated");
    }
  }
}