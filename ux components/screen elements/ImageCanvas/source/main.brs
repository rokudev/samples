Library "v30/bslDefender.brs"

Function Main() as void
    canvas = CreateObject("roImageCanvas")
    port = CreateObject("roMessagePort")
    posArray = GetPositions()
    items = []
    selectedIndex = 0        

    canvas.SetMessagePort(port)
    canvasRect = canvas.GetCanvasRect()
    'onOK(2)
    'stop        
    items.Push({
        url: "pkg:/assets/ball1.png"
        TargetRect: posArray[0]
    })
    items.Push({
        url: "pkg:/assets/ball2.png"
        TargetRect: posArray[1]
    })
    items.Push({
        url: "pkg:/assets/ball3.png"
        TargetRect: posArray[2]
    })
    items.Push({
        url: "pkg:/assets/ball4.png"
        TargetRect: posArray[3]
    })
    items.Push({
        url: "pkg:/assets/ball5.png"
        TargetRect: posArray[4]
    })
    ring = {
        url: "pkg:/assets/ring.png",
        TargetRect: {x: posArray[selectedIndex].x-2, y: posArray[selectedIndex].y-2}
    }            
    canvas.SetLayer(0, { Color: "#00000000", CompositionMode: "Source" })
    canvas.SetLayer(1, items)
    canvas.SetLayer(2, ring)
    canvas.Show()
    
    while true
        event = wait(0, port)
        if (event<> invalid)
            if (event.isRemoteKeyPressed())
                index = event.GetIndex()
                print index
                if (index = 4) OR (index = 2) 'Left or Up
                    selectedIndex = selectedIndex-1
                    if (selectedIndex < 0)
                        selectedIndex = 4
                    endif
                else if (index = 5) OR (index = 3) 'Right or Down
                    selectedIndex = selectedIndex+1
                    if (selectedIndex > 4)
                        selectedIndex = 0
                    endif
                else if (index = 6) 'OK
                    onOK(selectedIndex)
                endif
                ring.TargetRect = {x: posArray[selectedIndex].x-2, y: posArray[selectedIndex].y-2}
                canvas.SetLayer(0, { Color: "#00000000", CompositionMode: "Source" })
                canvas.SetLayer(1, items)
                canvas.SetLayer(2, ring)                
            endif
        endif
    end while
End Function

Function onOK(selectedIndex as integer) as integer
    canvas = CreateObject("roImageCanvas")
    port = CreateObject("roMessagePort")
    canvas.SetMessagePort(port)
    canvasRect = canvas.GetCanvasRect()
    dlgRect = {x: 0, y: 0, w: 600, h: 300}
    'btnRect = {x: 0, y: 0, w: 128, h: 80}    
    txtRect = {}
    txt = "Ball #" + stri(selectedIndex) + " Selected"
    fontRegistry = CreateObject("roFontRegistry")
    font = fontRegistry.GetDefaultFont()
    txtRect.w = font.GetOneLineWidth(txt, canvasRect.w)
    txtRect.h = font.GetOneLineHeight()
    txtRect.x = int((canvasRect.w - txtRect.w) / 2)
    txtRect.y = int((canvasRect.h - txtRect.h) / 2)
    dlgRect.x = int((canvasRect.w - dlgRect.w) / 2)
    dlgRect.y = int((canvasRect.h - dlgRect.h) / 2)
    'btnRect.x = int((canvasRect.w - btnRect.w) / 2)
    'btnRect.y = int((canvasRect.h +dlgRect.h) / 2) - btnRect.h - 15
    
    items = []
    items.Push({
        url: "pkg:/assets/dialog.png"
        TargetRect: dlgRect
    })
    items.Push({
        Text: txt
        TextAttrs: { font: "large", color: "#a0a0a0" }
        TargetRect: txtRect
    })
    'button = {
    '    url: "pkg:/assets/button.png"
    '    TargetRect: btnRect
    '}
    canvas.SetLayer(0, { Color: "#a0000000", CompositionMode: "Source_Over" })
    canvas.SetLayer(1, items)
    'canvas.SetLayer(2, button)
    canvas.Show()
    
    while true
        event = wait(0, port)
        if (event <> invalid)
            if (event.isRemoteKeyPressed())
                id = event.GetIndex()
                if (id = 6) OR (id = 0) 'OK or Back
                    canvas.Close()
                    return 1
                else if (id = 3)
                    button.url = "pkg:/assets/button_pressed.png"
                    canvas.SetLayer(0, { Color: "#a0000000", CompositionMode: "Source_Over" })
                    canvas.SetLayer(0, items)
                    canvas.SetLayer(1, button)
                else if (id = 2)
                    button.url = "pkg:/assets/button.png"
                    canvas.SetLayer(0, { Color: "#a0000000", CompositionMode: "Source_Over" })
                    canvas.SetLayer(0, items)
                    canvas.SetLayer(1, button)                
                endif
            endif            
        endif
    end while
    return 0
End Function

Function GetPositions() as object
    posArray = []
    posArray.Push({x: 74, y: 512})
    posArray.Push({x: 269, y: 241})
    posArray.Push({x: 500, y: 300})
    posArray.Push({x: 847, y: 432})    
    posArray.Push({x: 1024, y: 84})
    return posArray
End Function
