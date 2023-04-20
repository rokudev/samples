' ********** Copyright 2018 Roku Corp.  All Rights Reserved. ********** 
'
' The PanelSet example will start its initialization by creating a
' "SampleContent" node, which is the same content as the items within
' HomeScreen's rowlist. It will also call a helper function to setup
' the panels that will be displayed on screen.
sub init()
    m.panelSet = m.top.findNode("examplePanelSet")
    m.sampleContent = CreateObject("roSGNode", "SampleContent")

    setPanels()
end sub

' The setPanels() function will create a ListPanelExample component
' that will display the categories of the SampleContent node, while
' also setting certain fields in the ListPanelExample component to
' define certain functions and properties. The setPanels() function
' will also create a PanelExample component to display the categories'
' description based on what is currently focused in the ListPanelExample's
' LabelList.
function setPanels()
    m.listPanel = m.panelSet.createChild("ListPanelExample")
    m.listPanel.list.content = m.sampleContent
    m.listPanel.hasNextPanel = true
    m.listPanel.createNextPanelOnItemFocus = false
    m.listPanel.selectButtonMovesPanelForward = true

    m.panel = m.panelSet.createChild("PanelExample")
    m.panel.focusable = true
    m.panel.hasNextPanel = true
    m.panel.visible = true

    m.listPanel.list.observeField("itemFocused", "showDescription")
    m.panel.observeField("focusedChild", "slidePanels")

    m.listPanel.setFocus(true)
end function

' The showDescription() function will be called when an item in the
' ListPanelExample's LabelList is focused. This function will update
' the text of the label within the PanelExample component to reflect
' the description of what is currently highlighted. This also creates
' a GridPanelExample component that will be appended to the PanelSet
' if the user selects the category/list item from the ListPanelExample's
' LabelList.
function showDescription()
    itemContent = m.listpanel.list.content.getchild(m.listPanel.list.itemFocused)

    m.panel.description = itemContent.description

    m.gridPanel = CreateObject("roSGNode", "GridPanelExample")
    m.gridPanel.gridContent = itemContent
end function

' The slidePanels() function will change panels based on whether the user
' pressed the left or back button. If the user pressed the left or back
' button, the PanelExample and ListPanelExample components will be
' displayed and focus will return to the ListPanelExample component. If
' the user presses the right button (setting focus to the PanelExample
' component), this will cause the GridPanelExample component that was
' created previously in the showDescription() function to be appended
' to the PanelSet component and give focus to the GridPanelExample
' component.
function slidePanels()
    if not m.panelSet.isGoingBack
        m.panelSet.appendChild(m.gridPanel)
        m.gridPanel.setFocus(true)
    else
        m.listPanel.setFocus(true)
    end if
end function