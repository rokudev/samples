function init()
    print "in RowListTestScene init()"

    m.top.panelSet.visible = true

    ' create the RowListExamplesListPanel and add it to the PanelSet
    m.examplesListPanel = createObject("RoSGNode", "RowListExamplesListPanel")

    m.top.panelSet.appendChild(m.examplesListPanel)
end function
