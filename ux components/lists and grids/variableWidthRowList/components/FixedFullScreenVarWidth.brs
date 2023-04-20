Function init()
    print "starting init()"
    m.top.setFocus(true)

    m.RowList = m.top.findNode("rowList")

    content = CreateObject("roSGNode", "ContentNode")
    For i = 1 To 5
        rowContent = content.CreateChild("ContentNode")
        rowContent.TITLE = "Row " + i.ToStr()
        content.AppendChild(rowContent)
    Next
    m.RowList.observeField("content", "rowListContentChanged")
    m.RowList.content = content

    m.LoadTask = CreateObject("roSGNode", "RowListContentTaskVarWidth")
    m.LoadTask.content = content
    m.LoadTask.control = "RUN"
    print "finished init()"
End Function

function rowListContentChanged()
    print "rowListContentChanged!!!"
    for i=0 To 4
        contentChild = m.RowList.content.getChild(i)
        print "+++ child " i; " is "; contentChild
        print "--- child "; i; " has "; contentChild.getChildCount(); " children"
    end for
end function
