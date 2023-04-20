' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub Init()
    m.top.ViewManager = createObject("roSGNode", "ViewManager")
    viewStackUI = m.top.findNode("ViewStack")
    m.top.ViewManager.viewStackUI = viewStackUI
    m.top.ViewManager.observeField("currentView","OnCurrentViewChange")
    m.top.observeField("allowCloseChannelOnLastView","OnAllowCloseChannel")
    m.top.allowCloseChannelOnLastView = true
end sub

function Show(config as Object)
    if GetInterface(config, "ifAssociativeArray") = invalid then
        ? "Error: Component controller, received wrong config"
        
        return invalid
    end if
    View = config.View
    if View = invalid then View = config.view 
    contentManager = config.contentManager
    
    data = {}
    
    if View <> invalid then
        subTypesSupported = { GridView: "" }
        subtype = View.subtype()
        parentType = View.parentSubtype(View.subtype())
        createContentManager = false
        if subtype <> invalid and subTypesSupported[subtype] <> invalid then
            createContentManager = true
        else if parentType <> invalid and subTypesSupported[parentType] <> invalid then
            createContentManager = true
        end if
        
        if createContentManager then
            if contentManager = invalid then contentManager = CreateObject("roSgNode", "ContentManager")
            ' attach this View to this content manager
            contentManager.Parent = m.top.getparent()
            
            contentManager.callFunc("setView", View)
            data.contentManager = contentManager
        end if
    end if
    
    m.top.ViewManager.callFunc("runProcedure", { 
        fn: "addView"
        fp: [View, data]
    })
        
    if contentManager <> invalid then
        contentManager.control = "start"
    end if
    'do other stuff for proper registering and unregistering events 
end function

sub OnCurrentViewChange()
    m.top.currentView = m.top.ViewManager.currentView
end sub

sub OnAllowCloseChannel(event as Object)
    allowCloseChannel = event.getData()
    ' need to pass this flag to View stack; it will set scene.exitChannel to true if no Views left
    m.top.ViewManager.allowCloseChannelWhenNoViews = allowCloseChannel
end sub

function onkeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press AND key = "back"
        handled = closeView()
    end if
    
    return handled
end function

' handles closing View in View stack
' if no View left, closes scene and exits channel
function closeView() as Boolean
    ' developer should receive back button when all Views are closed

    ' save flags locally because developer can change it in wasClosed callback
    allowCloseLastViewOnBack = m.top.allowCloseLastViewOnBack
    allowCloseChannelOnLastView = m.top.allowCloseChannelOnLastView

    result = m.top.ViewManager.ViewCount > 1
    
    ' allowCloseLastViewOnBack is checked here because if it is set to true we need to close the View even it is last View in stack
    if result or allowCloseLastViewOnBack
        m.top.ViewManager.callFunc("runProcedure", { 
            fn: "closeView"
            fp: ["", {}]
        })

        ' result is bool if count of Views is 2 or more, so View in stach is closed and back button successfully handled
        if result then return true

        ' if last View is closed check if developer opens a new one in wasClosed callback, if so, back is handled
        if allowCloseLastViewOnBack and not allowCloseChannelOnLastView
            if m.top.ViewManager.ViewCount > 0 then return true
        end if
        
        if allowCloseLastViewOnBack then
            return false
        end if
    end if
    return not allowCloseChannelOnLastView
end function
