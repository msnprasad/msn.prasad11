trigger AA_EventTrigger on Event(
  before insert,
  before update,
  after delete,
  after insert,
  after update,
  before delete
) {
  ID salesKAHAssociate = AA_UtilityClass.getKAHAssociateID;
  ID salesKAHMarketManager = AA_UtilityClass.getKAHMarketManagerID;
  ID systemAdministrator = AA_UtilityClass.getSysAdminID;

  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      Map<String, Event> salesPerfIdsToEvents = new Map<String, Event>();
      Set<String> spIds = new Set<String>();
      Set<Id> ownerIds = new Set<Id>();
      Map<Id, ID> ownerIdsToProfileNames = new Map<Id, ID>();

      for (Event e : Trigger.new) {
        if (!ownerIds.contains(e.ownerId)) {
          ownerIds.add(e.ownerId);
        }
        /*if (e.IsRecurrence)
          e.Classic_Event_Series__c = true;
        if (e.RecurrenceActivityId != null && e.RecurrenceActivityId != e.Id)
          e.Classic_Event_Series__c = false;*/
      }

      for (User u : [SELECT Id, Profile.ID FROM user WHERE id IN :ownerIds]) {
        ownerIdsToProfileNames.put(u.Id, u.Profile.ID);
      }
        
      Integer i = 0;
        
      for (Event e : Trigger.new) {
          
        //Sales: KAH Associate test                                     //KAH Market Manager
        if (
          e.Type != 'PTO' &&
          (ownerIdsToProfileNames.get(e.ownerId) == salesKAHAssociate ||
          ownerIdsToProfileNames.get(e.ownerId) == salesKAHMarketManager)
        ) {
          try {
            Date d;
            if(e.ActivityDate!=null) d = e.ActivityDate;
            else if(e.ActivityDateTime!=null) d = Date.valueOf(e.ActivityDateTime);
            salesPerfIdsToEvents.put(
              e.OwnerId +
              mmyyyy(d) +
              String.valueOf(i),
              e
            );
            i++;
            if (!spIds.contains(e.OwnerId + mmyyyy(d))) {
              spIds.add(e.OwnerId + mmyyyy(d));
            }
          } catch (Exception err) {
            e.addError(
              'You must select and Date and Time for your activity to proceed.'
            );
          }
        } else {
          e.Sales_Performance_ID__c = null;
        }
      } //end for loop updated and inserted events
      List<Sales_Performance__c> salesPerfs = [
        SELECT Id, Sales_Performance_ID__c 
        FROM Sales_Performance__c
        WHERE Sales_Performance_ID__c IN :spIds
      ];//Sales_Calls__c
        
        
            
      Map<String, Id> invalidSpIdsToSpIds = new Map<String, Id>();
      for (String invalidSpId : salesPerfIdsToEvents.keySet()) {
        for (Sales_Performance__c sp : salesPerfs) {
          if (sp.Sales_Performance_ID__c == invalidSpId.substring(0, 24)) {
            invalidSpIdsToSpIds.put(invalidSpId, sp.Id);
          }
        }
      }

      for (String invalidSpId : salesPerfIdsToEvents.keySet()) {
        Event e = salesPerfIdsToEvents.get(invalidSpId);
        e.Sales_Performance_ID__c = invalidSpIdsToSpIds.get(invalidSpId);
      }
      //The update below causes LengthOfRelatedActivitiesToSalesCalls to be triggered
      //LengthOfRelatedActivitiesToSalesCalls sets the Sales_Calls__c field
      //to the number of tasks and events related to that Sales_Performance__c object
      update salesPerfs;
    }

    if (Trigger.isDelete) {
      AA_SalesCallTriggerHelper.deleteSalesEvent(Trigger.oldMap);
    }
  } else {
    //End if isBefore
    if (Trigger.isDelete) {
      //list of Sales_Performance_c IDs based on deleted events related Sales_Performance__c
      List<String> spIds = new List<String>();
      List<String> spIdsFromRecurrence = new List<String>();
      List<String> salesPerfToUpdateCount = new List<String>();
      for (Event e : Trigger.old) {
        if (
          e.IsRecurrence &&
          e.RecurrenceStartDateTime.date()
            .monthsBetween(e.RecurrenceEndDateOnly) >= 1
        ) {
          Integer mb = e.RecurrenceStartDateTime.date()
            .monthsBetween(e.RecurrenceEndDateOnly);
          for (Integer i = 0; i < mb; i++) {
            spIdsFromRecurrence.add(
              e.OwnerId + mmyyyy(e.RecurrenceStartDateTime.addMonths(i))
            );
          }
        }
          
          if((e.Sales_Subtype__c == 'COVID - F2F Sales Call') && e.Call_Status__c == 'Completed') {
              salesPerfToUpdateCount.add(e.OwnerId + mmyyyy(Date.valueOf(e.ActivityDate)));
          }
        spIds.add(e.Sales_Performance_ID__c);
      } //end for loop old deleted events
      //Query the Sales_Performance__c's from the list of Sales_Performance_c IDs
      List<Sales_Performance__c> salesPerfs = [
        SELECT Id, F2F_Calls__c
        FROM Sales_Performance__c
        WHERE Id IN :spIds OR Sales_Performance_ID__c IN :spIdsFromRecurrence OR Sales_Performance_ID__c IN :salesPerfToUpdateCount
      ];
        
        for(Sales_Performance__c salesPerf : salesPerfs) {
            if(salesPerfToUpdateCount.contains(salesPerf.Sales_Performance_ID__c)) {
                System.debug('**salesPerf.F2F_Calls__c :: ' + salesPerf.F2F_Calls__c);
            	salesPerf.F2F_Calls__c = (salesPerf.F2F_Calls__c != null ? salesPerf.F2F_Calls__c : 0) - 1;
            }
        }
      //The update below causes LengthOfRelatedActivitiesToSalesCalls to be triggered
      //LengthOfRelatedActivitiesToSalesCalls sets the Sales_Calls__c field
      //to the number of tasks and events related to that Sales_Performance__c object
      update salesPerfs;

      //Helper to delete Salescall events
      if (Trigger.isAfter) {
        // AA_SalesCallTriggerHelper.deleteSalesEvent(trigger.oldMap);
      }
    } else if (Trigger.isInsert) {
      //End if isDelete
      List<String> spIds = new List<String>();        
      Set<String> salesPerfToUpdateCount = new Set<String> ();
        
      for (Event e : Trigger.new) {
          if(( e.Sales_Subtype__c == 'COVID - F2F Sales Call') && e.Call_Status__c == 'Completed') {
              salesPerfToUpdateCount.add(e.OwnerId + mmyyyy(Date.valueOf(e.ActivityDate)));
          }
          
        if (e.Type != 'PTO' && e.Sales_Performance_ID__c != null) {
          spIds.add(e.Sales_Performance_ID__c);
        }
      }
      List<Sales_Performance__c> newSalesPerfs = [
        SELECT Id, F2F_Calls__c, Sales_Performance_ID__c
        FROM Sales_Performance__c
        WHERE Id IN :spIds OR Sales_Performance_ID__c IN :salesPerfToUpdateCount
      ];
        
        for(Sales_Performance__c salesPerf : newSalesPerfs) {
            if(salesPerfToUpdateCount.contains(salesPerf.Sales_Performance_ID__c)) {
                System.debug('**salesPerf.F2F_Calls__c :: ' + salesPerf.F2F_Calls__c);
            	salesPerf.F2F_Calls__c = (salesPerf.F2F_Calls__c != null ? salesPerf.F2F_Calls__c : 0) + 1;
            }
        }
        
      update newSalesPerfs;
      for (Event evt : Trigger.new) {
        system.debug('profileID:' + userInfo.getProfileId());
        if (
          evt.isRecurrence == true &&
          (system.today().daysBetween(evt.RecurrenceEndDateOnly) > 365)
        ) {
          evt.addError(
            'Event Series may only be scheduled 1 year out from the current date.  If you need to schedule an event out further, please consider other means, such as your Outlook calendar.'
          );
        }
      }

      //call to salescallhelper to insert new record
      if (Trigger.isAfter) {
        AA_SalesCallTriggerHelper.insertSalesEvent(Trigger.new);
      }
    } else if (Trigger.isUpdate) {
      //end if isInsert
      //System.debug('Number of events after update: '+Trigger.old.size()+Trigger.new.size());
      List<String> spIds = new List<String>();  
      Set<String> salesPerfToUpdateCount = new Set<String> ();
        
      for (Event e : Trigger.old) {
        if (e.Type != 'PTO') {
          spIds.add(e.Sales_Performance_ID__c);
        }
      }
      for (Event e : Trigger.new) {
          if(( e.Sales_Subtype__c == 'COVID - F2F Sales Call') && Trigger.oldmap.get(e.Id).Call_Status__c != 'Completed' && e.Call_Status__c == 'Completed') {
              salesPerfToUpdateCount.add(e.OwnerId + mmyyyy(Date.valueOf(e.ActivityDate)));
          }
          
        if (e.Type != 'PTO') {
          spIds.add(e.Sales_Performance_ID__c);
        }
      }
      List<Sales_Performance__c> newSalesPerfs = [
        SELECT Id, F2F_Calls__c, Sales_Performance_ID__c
        FROM Sales_Performance__c
        WHERE Id IN :spIds OR Sales_Performance_ID__c IN :salesPerfToUpdateCount
      ];
        
        for(Sales_Performance__c salesPerf : newSalesPerfs) {
            if(salesPerfToUpdateCount.contains(salesPerf.Sales_Performance_ID__c)) {
                System.debug('**salesPerf.F2F_Calls__c :: ' + salesPerf.F2F_Calls__c);
            	salesPerf.F2F_Calls__c = (salesPerf.F2F_Calls__c != null ? salesPerf.F2F_Calls__c : 0) + 1;
            }
        }
        
      update newSalesPerfs;
      //Helper tp update Salescall events
      if (Trigger.isAfter) {
        AA_SalesCallTriggerHelper.updateSalesEvent(
          Trigger.newMap,
          Trigger.oldMap
        );
      }
    } //end if Trigger is insert/update or delete/after update
  }

  public static string mmyyyy(Datetime d) {
    String mmyyyy;
    if (String.valueOf(d.month()).length() == 1) {
      mmyyyy = '0' + String.valueOf(d.month()) + String.valueOf(d.year());
    } else {
      mmyyyy = String.valueOf(d.month()) + String.valueOf(d.year());
    }
    return mmyyyy;
  } //end mmyyyy
}
