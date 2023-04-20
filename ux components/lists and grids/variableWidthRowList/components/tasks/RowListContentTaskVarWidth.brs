Sub init()
    m.top.functionName = "loadContent"
End Sub

Sub loadContent()
    If m.top.content <> invalid Then
        For i = 1 To m.top.content.getChildCount()
            row = CreateObject("rosgnode", "ContentNode")
            row.TITLE = "Row " + i.ToStr()
            ?"Loading ";row.TITLE;"..."
            print "UPDATING CONTENT ROW "; i
            if i=2
                maxIndex = 3
            else if i=4
                maxIndex = 5
            else
                maxIndex = 10
            end if

            For j = 0 To maxIndex-1
                item = row.CreateChild("ContentNode")
                item.TITLE = "Item " + j.ToStr()
                item.addField("FHDItemWidth", "float", false)
                if i=1
                    item.HDPOSTERURL = "pkg:/images/hero.png"
                    item.FHDItemWidth = "1220"
                else if (j mod 3) = 0
                    item.HDPOSTERURL = "pkg:/images/tv.png"
                    item.FHDItemWidth = "351"
                else
                    item.HDPOSTERURL = "pkg:/images/movie.png"
                    item.FHDItemWidth = "156"
                end if
            Next
            m.top.content.replaceChild(row, i-1)
        Next
    End If
End Sub
