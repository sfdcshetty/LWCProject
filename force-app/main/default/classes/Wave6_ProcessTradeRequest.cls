/******************************************************************************************************************************
* @class name    : Wave6_ProcessTradeRequest
* @description   : This class contains invokable method to create Trade request from Process builder which is used to create trade request.
*                  This class contain common static methos which is being used by invokable method as well as Wave6_TradeRequestBatch class.    
* @test class    : Wave6_ProcessTradeRequestTest
* @author        : Ganesh Ekhande
* @date          : 05/18/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/18/2017             Created.
* Ganesh Ekhande              08/07/2017             Removed reference of WEGP1_Model__c,WEGP1_FixedIncomeSleeve__c,WEGP1_InflationFocusedSleeve__c,WEGP1_EquitySleeve__c  fields.  
******************************************************************************************************************************/
public class Wave6_ProcessTradeRequest{
    public static string baseQuery =  'SELECT Id, RecordTypeId, WEGP1_AccountRestricted__c, Advisor__c, WEGP1_AdvisorTradeReview__c, WEGP1_Allocation__c, WEGP1_BondCUSIP__c, WEGP1_BuySell__c, '+
                                      'WEGP1_CashExclusion__c, WEGP1_CashExclusionType__c, WEGP1_ClientPickedBond__c, WEGP1_CurrentCashExclusion__c, WEGP1_ABPSubmitted__c, WEGP1_DayOnly__c, '+
                                      'WEGP1_DCAAmoumt__c, WEGP1_Deposit__c, WEGP1_DiscretionaryPL__c, WEGP1_Distribute__c, WEGP1_DistributionInstructions__c, WEGP1_DividendsReinvest__c, '+
                                      'WEGP1_DollarAmount__c,  WEGP1_ExclusionPrice__c, WEGP1_FederalTax__c, WEGP1_FinancialAccount__c,  '+
                                      'WEGP1_Frequency__c, WEGP1_GBCB__c, WEGP1_GoodCancelled__c, WEGP1_Household__c, WEGP1_IMDistribution__c, WEGP1_Individual__c,  '+
                                      'WEGP1_LastTradeDate__c, WEGP1_LimitPrice__c, WEGP1_LowCorrelation__c, WEGP1_MarketOrder__c,  WEGP1_MSSnapshot__c, WEGP1_NetGross__c, '+
                                      'WEGP1_NextTradeDate__c, WEGP1_NAFD__c, WEGP1_Notes__c, WEGP1_NumberPositions__c, WEGP1_PlanName__c, WEGP1_PutCall__c, WEGP1_ReasonRejection__c, '+
                                      'WEGP1_Responsible__c, WEGP1_SolicitedPL__c, WEGP1_SpecialTax__c, WEGP1_StartDate__c, WEGP1_StateTax__c, Status__c, WEGP1_StopPrice__c, WEGP1_TILIC__c, '+
                                      'WEGP1_Ticker__c, WEGP1_Transactions__c, WEGP1_ParentTradeRequest__c FROM Trade_Request__c ';

    
     /*
    * @author       : Ganesh Ekhande
    * @description  : This is invokable method which is used to create Trade Request.
    * @created      : 05/18/2017
    * @param        : list<ParentIds> parentTRIds 
    * @return       : void
    */
    @InvocableMethod(label='Wave6_CreateTradeRequest')
    public static void TradeRequestAction(List<Wave6_ProcessTradeRequest.ParentIds> parentTRIds ){
        
        system.debug('parentTRIds:>>'+parentTRIds);
        
        List<Id> parentIds = new List<Id>();
        List<Trade_Request__c> parentTradeRequests = new List<Trade_Request__c>();
        
        if(!parentTRIds.isEmpty()){
            for(Wave6_ProcessTradeRequest.ParentIds parent : parentTRIds){
                parentIds.add(parent.tradeReqId);
            }
            
            string qry ='';
            qry = baseQuery + 'WHERE Id IN: parentIds';
            system.debug('qry:>>'+qry);
            
            parentTradeRequests = database.query(qry);
            system.debug('parentTradeRequests:>>'+parentTradeRequests);
            
            if(!parentTradeRequests.isEmpty()){
                createTradeRequests(parentTradeRequests);
            }
        }
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is method creates clone of the Trade Request.
    * @created      : 05/18/2017
    * @param        : list<Trade_Request__c> parentTradeRequests 
    * @return       : void
    */
    public static void createTradeRequests(List<Trade_Request__c> parentTradeRequests){
         try{
            system.debug('parentTradeRequests:>>'+parentTradeRequests);
            List<Trade_Request__c> newTradeReqList = new List<Trade_Request__c>();
            List<Trade_Request__c> UpdatedTradeReqList = new List<Trade_Request__c>();
             
            RecordType dcaRecordType = [SELECT ID, Name, DeveloperName FROM RecordType WHERE DeveloperName='DCA_Trading_Ticket' and sObjectType = 'Trade_Request__c' LIMIT 1];
             
             
            for(Trade_Request__c tradeRequest : parentTradeRequests){
                // Get the default business hours
                BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
                
                // Find whether the time is within the default business hours
                Boolean isWithin = BusinessHours.isWithin(bh.id, system.now());
                system.debug('isWithin:>>'+isWithin);
                
                if(isWithin){
                    // Update Last Trade Date to current date on existing Trade Requests.    
                    Trade_Request__c tR = new Trade_Request__c();
                    tR.Id = tradeRequest.Id;
                    tR.WEGP1_LastTradeDate__c = System.Today();
                    UpdatedTradeReqList.add(tR);
                    
                    // Create new Trade Requests for each existing Trade request Fetched in Start Method
                    Trade_Request__c newTradeRequest =  new Trade_Request__c();
                    newTradeRequest.RecordTypeId =                  dcaRecordType.ID;
                    newTradeRequest.WEGP1_ParentTradeRequest__c =   tradeRequest.Id;
                    newTradeRequest.Status__c =                     'New';
         
                    newTradeRequest.WEGP1_StartDate__c =            tradeRequest.WEGP1_StartDate__c;
        
                    //clone the appropriate fields 
                    newTradeRequest.WEGP1_AccountRestricted__c =    tradeRequest.WEGP1_AccountRestricted__c;
                    newTradeRequest.Advisor__c =                    tradeRequest.Advisor__c;
                    newTradeRequest.WEGP1_AdvisorTradeReview__c =   tradeRequest.WEGP1_AdvisorTradeReview__c;
                    newTradeRequest.WEGP1_Allocation__c =           tradeRequest.WEGP1_Allocation__c;
                    newTradeRequest.WEGP1_BondCUSIP__c =            tradeRequest.WEGP1_BondCUSIP__c;
                    newTradeRequest.WEGP1_BuySell__c =              tradeRequest.WEGP1_BuySell__c;
                    newTradeRequest.WEGP1_CashExclusion__c =        tradeRequest.WEGP1_CashExclusion__c;
                    newTradeRequest.WEGP1_CashExclusionType__c =    tradeRequest.WEGP1_CashExclusionType__c;
                    newTradeRequest.WEGP1_ClientPickedBond__c =     tradeRequest.WEGP1_ClientPickedBond__c;
                    newTradeRequest.WEGP1_CurrentCashExclusion__c = tradeRequest.WEGP1_CurrentCashExclusion__c;
                    newTradeRequest.WEGP1_ABPSubmitted__c =         tradeRequest.WEGP1_ABPSubmitted__c;
                    newTradeRequest.WEGP1_DayOnly__c =              tradeRequest.WEGP1_DayOnly__c;
                    newTradeRequest.WEGP1_DCAAmoumt__c =            tradeRequest.WEGP1_DCAAmoumt__c;
                    newTradeRequest.WEGP1_Deposit__c =              tradeRequest.WEGP1_Deposit__c;
                    newTradeRequest.WEGP1_DiscretionaryPL__c =      tradeRequest.WEGP1_DiscretionaryPL__c;
                    newTradeRequest.WEGP1_Distribute__c =           tradeRequest.WEGP1_Distribute__c;
                    newTradeRequest.WEGP1_DistributionInstructions__c = tradeRequest.WEGP1_DistributionInstructions__c;
                    newTradeRequest.WEGP1_DividendsReinvest__c =    tradeRequest.WEGP1_DividendsReinvest__c;
                    newTradeRequest.WEGP1_DollarAmount__c =         tradeRequest.WEGP1_DollarAmount__c;
                    newTradeRequest.WEGP1_ExclusionPrice__c =       tradeRequest.WEGP1_ExclusionPrice__c;
                    newTradeRequest.WEGP1_FederalTax__c =           tradeRequest.WEGP1_FederalTax__c;
                    newTradeRequest.WEGP1_FinancialAccount__c =     tradeRequest.WEGP1_FinancialAccount__c;
                    newTradeRequest.WEGP1_GBCB__c =                 tradeRequest.WEGP1_GBCB__c;
                    newTradeRequest.WEGP1_GoodCancelled__c =        tradeRequest.WEGP1_GoodCancelled__c;
                    newTradeRequest.WEGP1_Household__c =            tradeRequest.WEGP1_Household__c;
                    newTradeRequest.WEGP1_IMDistribution__c =       tradeRequest.WEGP1_IMDistribution__c;
                    newTradeRequest.WEGP1_Individual__c =           tradeRequest.WEGP1_Individual__c;
                    newTradeRequest.WEGP1_LimitPrice__c =           tradeRequest.WEGP1_LimitPrice__c;
                    newTradeRequest.WEGP1_LowCorrelation__c =       tradeRequest.WEGP1_LowCorrelation__c;
                    newTradeRequest.WEGP1_MarketOrder__c =          tradeRequest.WEGP1_MarketOrder__c;
                    newTradeRequest.WEGP1_MSSnapshot__c =           tradeRequest.WEGP1_MSSnapshot__c;
                    newTradeRequest.WEGP1_NetGross__c =             tradeRequest.WEGP1_NetGross__c;
                    newTradeRequest.WEGP1_NAFD__c =                 tradeRequest.WEGP1_NAFD__c;
                    newTradeRequest.WEGP1_Notes__c =                tradeRequest.WEGP1_Notes__c;
                    newTradeRequest.WEGP1_NumberPositions__c =      tradeRequest.WEGP1_NumberPositions__c;
                    newTradeRequest.WEGP1_PlanName__c =             tradeRequest.WEGP1_PlanName__c;
                    newTradeRequest.WEGP1_PutCall__c =              tradeRequest.WEGP1_PutCall__c;
                    newTradeRequest.WEGP1_ReasonRejection__c =      tradeRequest.WEGP1_ReasonRejection__c;
                    newTradeRequest.WEGP1_Responsible__c =          tradeRequest.WEGP1_Responsible__c;
                    newTradeRequest.WEGP1_SolicitedPL__c =          tradeRequest.WEGP1_SolicitedPL__c;
                    newTradeRequest.WEGP1_SpecialTax__c =           tradeRequest.WEGP1_SpecialTax__c;
                    newTradeRequest.WEGP1_StateTax__c =             tradeRequest.WEGP1_StateTax__c;
                    
                    newTradeRequest.WEGP1_StopPrice__c =            tradeRequest.WEGP1_StopPrice__c;
                    newTradeRequest.WEGP1_TILIC__c =                tradeRequest.WEGP1_TILIC__c;
                    newTradeRequest.WEGP1_Ticker__c =               tradeRequest.WEGP1_Ticker__c;
                    newTradeRequest.WEGP1_Transactions__c =         tradeRequest.WEGP1_Transactions__c;
                    
                    newTradeReqList.add(newTradeRequest); 
                }
            }
            
            system.debug('newTradeReqList:>>'+newTradeReqList);
            database.update(UpdatedTradeReqList,false);
            database.insert(newTradeReqList,false);
        }catch(exception ex){
            system.debug('Error occurred while processing Trade Requests.');    
        }
    }
    
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : Inner wrapper class which wraps different inputs required for invokable action.
    * @created      : 05/18/2017
    */
    public class ParentIds {
    
        @InvocableVariable(label='Trade request Id' description='Required. The Id of the Parent record.' required=true)
        public String tradeReqId;
        
    }
}