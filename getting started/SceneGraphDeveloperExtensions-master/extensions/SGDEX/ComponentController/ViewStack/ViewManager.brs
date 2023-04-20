' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub init()
    m.sid_object = {}
    m.ui_object = {}
    m.vo_object = {}
    
    'View stack array
    m.ssA = []
    
    'View stack component
    m.addView = addView 
    m.closeView = closeView
    m.closeToView = closeToView
    m.replaceCurrentView = replaceCurrentView
    m.syncOutProperties = syncOutProperties
    m.saveState = saveState
    
    m.top.observeField("change", "procedureObjectChange")
end sub

sub syncOutProperties()
    if m.ssUI <> invalid
        m.top.currentView = m.ssUI.getchild(0)
    else
        m.top.currentView = invalid
    end if
    m.top.ViewCount = m.ssA.Count()
end sub

sub viewStackUIChange()
    m.ssUI = m.top.viewStackUI
end sub

' >>>   procedureObject  part -----------------------------------------------------------------------------------------------------------
sub procedureObjectChange(event as Object)
    'execute all stacked events
    field = event.getField()
    if field = "change"
        maxEventsCount = 15
        while m.top.getChildCount() > 0 AND maxEventsCount > 0
            procedureNode = m.top.getChild(0)
            if procedureNode <> invalid 
                m.top.removeChildIndex(0)
                procedureObject = procedureNode.procedureObject
                if type(procedureObject) = "roAssociativeArray" and type(m[procedureObject.fn]) = "roFunction" then
                    ?"==============================================================================="
                    ?"SGDEX: Run Procedure from ViewManager child -> functionName = "procedureObject.fn
                    ?"==============================================================================="
                    runProcedure(procedureObject)
                end if
            else
                exit while
            end if
            maxEventsCount = maxEventsCount - 1
        end while
    else if field = "procedureObject" and m.top.procedureObject <> invalid
        procedureObject = m.top.procedureObject
        ?"==============================================================================="
        ?"SGDEX: Run Procedure from procedureObject field -> functionName = "procedureObject.fn
        ?"==============================================================================="
        if type(procedureObject) = "roAssociativeArray" and type(m[procedureObject.fn]) = "roFunction" then
            runProcedure(procedureObject)
        end if
    else
        ?"==============================================================================="
        ?"SGDEX: Run Procedure from "field" field -> functionName = "field
        ?"==============================================================================="
        data = event.getData()
        if type(m[field]) = "roFunction" and type(data) = "roAssociativeArray" and data.fp <> invalid then
            runProcedure({
                fn : field
                fp : data.fp
            })
        end if
    end if
end sub

' run procedure from 0 to 5 argunments
sub runProcedure(procedureObject)
    procedureParams = procedureObject.fp
    ? "SGDEX: View Manager runProcedure "; procedureObject.fn
    if type(procedureParams) = "roArray" then
        if procedureParams.count() = 0 then
            m[procedureObject.fn]()
        else if procedureParams.count() = 1 then
            m[procedureObject.fn](procedureParams[0])
        else if procedureParams.count() = 2 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1])
        else if procedureParams.count() = 3 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1], procedureParams[2])
        else if procedureParams.count() = 4 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1], procedureParams[2], procedureParams[3])
        else if procedureParams.count() = 5 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1], procedureParams[2], procedureParams[3], procedureParams[4])
        end if
    else
        m[procedureObject.fn]()
    end if
end sub
' <<<   procedureObject  part -----------------------------------------------------------------------------------------------------------

function createViewVO(NodeOrName, ViewInitData)

    if lcase(type(ViewComponentName)) = "rosgnode" then
        name = NodeOrName.id
    else
        name = NodeOrName
    end if
    previousViewSid = m.ssA.Peek()
    if previousViewSid <> invalid then
        previousViewsid = previousViewsid.sid
    else
        previousViewSid = ""
    end if
    ViewVO = {
        name : name
        init_data : ViewInitData
        current_state : {
            init_data : ViewInitData
            stop_data : invalid
            closed_View_data : invalid
            
            previousViewSid : previousViewSid
        }
        'View id
        sid : getViewId(NodeOrName)
    }
    
    m.vo_object[ViewVO.sid] = ViewVO
    
    return ViewVO
end function

function getViewId(NodeOrName)

    if lcase(type(NodeOrName)) = "rosgnode" then
        key = NodeOrName.id
    else
        key = NodeOrName
    end if
    
    value = m.sid_object[key]
    if value <> invalid then
        value = value + 1
    else
        value = 1
    end if
    
    m.sid_object[key] = value
    
    return key + "_" + itostr(value)
