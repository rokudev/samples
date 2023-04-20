sub addRowListTestItem(label as string, component as string)
   testListItemNode = createObject("RoSGNode", "RowListExampleContentNode")

   ' setting title will set the RowListExampleContentNode's ContentMetaData field
   testListItemNode.title = label

   ' setting componentName will set the RowListExampleContentNode's componentName
   ' interface field
   testListItemNode.componentName = component

   m.rowListTestListContent.appendChild(testListItemNode)
end sub

function focusChanged()
    if m.top.isInFocusChain()
        m.list.setFocus(true)
    end if
end function

function createRowListExamplePanel()
    listItemContent = m.rowListTestListContent.getChild(m.top.createNextPanelIndex)
    componentToCreate = listItemContent.componentName

    newRightPanel = createObject("RoSGNode", listItemContent.componentName)

    m.top.nextPanel = newRightPanel
end function

function init()
    print "in rowListExamplesListPanel init"
    m.list = m.top.FindNode("examplesList")

    m.top.list = m.list

    m.rowListTestListContent = createObject("RoSGNode", "ContentNode")

    addRowListTestItem("Simple Test", "SimpleRowListPanel")
    addRowListTestItem("Mixed Aspect Test", "MixedAspectRowListPanel")
    addRowListTestItem("Markup On Focus Test", "MarkupOnFocusRowListPanel")

    m.list.content = m.rowListTestListContent

    ' set up the PanelSet title to be "RowList Examples" 
    ' when this panel is on the left
    m.top.overhangTitle = "RowList Examples"
    
    m.top.id           = "GridExamplesListPanel"
    m.top.panelSize    = "narrow"
    m.top.hasNextPanel = true

    ' observe focusedChild to that the LabelList can
    ' take the key event focus when the PanelSet gives
    ' the focus to this Panel
    m.top.observeField("focusedChild", "focusChanged")

    m.top.observeField("createNextPanelIndex", "createRowListExamplePanel")
end function