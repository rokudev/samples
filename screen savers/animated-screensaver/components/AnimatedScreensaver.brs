    Function OnAnimChanged() as Void 'Function to start all the animations inside screensaver
        m.Poster1UpDownAnimation.control = "start"
        m.Poster2LeftRightAnimation.control = "start"
        m.Poster3UpDownAnimation.control = "start"
        m.Poster4DiagonalAnimation.control = "start"
        m.Poster5UpDownAnimation.control = "start"
        m.Poster6DiagonalAnimation.control = "start"
        m.Poster7UpDownAnimation = "start"
    end Function    

    Function init() 'Function is run when XML is parsed
        m.top.backgroundColor = "0x000000FF" 'Set background color to black
        m.top.backgroundURI = "" 'Set background URI (image) to empty so background color displays
        
        m.TopLabel = m.top.findNode("TopLabel") 'Sets pointer to TopLabel node to adjust fields
        m.TopLabel.font.size=160
        m.TopLabel.color="0x72D7EEFF"
        
        m.BottomLabel = m.top.findNode("BottomLabel") ' Sets pointer to BottomLabel node to adjust fields
        m.BottomLabel.font.size=60
        m.BottomLabel.color="0x72D7EEFF"
        
        
        m.Poster1UpDownAnimation = m.top.findNode("Poster1UpDownAnimation") 'Sets pointers to Animation nodes. This is so we can access their animation controls
        m.Poster2LeftRightAnimation = m.top.findNode("Poster2LeftRightAnimation")
        m.Poster3UpDownAnimation = m.top.findNode("Poster3UpDownAnimation")
        m.Poster4DiagonalAnimation = m.top.findNode("Poster4DiagonalAnimation")
        m.Poster5UpDownAnimation = m.top.findNode("Poster5UpDownAnimation")
        m.Poster6DiagonalAnimation = m.top.findNode("Poster6DiagonalAnimation")
        m.Poster7UpDownAnimation = m.top.findNOde("Poster7UpDownAnimation")
        
        
        OnAnimChanged() 'Calls function (located at the top) to start all animations inside the screensaver
    end Function