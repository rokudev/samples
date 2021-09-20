' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.top.SetFocus(true)
    
    mslb1 = m.top.findNode("mslb1")
    mslb1.drawingStyles = {
        "GothamPurpleBold": {
            "fontUri": "pkg:/fonts/Gotham-Bold.otf"
            "fontSize":36
            "color": "#662d91"
        }
        "GothamBoldWhite": {
            "fontUri": "pkg:/fonts/Gotham-Bold.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "GothamPurple": {
            "fontUri": "pkg:/fonts/Gotham-Medium.otf"
            "fontSize":36
            "color": "#662d91"
        }
        	"GothamPurpleLarge": {
            "fontUri": "pkg:/fonts/Gotham-Medium.otf"
            "fontSize":54
            "color": "#662d91"
        }
         "GothamWhite": {
            "fontUri": "pkg:/fonts/Gotham-Medium.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "HandprintedWhite": {
            "fontUri": "pkg:/fonts/vSHandprinted.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "HandprintedGreen": {
            "fontUri": "pkg:/fonts/vSHandprinted.otf"
            "fontSize": 36 
            "color": "#00FF00FF"
        }
        "Noto": {
            "fontUri": "pkg:/fonts/OpenSansEmoji.ttf"
            "fontSize": 36
            "color": "#662d91FF"
        }
        "default": {
            "fontSize": 12
            "fontUri": "font:LargeSystemFont"
            "color": "#DDDDDDFF"
        }              
    }
    
    mslb2 = m.top.findNode("mslb2")
    mslb2.drawingStyles = {
        "GothamPurpleBold": {
            "fontUri": "pkg:/fonts/Gotham-Bold.otf"
            "fontSize":36
            "color": "#662d91"
        }
        "GothamBoldWhite": {
            "fontUri": "pkg:/fonts/Gotham-Bold.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "GothamPurple": {
            "fontUri": "pkg:/fonts/Gotham-Medium.otf"
            "fontSize":36
            "color": "#662d91"
        }
        	"GothamPurpleLarge": {
            "fontUri": "pkg:/fonts/Gotham-Medium.otf"
            "fontSize":72
            "color": "#662d91"
        }
         "GothamWhite": {
            "fontUri": "pkg:/fonts/Gotham-Medium.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "HandprintedWhite": {
            "fontUri": "pkg:/fonts/vSHandprinted.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "HandprintedGreen": {
            "fontUri": "pkg:/fonts/vSHandprinted.otf"
            "fontSize": 36 
            "color": "#00FF00FF"
        }
        "Noto": {
            "fontUri": "pkg:/fonts/OpenSansEmoji.ttf"
            "fontSize": 36
            "color": "#662d91FF"
        }
        "default": {
            "fontSize": 36
            "fontUri": "font:LargeSystemFont"
            "color": "#DDDDDDFF"
        }              
    }    

   mslb1.text = "<GothamWhite>Developers can use the new </GothamWhite><GothamBoldWhite>MultiStyleLabel </GothamBoldWhite><GothamWhite>node class to create labels with multiple </GothamWhite><HandprintedWhite>fonts,</HandprintedWhite><GothamPurple>colors, and </GothamPurple><GothamPurpleLarge>sizes.</GothamPurpleLarge>" 
   mslb2.text = "<GothamWhite>This enables developers to, for example, bold and/or color </GothamWhite><GothamPurpleBold>important text </GothamPurpleBold><GothamWhite>within a label and display emojis </GothamWhite><GothamPurpleBold>(</GothamPurpleBold>" + "<Noto>" + chr(128250) +"</Noto>" + "<GothamPurpleBold>)</GothamPurpleBold><GothamWhite>.</GothamWhite>"


End sub

function doTest() as void
    mslb1 = m.top.findNode("mslb1")
    mslb2 = m.top.findNode("mslb2")
    
    if mslb1.isTextEllipsized
        print "mslb1.isTextEllipsized = TRUE"
    else
        print "mslb1.isTextEllipsized = FALSE"
    endif
    
    if mslb2.isTextEllipsized
        print "mslb2.isTextEllipsized = TRUE"
    else
        print "mslb2.isTextEllipsized = FALSE"        
    endif
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press = true
        if key = "OK"
            doTest()
        endif
    endif
    return result 
end function
