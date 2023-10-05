({
    handleSelect: function (component, event, helper) {
        let view = component.get("v.view");
        const selectedTabId = event.getParam("id");
        if(selectedTabId === 'person'){
            component.set("v.headerTitle", "Person View");
        } else{
            component.set("v.headerTitle", 'Location View');
        }
        component.set("v.scope", selectedTabId);

        const healthHeadercomp = component.find("healthHeader");
        healthHeadercomp.fetchCount();
    }
})
