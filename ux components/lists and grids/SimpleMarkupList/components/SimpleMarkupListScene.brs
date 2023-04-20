'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

function init()
    m.simpleMarkupList = m.top.findNode("SimpleMarkupList")
    m.simpleMarkupList.content = getMarkupListData()
    m.simpleMarkupGrid = m.top.findNode("SimpleMarkupGrid")
    m.simpleMarkupGrid.content = getMarkupGridData()
	m.simpleMarkupList.SetFocus(true)
	m.simpleMarkupList.ObserveField("itemFocused", "onFocusChanged")
end function

function getMarkupListData() as object
    data = CreateObject("roSGNode", "ContentNode")

    for i = 1 to 10
        dataItem = data.CreateChild("SimpleListItemData")
        dataItem.posterUrl = "http://devtools.web.roku.com/samples/images/Portrait_2.jpg"
        dataItem.labelText = "This is list item " + stri(i)
        dataItem.label2Text = "Subitem " + stri(i)
    end for
    return data
end function

function getMarkupGridData() as object
    data = CreateObject("roSGNode", "ContentNode")

    for i = 1 to 6
        dataItem = data.CreateChild("SimpleGridItemData")
        dataItem.posterUrl = "http://devtools.web.roku.com/samples/images/Portrait_1.jpg"
        dataItem.labelText = "Grid item" + stri(i)
    end for
    return data
end function

function onFocusChanged() as void
    print "Focus on item: " + stri(m.simpleMarkupList.itemFocused)
    print "Focus on item: " + stri(m.simpleMarkupList.itemUnfocused) + " lost"
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if (m.simpleMarkupList.hasFocus() = true) and (key = "right") and (press=true)
	    m.simpleMarkupGrid.setFocus(true)
		m.simpleMarkupList.setFocus(false)
	    handled = true
	else if (m.simpleMarkupGrid.hasFocus() = true) and (key = "left") and (press=true)
	    m.simpleMarkupGrid.setFocus(false)
		m.simpleMarkupList.setFocus(true)
	    handled = true
	endif
    return handled    
end function
