Function init ()
    m.pictures = [] ' For loop to load images into m.pictures array
    for i = 1 to 5
        m.pictures.push("pkg:/images/" + i.toStr() +".jpg")
    end for 
    m.count = 0 
    
    m.QuadrantTransition = m.top.findNode("QuadrantTransition") 'Sets pointer to Animation node for the Quadrant Transition
    
    m.Background = m.top.findNode("Background") 'Sets pointer to Poster node
    m.Background.uri = m.pictures[0]'Sets uri of Poster node to firt picture in m.pictures array
    
    m.global.observeField("MyField", "Transition") 'Sets observer to MyField. Every time MyField value changes the Transition() function is called
    m.global.observeField("PicSwap", "changeBackground") ' Sets observer to PicSwap. Every time PicSwap value changes the changeBackground() function is called
end Function

Function changeBackground() as Void 'Changes the uri of the poster to the next picture in the m.pictures array
    if m.count = 4
        m.count = -1
    end if
    m.count+=1
    m.Background.uri = m.pictures[m.count]
End Function

Function Transition() as Void 'Starts the animation to for the QuadrantTransition
    m.QuadrantTransition.control = "start"
End Function