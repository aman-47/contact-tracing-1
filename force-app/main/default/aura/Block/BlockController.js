({
    blockClickHandler : function(component, event, helper) {
        const open = component.get("v.open");
        if(!open){
            component.set("v.open", true);
            // get label value
            const label = component.get("v.label");
            // fire the event
            let compEvent = component.getEvent("click");
            compEvent.setParams({value : label });
            compEvent.fire();
        }
    },

    scriptsLoaded : function (component, event, helper){
        const divElement = component.getElement(".board-block");
        fitText(divElement);
    }
});
