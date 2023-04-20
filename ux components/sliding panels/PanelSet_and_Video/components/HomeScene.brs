' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.loadingProgress = m.top.findNode("loadingProgress")
    m.loadingProgress.visible = true
    m.loadingProgress.control = "start"

    m.video = m.top.findNode("Video")
    m.video.observeField("state", "OnVideoPlaybackFinished")
    m.hud = m.top.findNode("Hud")
    m.Dialog = m.top.findnode("Dialog")
    m.PanelSet = m.top.findNode("PanelSet")
    m.listPanel = m.panelSet.CreateChild("ListPanel")
    m.listPanel.observeField("createNextPanelIndex", "OnCreateNextPanelIndex")
    
    m.DetailsListPanel = CreateObject("roSGNode", "LabelListPanel")
    m.DetailsListPanel.id = "DetailListPanel"
    m.DetailsListPanel.list.observeField("itemfocused", "OnDetailsListPanelItemFocused")
    m.DetailsListPanel.list.observeField("itemSelected", "OnDetailsListPanelItemSelected")
    
    'set left side list
    m.LabelList = CreateObject("roSGNode", "LabelList")
    m.LabelList.observeField("focusedItem", "OnLabelListSelected")
    m.listPanel.list = m.LabelList   
    m.listPanel.appendChild(m.LabelList)
    m.ListPanel.setFocus(true)
    
    m.top.backgroundURI = "pkg:/images/background.jpg"
End sub


'triggers when content received
'______________________________
Sub OnChangeLabelContent() 
    m.loadingProgress.control = "stop"
    m.LabelList.content = m.top.LabelContent
    m.loadingProgress.visible = false
End Sub 
Sub OnChangeOptionsContent()
    m.DetailsListPanel.list.content = m.top.OptionsContent
End Sub
Sub OnChangeContent()
    if m.ContentListPanel <> invalid then
        m.ContentListPanel.list.content=m.top.content
    end if
End Sub
'______________________________

Sub OnCreateNextPanelIndex()
    m.ContentListPanel       = CreateObject("roSGNode", "MarkupListPanel")  
    
    if m.ContentListPanel = invalid then return
    
    m.ContentListPanel.width = 984
    m.ContentListPanel.height = 524
    'setup layout of this panel
    list                     = m.ContentListPanel.list
    list.itemComponentName   = "VideoItem"
    list.itemSize            = [928, 524]
    list.itemSpacing         = [0, 30]
    list.observeField("itemFocused", "OnContentListPanelItemFocused")
    'set loading indicator to panel
    m.listPanel.nextPanel    = m.ContentListPanel
    if m.top.content <> invalid
        m.ContentListPanel.list.content = m.top.content
    end if
End Sub

Sub OnContentListPanelItemFocused()
    'appends details buttons if content row is focused
    if m.panelSet.FindNode(m.DetailsListPanel.id) = invalid then
        m.panelSet.AppendChild(m.DetailsListPanel)
    end if
    
    if m.ContentListPanel = invalid then return
    
    'gets focused content node
    list = m.ContentListPanel.list
    content = list.content.getChild(list.itemFocused)
    
    'spread focused content through depended nodes
    m.hud.content = content
    m.hud.show = false
    m.video.content = content
End Sub

Sub OnDetailsListPanelItemFocused()
    'if details buttons is focused then shows hud
    m.hud.show = true
End Sub

Sub OnDetailsListPanelItemSelected()
    'on button selected details button plays video
    m.video.visible="true"
    m.video.control="play"
    m.video.setFocus(true)
End Sub

Sub OnVideoPlaybackFinished()
    if m.video.state="finished" then
        m.video.visible = false
        m.video.control="stop"
        m.DetailsListPanel.setFocus(true)
    end if    
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press then
        if key="back" then
            'close video when we press back
            if m.video.visible then
                m.video.visible = false
                m.video.control="stop"
                m.DetailsListPanel.setFocus(true)
                result = true       
            end if     
        else if key="options" then
           'we are not in video playback
            If Not m.video.visible Then
                if NOT m.dialog.visible then
                    m.focusedNode = m.panelSet.focusedChild
                    m.dialog.visible = true
                    m.dialog.setFocus(true)
                    result = true
                else
                    m.dialog.visible = false 
                    m.focusedNode.SetFocus(true)
                    result = true
                end if
            end if
        end if
    else if key="back" and m.dialog.visible then
        m.Dialog.visible = false
        m.focusedNode.SetFocus(true)
        result = true           
    end if
    return result 
end function
