Function changeBackground() as Void 'Function that changes the background image to the next image in the m.pictures array
    if (m.count=4)
        m.count = -1
    end if
    m.count += 1
    m.BackgroundArt.uri = m.pictures[m.count]
End Function

Function FadeAnimation() as Void 'Function that starts the FadeAnimation transition animation
    m.FadeAnimation.control = "start"
End Function

Function init()
    m.pictures = [] ' For loop to load images into m.pictures array
    for i = 1 to 5
        m.pictures.push("pkg:/images/" + i.toStr() +".jpg") 'Loads images 1-5 in image folder into m.pictures array
    end for 
    m.count = 0

    m.FadeAnimation = m.top.findNode("FadeAnimation") 'Sets pointer to FadeAnimation node
    m.BackgroundArt = m.top.findNode("BackgroundArt") 'Sets pointer to BackgroundArt node
    m.BackgroundArt.uri = m.pictures[0] 'Sets Background art to first picture
   
    m.global.observeField("PicSwap", "changeBackground") 'field Observer that calls changeBackground() function everytime the value of PicSwap is changed
    m.global.observeField("MyField", "FadeAnimation")  'field Observer that calls FadeAnimation() function everytime the value of MyField is changed
End Function
    
   