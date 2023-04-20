function buildModel()
    m.model = createObject("RoSGNode","ContentNode")

    for i = 1 to 10 step 1
        rowContent = m.model.createChild("ContentNode")
        rowContent.TITLE = "Row " + i.toStr()
        for j = 1 to 12 step 1
           itemContent = rowContent.createChild("ContentNode")
           itemContent.TITLE = "ITEM"
           if (i < 5) and (i MOD 2 = 0)
               itemUri = "http://devtools.web.roku.com/samples/images/Portrait_" + j.toStr() + ".jpg"
           else
               itemUri = "http://devtools.web.roku.com/samples/images/Landscape_" + j.toStr() + ".jpg"
           end if
           itemContent.HDPOSTERURL = itemUri
           if (i = 3)
               j=13
           end if
        end for
    end for

    print "ROOT CONTENT SIZE "; m.model.getChildCount()
end function 

function focusChanged()
    if m.top.isInFocusChain()
    if not m.rowList.hasFocus()
            m.rowList.setFocus(true)
        end if
    end if
end function

function itemFocused()
    print "item "; m.rowList.rowItemFocused[1]; " in row "; m.rowList.rowItemFocused[0]; " was focused"
end function

function itemSelected()
    print "item "; m.rowList.rowItemSelected[1]; " in row "; m.rowList.rowItemSelected[0]; " was selected"
end function

function init()
    print "in MixedAspectRowListPanel init()"

    buildModel()

    m.rowList = m.top.findNode("theRowList")
    m.rowList.visible = false
    m.rowList.numRows = 3
    m.rowList.itemSize = [ 196*3 + 20*2, 180 ]
    m.rowList.itemSpacing = [ 20, 30]

    m.rowList.rowHeights = [ 180, 250, 180, 250, 180 ]

    m.rowList.rowItemSize = [ [196, 148], [142, 211], [196, 148], [142, 211], [196, 148] ]
    m.rowList.rowItemSpacing = [ [20, 20] ]

    m.rowList.focusXOffset = 0

    m.rowList.showRowLabel   = true
    m.rowList.showRowCounter = true

    m.rowList.rowLabelOffset = [ [0, 10] ]

    m.rowList.rowFocusAnimationStyle = "floatingfocus"

    m.rowList.content = m.model

    m.rowList.visible = true

    m.rowList.observeField("rowItemSelected", "itemSelected")
    m.rowList.observeField("rowItemFocused",  "itemFocused")

    m.top.observeField("focusedChild", "focusChanged")

    m.top.id = "RowListTestScene"
    m.top.visible = true
end function
