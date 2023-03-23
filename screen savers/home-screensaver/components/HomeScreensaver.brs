
    Function Change() as Void
        if m.count = 1
            m.count = -1 'Set to -1 because increment will change it to 0
        end if
        m.count+=1
        if m.count = 0
            m.PosterTwoIn.control = "start" 'Start Animation to Fade PosterTwo in
            m.PosterTwo.uri = m.global.channels[rnd(m.global.channels.count())-1] 'Sets uri of PosterTwo to random uri in Channel Artwork array
        else if m.count = 1
            m.PosterOneIn.control = "start" 'Start Animation to Fade PosterOne in
            m.PosterOne.uri = m.global.channels[rnd(m.global.channels.count()-1)] 'Sets uri of PosterOne to random uri in Channel Artwork array
        end if
    end Function
    
    Function init()
        m.count = -1     'Will Display 0 index of channel artwork because of increment to m.count in Change()
        m.top.backgroundUri = "pkg:/images/Background.jpg" 'Background URI of screensaver
        
        m.PosterOneIn = m.top.findNode("PosterOneIn") 'Sets pointer to each poster change animation
        m.PosterTwoIn = m.top.findNode("PosterTwoIn")
        
        m.PosterOne = m.top.findNode("PosterOne") 'Sets pointers to each poster node
        m.PosterTwo = m.top.findNode("PosterTwo")
        
        m.BounceAnimation = m.top.findNode("BounceAnimation") 'Sets pointer to BounceAnimation
        m.BounceAnimation.control = "start" 'Start BounceAnimation
        
        Change()
        m.global.observeField("MyField", "Change") '(Observer for MyField) Everytime the value of MyField Changes, the Change() function is called
    end Function