end function

sub addView(ViewComponentName, ViewInitData)
    nowViewUI = invalid
    'let previous View save it's state before opening new View
    'good for saving focused child     
    if m.ssA.Count() > 0 then
        nowViewVO = m.ssA.Peek()
        nowViewUI = m.ui_object[nowViewVO.sid]
        if nowViewUI.hasField("saveState") then
            nowViewUI.saveState = true
        end if
    end if
    ViewVO = createViewVO(ViewComponentName, ViewInitData)
    
    if lcase(type(ViewComponentName)) = "rosgnode" then
        UIObject = ViewComponentName
    else
        UIObject = createObject("roSGNode", ViewVO.name)
    end if
    
    m.ui_object[ViewVO.sid] = UIObject 
    newView = m.ui_object[ViewVO.sid]
    m.ssUI.appendChild(newView)
    if not newView.isinFocusChain() AND newView.focusedChild = invalid
        
        if newView.initialFocusedNode <> invalid
            ?"SGDEX: set focus to :"newView.initialFocusedNode.subtype()
            newView.initialFocusedNode.setfocus(true) 
        else
            if not newView.isInFocusChain()
                newView.setFocus(true)
                ?"SGDEX: newView.setFocus(true)"
            end if
        end if
    end if
    
    if newView.hasField("wasShown") then
        newView.wasShown = true
    end if
    
    if NOT newView.hasField("close") then
        newView.addField("close", "string", true)
    end if
    newView.observeFieldScoped("close", "RemoveThisViewFromStack")
    
    if nowViewUI <> invalid
        nowViewUI.visible = false
        m.ssUI.removeChild(nowViewUI)
    end if
    
    m.ssA.push(ViewVO)
    syncOutProperties()
end sub

sub closeView(sid = invalid, closeData = invalid)
    if m.ssA.Count() > 0 then
        closedViewVO = m.ssA.Pop()
        if m.ssA.Count() = 0
            if m.top.allowCloseChannelWhenNoViews = true
                scene = m.top.getScene()
                if scene <> Invalid and scene.hasField("exitChannel") then
                    scene.exitChannel = true
                    return
                end if
            end if
        end if
        closedViewUI = m.ui_object[closedViewVO.sid]
        'tell the View that it was closed
        ?"SGDEX: fire close for this View"
        if closedViewUI.hasField("wasClosed") then
            closedViewUI.wasClosed = true
        end if
        
        'Re-add previous View
        if m.ssA.Count() > 0 then
            nowViewVO = m.ssA.Peek()
            nowViewVO.current_state.closed_View_data = closeData
            nowViewUI = m.ui_object[nowViewVO.sid]
            if not IsNodeContainsChild(m.ssUI,nowViewUI) ' check if new View doesn't opened in close callback
                ?"SGDEX: Showing previous View"
                nowViewUI.visible = true
                m.ssUI.appendChild(nowViewUI)
                
                if nowViewVO.focusedNode <> invalid then
                    nowViewVO.focusedNode.setFocus(true)
                else
                    if not nowViewUI.isInFocusChain()
                        nowViewUI.setFocus(true)
                    end if
                end if    
                if nowViewUI.hasField("wasShown") then
                    nowViewUI.wasShown = true
                end if
            end if
        else
            ?"SGDEX: INFO : Last View was closed"
        end if
        
        'Delete and clean closed View
        closedViewUI = m.ui_object[closedViewVO.sid]
        closedViewUI.visible = false
        m.ssUI.removeChild(closedViewUI)    
        m.ui_object.delete(closedViewVO.sid)
        m.vo_object.delete(closedViewVO.sid)
    end if
    
    syncOutProperties()
end sub

sub closeToView(sid = invalid, closeData = invalid)
    if m.ssA.Count() > 0 then
        ViewVO = m.ssA.peek()
        closedViewVO = invalid
        closedViewUI = invalid
        if ViewVO <> invalid 
            if sid <> "" and Lcase(ViewVO.sid) <> LCase(sid)
                closedViewVO = m.ssA.Pop()
                closedViewUI = m.ui_object[closedViewVO.sid]
                'tell the View that it was closed
                if closedViewUI.hasField("wasClosed") then
                    closedViewUI.wasClosed = true
                end if
            end if
        end if
        
        'Re-add previous View
        
        if m.ssA.Count() > 0 
            nowViewVO = invalid
            count = m.ssA.Count()
            if sid <> invalid AND sid.len() > 0 then
                whileCounter = 100
                while true and whileCounter > 0
                    ViewVO = m.ssA.peek()
                    if ViewVO <> invalid 
                        if Lcase(ViewVO.sid) = LCase(sid)
                            nowViewVO = ViewVO
                            exit while
                        else
