' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.top.SetFocus(true)
    
    mslb1 = m.top.findNode("mslb1")
    mslb1.drawingStyles = {
        "RokuTextPurpleBold": {
            "fontUri": "pkg:/fonts/RokuText-Bold.otf"
            "fontSize":36
            "color": "#662d91"
        }
        "RokuTextBoldWhite": {
            "fontUri": "pkg:/fonts/RokuText-Bold.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "RokuTextPurple": {
            "fontUri": "pkg:/fonts/RokuText-Medium.otf"
            "fontSize":36
            "color": "#662d91"
        }
        	"RokuTextPurpleLarge": {
            "fontUri": "pkg:/fonts/RokuText-Medium.otf"
            "fontSize":54
            "color": "#662d91"
        }
         "RokuTextWhite": {
            "fontUri": "pkg:/fonts/RokuText-Medium.otf"
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
        "RokuTextPurpleBold": {
            "fontUri": "pkg:/fonts/RokuText-Bold.otf"
            "fontSize":36
            "color": "#662d91"
        }
        "RokuTextBoldWhite": {
            "fontUri": "pkg:/fonts/RokuText-Bold.otf"
            "fontSize":36
            "color": "#FFFAFA"
        }
        "RokuTextPurple": {
            "fontUri": "pkg:/fonts/RokuText-Medium.otf"
            "fontSize":36
            "color": "#662d91"
        }
        	"RokuTextPurpleLarge": {
            "fontUri": "pkg:/fonts/RokuText-Medium.otf"
            "fontSize":72
            "color": "#662d91"
        }
         "RokuTextWhite": {
            "fontUri": "pkg:/fonts/RokuText-Medium.otf"
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

   mslb1.text = "<RokuTextWhite>Developers can use the new </RokuTextWhite><RokuTextBoldWhite>MultiStyleLabel </RokuTextBoldWhite><RokuTextWhite>node class to create labels with multiple </RokuTextWhite><HandprintedWhite>fonts,</HandprintedWhite><RokuTextPurple>colors, and </RokuTextPurple><RokuTextPurpleLarge>sizes.</RokuTextPurpleLarge>" 
   mslb2.text = "<RokuTextWhite>This enables developers to, for example, bold and/or color </RokuTextWhite><RokuTextPurpleBold>important text </RokuTextPurpleBold><RokuTextWhite>within a label and display emojis </RokuTextWhite><RokuTextPurpleBold>(</RokuTextPurpleBold>" + "<Noto>" + chr(128250) +"</Noto>" + "<RokuTextPurpleBold>)</RokuTextPurpleBold><RokuTextWhite>.</RokuTextWhite>"


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
