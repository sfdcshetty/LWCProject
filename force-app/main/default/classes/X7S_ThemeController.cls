global with sharing class X7S_ThemeController {
    /*
    @Name		  :  getSiteName
    @Description  :  Method to fetch the Network Name (Community Name) of the user's community so we can use it in our theme.
    */
    @AuraEnabled
    global static String getSiteName() {
        return X7S_ThemeController.getSiteNameInternal(System.Network.getNetworkId());
    }

    public static String getSiteNameInternal(String networkId) {
        try {
            if (String.isNotBlank(networkId))
            {
                Network communityNetwork = [ SELECT Id, Name FROM Network WHERE ID = :networkId WITH SECURITY_ENFORCED ]; return communityNetwork != null ? communityNetwork.Name : '';
            }
        } catch (Exception e) {
            System.debug('getSiteName() : ' + e.getMessage() + ' line number: ' + e.getLineNumber());
        }

        return '';
    }
}