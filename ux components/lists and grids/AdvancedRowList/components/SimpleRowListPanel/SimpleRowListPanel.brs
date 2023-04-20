function init()
    print "in SimpleRowListPanel init()"
    
    m.rowList = m.top.findNode("theRowList")
    m.rowList.visible = false
    m.rowList.numRows = 3
    m.rowList.itemSize = [ 180*3 + 20*2, 250 ]
    m.top.observeField("focusedChild", "focusChanged")

    m.top.id = "RowListTestScene"
    m.top.visible = true

    m.playCount = 0

    m.readerTask = createObject("roSGNode", "ContentReader")
    m.readerTask.observeField("content", "gotContent")
    m.readerTask.control = "RUN"
end function

function focusChanged()
    if m.top.isInFocusChain()
        if not m.rowList.hasFocus()
            m.rowList.setFocus(true)
        end if
    end if
end function

function gotContent()
    print "gotContent()"
    if m.readerTask.content=invalid
        print "invalid readerTask.content"
    else
        m.top.rowListContent = m.readerTask.content
    end if
end function

function itemFocused()
    print "item "; m.rowList.rowItemFocused[1]; " in row "; m.rowList.rowItemFocused[0]; " was focused"
end function

function itemSelected()
    print "item "; m.rowList.rowItemSelected[1]; " in row "; m.rowList.rowItemSelected[0]; " was selected"
end function

function rowListContentChanged()
    print "rowListContentChanged"

    m.rowList.rowItemSize = [180, 180]

    m.rowList.rowItemSpacing = [20, 20]
    m.rowList.focusXOffset = 0

    m.rowList.showRowLabel   = true
    m.rowList.showRowCounter = true

    m.rowList.rowLabelOffset = [0, 10]

    m.rowList.rowFocusAnimationStyle = "floatingfocus"

    m.rowList.content = m.top.rowListContent

    m.rowList.visible = true

    m.rowList.observeField("rowItemSelected", "itemSelected")
    m.rowList.observeField("rowItemFocused",  "itemFocused")

end function

function onKeyEvent(key As String, press As Boolean) As Boolean
    if press and (key = "play") 
        row0List = m.rowlist.content.getChild(0)
        m.playCount = m.playCount + 1
        row0List.title = row0List.title + str(m.playCount)
    end if
end function