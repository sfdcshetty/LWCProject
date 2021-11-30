/*--
  ~ Copyright (c) 2020. 7Summits Inc. All rights reserved.
  --*/

  ({
    handleFixedNav: function(component, event, helper) {
        var pinElement;
        var removePinElem;
        var pinClass = 'x7s-theme-pinnable';
        var isPinnedClass = 'x7s-theme-pinnable__pinned';
        var truncateClass = "x7s-theme-pinnable__truncated";

        // Set offsetAmount to 0, because the spacing needs to be applied at the site theme level
        var offsetAmount = helper.getHeaderHeight();

        if (component.find("dataPinnable")) {
            pinElement = component.find("dataPinnable").getElement();
        }
        if (component.find("dataRemovePinnable")) {
            removePinElem = component.find("dataRemovePinnable").getElement();
        }
        if (pinElement) {
            pinElement.classList.add(pinClass);
            pinElement.firstElementChild.style.width = pinElement.clientWidth + 'px';
        }

        var scrollPos = window.scrollY || document.documentElement.scrollTop;

        if(pinElement && removePinElem) {
            var removePinAt = ((removePinElem.offsetTop - offsetAmount) - pinElement.firstElementChild.clientHeight) || scrollPos;

            pinElement.firstElementChild.clientHeight > window.innerHeight ?
                pinElement.classList.add(truncateClass):
                pinElement.classList.remove(truncateClass);
        
            if ((pinElement.offsetTop) < scrollPos + offsetAmount) {
                pinElement.classList.add(isPinnedClass);
                if (scrollPos > removePinAt) {
                    pinElement.firstElementChild.style.top = ((removePinAt - scrollPos) + offsetAmount) + 'px';
                } else {
                    pinElement.firstElementChild.style.top = offsetAmount + 'px';
                }
            }
            else if (pinElement.offsetTop >= scrollPos + offsetAmount) {
                pinElement.classList.remove(isPinnedClass);
                pinElement.firstElementChild.style.top = 0;
            }
        }
    }, 

    getHeaderHeight: function() {
        var headerElement = document.getElementsByClassName('x7s-header')[0];
        var navElement = document.getElementsByClassName('x7s-theme__single-bar-header')[0];
        var headerHeight = 0;
        // If the header is fixed, we need to grab the headers height and use that
        if (navElement && headerElement && headerElement.classList.contains('x7s-header_fixed')) {
            headerHeight = navElement.offsetHeight;
        }
        // Add a padding to the fixed sidebar so it doesn't stick DIRECTLY underneat the nav
        // 24 px is approximately the width between columns
        headerHeight = headerHeight + 24; 

        return headerHeight;
    }
})