'                            if ViewVO.hasField("wasClosed") then
'                                ViewVO.wasClosed = true
'                            end if
                            m.ui_object.delete(ViewVO.sid)
                            m.vo_object.delete(ViewVO.sid)
                            'delete this View
                            m.ssA.pop()                
                        end if
                    else
                        ?"failed to get View"
                        exit while
                    end if
                    whileCounter--
                end while
            end if
            if nowViewVO = invalid then nowViewVO = m.ssA.Peek()
            if nowViewVO <> invalid
                nowViewVO.current_state.closed_View_data = closeData
                nowViewUI = m.ui_object[nowViewVO.sid]
                nowViewUI.visible = true
                m.ssUI.appendChild(nowViewUI)
                
                if nowViewVO.focusedNode <> invalid then
                    nowViewVO.focusedNode.setFocus(true)
                else
                    nowViewUI.setFocus(true)
                end if    
                if nowViewUI.hasField("wasShown") then
                    nowViewUI.wasShown = true
                end if
            else
                ?"SGDEX: closed to many View, check your id"
            end if
        else
            ?"SGDEX: problems with sid,  m.ssA.Count():" m.ssA.Count()", sid:["sid"]"
        end if
        
        'Delete and clean closed View
        if closedViewUI <> invalid and closedViewVO <> invalid
            closedViewUI = m.ui_object[closedViewVO.sid]
            closedViewUI.visible = false
            m.ssUI.removeChild(closedViewUI)    
            m.ui_object.delete(closedViewVO.sid)
            m.vo_object.delete(closedViewVO.sid)
        end if
    end if
    syncOutProperties()
end sub

sub replaceCurrentView(ViewComponentName, ViewInitData)
    if m.ssA.Count() > 0 then
        closedViewVO = m.ssA.Pop()
        
        'Add new View
        ViewVO = createViewVO(ViewComponentName, ViewInitData)
        m.ui_object[ViewVO.sid] = createObject("roSGNode", ViewVO.name)
        newView = m.ui_object[ViewVO.sid]
        m.ssUI.appendChild(newView)
        newView.setFocus(true)
        if newView.hasField("wasShown") then
            newView.wasShown = true
        end if    
        m.ssA.push(ViewVO)
        
        'Delete and clean closed View
        closedViewUI = m.ui_object[closedViewVO.sid]
        closedViewUI.visible = false
        m.ssUI.removeChild(closedViewUI)    
        m.ui_object.delete(closedViewVO.sid)
    end if
    
    syncOutProperties()
end sub

sub RemoveThisViewFromStack(event as Object)
    
    View = event.getROSGNode()
    if View <> invalid AND m.ssA.Count() > 0 then
        
        closedViewVO = m.ssA.peek()
        closedViewUI = m.ui_object[closedViewVO.sid]
        
        if closedViewUI.isSameNode(View) then
            'This is simple close so we can call it
            closeView("", {})
        else
            for index = m.ssa.count() - 1 to 0 step -1
                possibleView = m.ssa[index]
                if possibleView <> invalid then
                    possibleViewRSGNode = m.ui_object[possibleView.sid]
                    if possibleViewRSGNode <> invalid AND possibleViewRSGNode.isSameNode(View) then
                        ?"found View to close"
                        if possibleViewRSGNode.hasField("wasClosed") then
                            possibleViewRSGNode.wasClosed = true
                        end if
                        m.ui_object.delete(possibleView.sid)
                        m.vo_object.delete(possibleView.sid)
                        m.ssa.delete(index)
                        exit for
                    end if
                end if
            end for
        end if
    end if
end sub

sub saveState(sid , saveAA )
    ViewVO = m.vo_object[sid]
    if ViewVO <> invalid then
        ViewVO.current_state.stop_data = saveAA
    end if
end sub

function IsNodeContainsChild(node,child) as boolean
    if node <> invalid and child <> invalid
        for i = 0 to node.getchildcount() - 1
            n_child = node.getChild(i)
            if n_child <> invalid and n_child.isSameNode(child) then return true
        end for
    end if
    return false
end function

'==============================================================================
'                             Helper functions
'==============================================================================

'******************************************************
'itostr
'
'Convert int to string. This is necessary because
'the builtin Stri(x) prepends whitespace
'******************************************************
Function itostr(i As Integer) As String
    str = Stri(i)
    return strTrim(str)
End Function


'******************************************************
'Trim a string
'******************************************************
Function strTrim(str As String) As String
    st=CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function
