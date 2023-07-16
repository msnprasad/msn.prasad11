({
	onsearchclick : function(component, event, helper) {
        helper.helperonsearch(component, event, helper);
	},
    newvalueselected : function(component, event, helper) {
        var carTypeId = component.find("carTypelist").get("v.value");
	alert(carTypeId+' option was clicked');	
	},
    doinit : function(component, event, helper) {
        component.set("v.carTypes",['sports cars','Luxary cars','vans']);
	
	},
    
})