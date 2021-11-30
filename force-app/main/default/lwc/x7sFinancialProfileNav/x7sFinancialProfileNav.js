/**
 * Created by martinblase on 4/6/21.
 */

//import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { api, track, LightningElement } from "lwc";

export default class X7sFinancialProfileNav extends LightningElement {
    @api showMenu = false;
    @api menuItems = []; // array of objects from parent component

    _currentIndex = 0;
    @api set currentIndex(val) {
        this._currentIndex = val;
        this.updateMenuItems(val);
    }
    get currentIndex() { return this._currentIndex; }

    get menuIcon() {
        return (this.showMenu) ? 'utility:close' : 'utility:rows';
    }

    get menuClasses() {
        return 'x7s-finprofile_menu-wrapper ' + (this.showMenu ? 'slds-transition-show' : 'slds-transition-hide');
    }

    handleMenuButtonClick(event) {
        this.showMenu = !this.showMenu;
    }

    handleNavClick(event) {
        let formIdx = event.currentTarget.dataset.formIdx;
        //fireEvent('navClick','nav item clicked');
        this.dispatchEvent(new CustomEvent('navigate',{
            detail: { index: formIdx }
        } ));
        this.updateMenuItems(formIdx);
        setTimeout(()=>{ this.hideMenu() }, 700);
    }

    updateMenuItems(idx) {
        this.menuItems = this.menuItems.map((i,currIndex)=>({
            ...i,
            isActive: (currIndex == idx),
        }));
    }

    @api hideMenu() {
        this.showMenu = false;
    }
}