/**
 * Created by 7Summits on 6/10/21.
 */

public with sharing class x7s_UserPhotoRetrieveFromCMSBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static final String CHANNELNAME = 'Wealth Enhancement Group Client Portal';

    public Integer pageNumber = 0;
    public Boolean runOnce = false;
    public Map<String, String> employeeNumberToImageMap;

    public x7s_UserPhotoRetrieveFromCMSBatch() { }
    public x7s_UserPhotoRetrieveFromCMSBatch(Integer pageNumber) {
        this.pageNumber = pageNumber;
    }

    /**
     * @description Batch Interface - start
     * @param bc
     *
     * @return
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('pageNumber: ' + pageNumber);
        employeeNumberToImageMap = mapEmployeeNumberToImageUrl(pageNumber);
        System.debug(employeeNumberToImageMap);
        return Database.getQueryLocator([
                SELECT Id, EmployeeNumber, Photo_URL__c
                FROM User
                WHERE EmployeeNumber IN :employeeNumberToImageMap.keySet()
        ]);
     }

    /**
     * @description Batch Interface - execute
     * @param bc
     * @param scope
     */
    public void execute(Database.BatchableContext bc, List<User> scope) {
        System.debug(scope);
        List<User> usersToUpdate = new List<User>();
        for(User u : scope){
            if(employeeNumberToImageMap != null && u.EmployeeNumber != null && employeeNumberToImageMap.containsKey(u.EmployeeNumber)){
                System.debug('User found: ' + u.EmployeeNumber);
                System.debug(employeeNumberToImageMap.get(u.EmployeeNumber));
                u.Photo_URL__c = employeeNumberToImageMap.get(u.EmployeeNumber);
                usersToUpdate.add(u);
            }
        }
        update usersToUpdate;
    }

    /**
     * @description Batch Interface - finish
     * @param bc
     */
    public void finish(Database.BatchableContext bc) {
        Integer nextPageNumber = pageNumber + 1;
        System.debug('Finished');
        System.debug(employeeNumberToImageMap);
        System.debug(nextPageNumber);
        if(employeeNumberToImageMap != null && employeeNumberToImageMap.size() > 0 && !runOnce) {
            System.debug('Next Batch');
            Database.executeBatch(new x7s_UserPhotoRetrieveFromCMSBatch(nextPageNumber));
        }
    }

    @testvisible
    private Map<String,String> mapEmployeeNumberToImageUrl(Integer pageNumber){
        employeeNumberToImageMap = new Map<String, String>();

        String channelId = getClientPortalChannelId();
        System.debug(channelId);

        String startDate = Datetime.now().addYears(-100).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        String endDate = Datetime.now().addYears(100).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

        ConnectApi.ManagedContentVersionCollection contentCollection;

        System.debug('channelId:::' + channelId);
   
        contentCollection = ConnectApi.ManagedContent.getAllContent(channelId, pageNumber, 200, 'en_US', 'cms_image', true, startDate, endDate, false);
        
        if(contentCollection != null && contentCollection.items != null && contentCollection.items.size() > 0) {
            for (ConnectApi.ManagedContentVersion version : contentCollection.items) {

                System.debug('contentItem='+version);
                //String contentName = (String) version.contentUrlName;
                String contentName = (String) version.title;
                System.debug('contentName and length='+contentName+ ' '+contentName.length());
                if(contentName.length() > 4){ //Filter out any name shorter than 5 characters
                    String char3 = contentName.substring(3, 4);
                    String char4 = contentName.substring(4, 5);
                    String employeeNumber;
                    System.debug('contentName='+contentName);
                    System.debug('char3='+char3);
                    System.debug('char4='+char4);
                    //Is 4th character numeric?  If so, keep going.  If not, use first 3 as employee number
                    if(char3.isNumeric()) {
                        System.debug('char3 is numeric...');
                        //Is 5th character numeric?  If so, make employee number 5 digits.  If not, use first 4 as employee number
                        if(char4.isNumeric()) {
                            System.debug('char4 is numeric...');
                            employeeNumber = '0' + contentName.substring(0, 5);
                        } else {
                            System.debug('char4 is NOT numeric...');
                            employeeNumber = '00' + contentName.substring(0, 4);
                        }
                    } else {
                        System.debug('char3 is NOT numeric...');
                        employeeNumber = '000' + contentName.substring( 0, 3 );
                    }
                    System.debug('employeeNumber and contentkey= '+ employeeNumber + ' ' + version.contentKey);
                    employeeNumberToImageMap.put(employeeNumber, '/clientportal/cms/delivery/media/' + version.contentKey);
                }
            }
        }
        System.debug('final employeeNumberToImageMap='+employeeNumberToImageMap);
        return employeeNumberToImageMap;
    }

    @testvisible
    private String getClientPortalChannelId(){
        ConnectApi.ManagedContentChannelCollection collection;
        String channelId;
        Integer pageIndex = 0;
        do{
            collection = ConnectApi.ManagedContent.getAllDeliveryChannels(pageIndex, null);

            for(ConnectApi.ManagedContentChannel channel : collection.channels){
                if(channel.channelName == CHANNELNAME){
                    channelId = String.valueOf(channel.channelId);
                    return channelId;
                }
            }

            ++pageIndex;
        }while(channelId == null && collection != null && collection.channels != null && collection.channels.size() > 0);

        return null;
    }
}