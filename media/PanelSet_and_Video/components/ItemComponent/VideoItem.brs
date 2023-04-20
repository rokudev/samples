' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

'cashe chidren nodes for future operations
function Init()
   m.cover = m.top.findNode("cover")
   
   m.isLandScapeMode = true
   
   m.itemInfo       = m.top.findNode("itemInfo")
   m.title          = m.top.findNode("title")
   m.description    = m.top.findNode("description")
   m.itemDetails    = m.top.findNode("itemDetails")
   m.backgroundPoster = m.top.findNode("backgroundPoster")
   
   m.cover.observeField("loadStatus", "OnCoverLoadStatusChanged")
 end function

'triggers content change and update layout properly
function OnItemContentChanged()
    m.cover.uri = m.top.itemContent.HDPOSTERURL
    m.cover.translation = [5, 5]
    
    item = m.top.itemContent
    
    title = item.title
    if title <> invalid        
        m.title.text = title
    end if
    
    itemInfoArray = []
    
    releaseDate = item.ReleaseDate
    if releaseDate <> invalid and type(releaseDate) = "roString" then
        if releaseDate = "" then releaseDate="no date available"
        itemInfoArray.push(releaseDate)
    end if 
    
    length = item.length
    if length <> invalid then
        formatedLength = GetDurationString(length, True, True, "s", "mins ", "hrs " )
        if formatedLength = "" then formatedLength="no length available"
        itemInfoArray.push(formatedLength)
    end if
    
    m.itemInfo.text = Join(itemInfoArray, " | ")
            
    m.description.text = item.description
    
    
    UpdateLayout()
end function

'set cover image and handle item layout
function OnCoverLoadStatusChanged()
    if m.cover.loadStatus = "ready" then
        if m.cover.bitmapHeight > m.cover.bitmapWidth and m.isLandScapeMode then
            m.isLandScapeMode = false
            SetItemDetailsVisibility()
            UpdateLayout()
        else if m.cover.bitmapHeight < m.cover.bitmapWidth and not m.isLandScapeMode
            m.isLandScapeMode = true
            SetItemDetailsVisibility()
            UpdateLayout()
        end if 
    end if
 end function

'update layout on width change
function OnWidthChanged()
    UpdateLayout()
end function

'update layout on height change
function OnHeightChanged()
    UpdateLayout()
end function

'tune size of all subelements according to item size
function UpdateLayout()
    textOffsetX = 30
    textOffsetY = 10
    
    m.cover.height = m.top.height - textOffsetY
        
    m.title.width = m.top.width - (textOffsetX * 2)
    m.backgroundPoster.height = m.top.height
    
    if m.isLandScapeMode then
        m.cover.width = m.top.width
        
        m.itemDetails.translation = "[" + str(textOffsetX) + "," +  str(m.top.height - textOffsetY) + "]"
        
        m.Description.width = m.top.width - (textOffsetX * 2)
        m.Description.NumLines = 2
        
        m.backgroundPoster.width = m.top.width
        m.backgroundPoster.translation = "[0,0]"
    else
        coverWidth = int(m.top.width * 0.38)
        m.cover.width = coverWidth
        
        m.itemDetails.translation = "[" + str(textOffsetX + coverWidth) + "," +  str(m.top.height - textOffsetY) + "]"
        
        m.Description.width = m.top.width - coverWidth
        m.Description.NumLines = 3     
        
        m.backgroundPoster.width = m.top.width - coverWidth
        m.backgroundPoster.translation = "[" + str(coverWidth) +",0]"
    end if
           
end function

'triggers on focus percent changed
function OnFocusPercentChanged()
    SetItemDetailsVisibility()
end function

'triggers on list5 focus changed
function OnListFocusChanged()       
   SetItemDetailsVisibility()
end function

'handle item visibility according to landscape or portrait mode
function SetItemDetailsVisibility()
    m.itemDetails.visible = true
    m.backgroundPoster.visible = true
end function


Function GetDurationString(totalSeconds = 0 As Integer, skipSeconds = False As Boolean, calcDays = True As Boolean, secondsString = "s" As String, minutesString = "m " As String, hoursString = "h " As String, daysString = "d " As String, secondString = secondsString As String, minuteString = minutesString As String, hourString = hoursString As String, dayString = daysString As String) As String
    remaining = totalSeconds
    days = "0"
    If calcDays Then
        days = Int(remaining / 86400).ToStr()
        remaining = remaining Mod 86400
    End If
    hours = Int(remaining / 3600).ToStr()
    remaining = remaining Mod 3600
    minutes = Int(remaining / 60).ToStr()
    remaining = remaining Mod 60
    seconds = remaining.ToStr()
    
    duration = ""
    If days <> "0" Then
        duration = duration + days
        If days = "1" Then
            duration = duration + dayString
        Else
            duration = duration + daysString
        End If
    End If
    If hours <> "0" Or days <> "0" Then
        duration = duration + hours
        If hours = "1" Then
            duration = duration + hourString
        Else
            duration = duration + hoursString
        End If
    End If
    If minutes <> "0" Or hours <> "0" Or days <> "0" Then
        duration = duration + minutes
        If minutes = "1" Then
            duration = duration + minuteString
        Else
            duration = duration + minutesString
        End If
    End If
    If Not skipSeconds And (seconds <> "0" Or minutes <> "0" Or hours <> "0" Or days <> "0") Then
        duration = duration + seconds
        If seconds = "1" Then
            duration = duration + secondString
        Else
            duration = duration + secondsString
        End If
    End If
    
    Return duration.Trim()
End Function


Function Join(array As Object, delim = "" As String) As String
    result = ""
    If type(array) = "roArray" Then
        For i = 0 To array.Count() - 1
            item = array[i]
            If NOT (LCase(type(item)) = "rostring" or LCase(type(item)) = "string") Then
                item = ""
            End If
            If i > 0 Then
                result = result + delim
            End If
            result = result + item
        Next
    End If
    Return result
End Function
