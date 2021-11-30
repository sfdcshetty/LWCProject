import { LightningElement, api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class X7sWegExploreOurServices extends NavigationMixin(LightningElement) {
    @api title;
    @api buttonText;
    @api rowsDividedBy;

    @api link1Title;
    @api link1Url;
    @api link1External;
    
    @api link2Title;
    @api link2Url;
    @api link2External;

    @api link3Title;
    @api link3Url;
    @api link3External;

    @api link4Title;
    @api link4Url;
    @api link4External;
    
    @api link5Title;
    @api link5Url;
    @api link5External;
    
    @api link6Title;
    @api link6Url;
    @api link6External;

    @api link7Title;
    @api link7Url;
    @api link7External;

    @api link8Title;
    @api link8Url;
    @api link8External;

    @api link9Title;
    @api link9Url;
    @api link9External;

    @api link10Title;
    @api link10Url;
    @api link10External;
    
    @api link11Title;
    @api link11Url;
    @api link11External;

    @api link12Title;
    @api link12Url;
    @api link12External;

    @api link13Title;
    @api link13Url;
    @api link13External;
    
    @api link14Title;
    @api link14Url;
    @api link14External;
    
    @api link15Title;
    @api link15Url;
    @api link15External;

    @api link16Title;
    @api link16Url;
    @api link16External;

    @api link17Title;
    @api link17Url;
    @api link17External;

    @api link18Title;
    @api link18Url;
    @api link18External;

    links = [];
    links1 = [];
    links2 = [];
    links3 = [];
    presentLinks1 = true;
    presentLinks2 = false;
    presentLinks3 = false;

    connectedCallback(){

        this.links = [
            { 
                title: this.link1Title,
                url: this.link1Url, 
                external: this.link1External
            },
            { 
                title: this.link2Title,
                url: this.link2Url, 
                external: this.link2External
            },
            { 
                title: this.link3Title,
                url: this.link3Url, 
                external: this.link3External
            },
            { 
                title: this.link4Title,
                url: this.link4Url, 
                external: this.link4External
            },
            { 
                title: this.link5Title,
                url: this.link5Url, 
                external: this.link5External
            },
            { 
                title: this.link6Title,
                url: this.link6Url, 
                external: this.link6External
            },
            { 
                title: this.link7Title,
                url: this.link7Url, 
                external: this.link7External
            },
            { 
                title: this.link8Title,
                url: this.link8Url, 
                external: this.link8External
            },
            { 
                title: this.link9Title,
                url: this.link9Url, 
                external: this.link9External
            },
            { 
                title: this.link10Title,
                url: this.link10Url, 
                external: this.link10External
            },
            { 
                title: this.link11Title,
                url: this.link11Url, 
                external: this.link11External
            },
            { 
                title: this.link12Title,
                url: this.link12Url, 
                external: this.link12External
            },
            { 
                title: this.link13Title,
                url: this.link13Url, 
                external: this.link13External
            },
            { 
                title: this.link14Title,
                url: this.link14Url, 
                external: this.link14External
            },
            { 
                title: this.link15Title,
                url: this.link15Url, 
                external: this.link15External
            },{ 
                title: this.link16Title,
                url: this.link16Url, 
                external: this.link16External
            },{ 
                title: this.link17Title,
                url: this.link17Url, 
                external: this.link17External
            }
            ,{ 
                title: this.link18Title,
                url: this.link18Url, 
                external: this.link18External
            }
        ];

        console.log(this.links);

        this.links1 = this.breakOutLinks(this.links1, this.links, 0, this.rowsDividedBy);

        if(this.links.length/this.rowsDividedBy > 1){
            this.links2 = this.breakOutLinks(this.links2, this.links, this.rowsDividedBy, (this.rowsDividedBy*2));
            if(this.links2.length>0) this.presentLinks2 = true;
            
        }
        if(this.links.length/(this.rowsDividedBy * 2) > 1){
            this.links3 = this.breakOutLinks(this.links3, this.links, this.rowsDividedBy*2, (this.rowsDividedBy*3));
            if(this.links3.length>0) this.presentLinks3 = true;

        }
    }

    breakOutLinks(linksToBreakOut, fullLinkList, startValue, rowsToBreakOn){
        linksToBreakOut =  this.links.slice(startValue, rowsToBreakOn);
        return linksToBreakOut;
    }

    goToWegSite(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.wealthenhancement.com'
            }
        });
    }
}