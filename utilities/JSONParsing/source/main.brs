Function Main() as void

    m.buttons = [
        {Label: "Parse JSON", ID: 1}
        {Label: "Parse XML", ID: 2}
    ]
    
    port = CreateObject("roMessagePort")
    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort( port )

    InitTheme()
    
    screen.SetTitle("Simple JSON Parsing Sample")
    screen.AddHeaderText("Click the Parse JSON Button to read the JSON File")
    screen.AddParagraph("(We've Included XML Parsing for Comparison Too)")
    for each button in m.buttons
        screen.AddButton(button.ID, button.Label)
    end for
    screen.show()
    
    while (true)
        msg = wait(0, port)
        if type( msg ) = "roParagraphScreenEvent"
            if (msg.isButtonPressed())
                HandleButtonPress(msg.GetIndex())
            end if
        end if
    end while
End Function

Function InitTheme() as void
    app = CreateObject("roAppManager")

    theme = {
        OverhangOffsetSD_X:         "18"
        OverhangOffsetSD_Y:         "0"
        OverhangSliceSD:            "pkg:/images/Overhang_BackgroundSlice_SD.png"
        OverhangLogoSD:             "pkg:/images/json.png"
        OverhangOffsetHD_X:         "18"
        OverhangOffsetHD_Y:         "0"
        OverhangSliceHD:            "pkg:/images/Overhang_BackgroundSlice_HD.png"
        OverhangLogoHD:             "pkg:/images/json.png"
    }
    app.SetTheme(theme)

End Function

Function HandleButtonPress(id as integer) as void
    if (id = m.buttons[0].ID)
        LoadJSONFile()
    else if (id = m.buttons[1].ID)
        LoadXMLFile()
    end if
End Function

Function LoadJSONFile() as void
    jsonAsString = ReadAsciiFile("pkg:/json/sample1.json")
    m.json = ParseJSON(jsonAsString)
    ShowPosterScreen(m.json.Videos, true)
End Function

Function LoadXMLFile() as void
    xmlParser = CreateObject("roXMLElement")
    xmlParser.Parse(ReadAsciiFile("pkg:/xml/sample1.xml"))
    ShowPosterScreen(xmlParser.Video, false)
End Function

Function ShowPosterScreen(videos as object, fromJson as boolean) as integer
    posterScreen = CreateObject("roPosterScreen")
    port = CreateObject("roMessagePort")
    
    
    posterScreen.SetMessagePort(port)
    if (fromJson)
        posterScreen.SetBreadcrumbText("JSON Parsing Result", "")
    else
        posterScreen.SetBreadcrumbText("XML Parsing Result", "")
    end if
    contentList = CreateObject("roArray", 2, true)
    for each video in videos
        poster = CreateObject("roAssociativeArray")
        if (fromJson)
            poster.ShortDescriptionLine1 = video.Title
            poster.SDPosterURL = video.Image
            poster.HDPosterURL = video.Image
        else
            poster.ShortDescriptionLine1 = video.Title.GetText()
            poster.SDPosterURL = video.Image.GetText()
            poster.HDPosterURL = video.Image.GetText()
        end if
        contentList.push( poster )
    end for
    posterScreen.SetContentList( contentList )
    posterScreen.SetFocusedListItem(2)
    posterScreen.show()

    while (true)
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent"
            if (msg.isListItemSelected())
                PlayVideo(videos[msg.GetIndex()], fromJson)
            else if (msg.isScreenClosed())
                return -1
            end if
        endif
    end while

End Function

Function PlayVideo(video as object, json as boolean) as integer
    videoScreen = CreateObject("roVideoScreen")
    port = CreateObject("roMessagePort")
    videoScreen.SetMessagePort( port )
    if (json)
        metaData = {
            ContentType: "episode",
            Title: video.Title,
            Description: video.Title,
            Stream: {
                Url: video.Url
            }
        }
    else
        metaData = {
            ContentType: "episode",
            Title: video.Title.GetText(),
            Description: video.Title.GetText(),
            Stream: {
                Url: video.Url.GetText()
            }
        }    
    end if
    videoScreen.SetContent( metaData )
    videoScreen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roVideoScreenEvent"
            if (msg.isScreenClosed())
                return -1
            end if
        endif
    end while
    
    
End Function
