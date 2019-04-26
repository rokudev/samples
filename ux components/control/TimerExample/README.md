## Timer Markup

**Node Class Reference: Timer**

The **Timer** node class is a simple way to add a time delay to selected operations. Just add a **Timer** node, observe the `fire` field, and write a callback function for the operation you want to be delayed, or in some way timed:

**Timer Example**

```
<component name = "TimerExample" extends = "Scene" >
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
 
      m.defaulttext = "Wait for it, wait for it..."
      m.alternatetext = "Timer fired!!!"
      m.label = m.top.FindNode("exampleLabel")
      m.label.text = m.defaulttext
      m.textchange = false
 
      examplerect = m.label.boundingRect()
      centerx = (1280 - examplerect.width) / 2
      centery = (720 - examplerect.height) / 2
      m.label.translation = [ centerx, centery ]
 
      timer = m.top.findNode("exampleTimer")
      timer.ObserveField("fire", "changetext")
      timer.control = "start"
 
      m.top.setFocus(true)
    end sub
 
    sub changetext()
      if (m.textchange = false) then
        m.label.text = m.alternatetext
        m.textchange = true
      else
        m.label.text = m.defaulttext
        m.textchange = false
      end if
    end sub
 
    ]]>
 
  </script>
 
  <children>
 
    <Label
      id = "exampleLabel"
      width = "480"
      height = "60"
      horizAlign = "center"
      vertAlign = "center" />
 
    <Timer
      id = "exampleTimer"
      repeat = "true"
      duration = "2" />
 
  </children>
 
</component>
```

The XML component markup above will change the text on the screen every two seconds, because the `changtext()` callback function is triggered the each time the **Timer** node `fire` field changes.

![img](https://sdkdocs.roku.com/download/attachments/4262849/timerdoc.jpg?version=3&modificationDate=1472836709786&api=v2)