# Observed Fields Markup

**Node Class Reference:** [**Timer**](https://developer.roku.com/docs/references/api-index/scenegraph/control-nodes/timer.md)

All SceneGraph objects include an **observeField()** function that can call an event handler function in response to a change in a field in the object (see **ifSGNodeField**). (As an alternate, the **interface** element also can also be used for the same purpose, as described in [****](https://developer.roku.com/docs/references/api-index/scenegraph/xml-elements/interface.md).) `EventObserverExample.zip` uses a **Timer** node to trigger a change in the text in a **Label** node we defined previously in [**Renderable Node Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes) (to see a tutorial example of the **Timer** node, you can skip ahead a little to [**Timer Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/control)).

But we're going to make this more complicated by combining an animation node that also operates on the **Label** node with the **Timer** node. We're going to try to synchronize the **Timer** node with an animation node that operates on the `translation` field of the **Label** node, to change the text as well as move it around the display screen.

**Event Observer Example**

```
<component name = "EventObserverExample" extends = "Scene" >
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
 
      example = m.top.findNode("textRectangle")
 
      examplerect = example.boundingRect()
      centerx = (1280 - examplerect.width) / 2
      centery = (720 - examplerect.height) / 2
      example.translation = [ centerx, centery ]
 
      m.movinglabel = m.top.findNode("movingLabel")
      scrollback = m.top.findNode("scrollbackAnimation")
      texttimer = m.top.findNode("textTimer")
      m.defaulttext = "All The Best Videos!"
      m.alternatetext = "All The Time!!!"
      m.textchange = false
      texttimer.observeField("fire", "changetext")
      scrollback.control = "start"
      texttimer.control = "start"
 
      m.top.setFocus(true)
    end sub
 
    sub changetext()
      if (m.textchange = false) then
        m.movinglabel.text = m.alternatetext
        m.textchange = true
      else
        m.movinglabel.text = m.defaulttext
        m.textchange = false
      end if
    end sub
 
    ]]>
 
  </script>
 
  <children>
 
    <Rectangle
      id = "textRectangle"
      width = "640"
      height = "60"
      color = "0x10101000" >
 
      <Label
        id = "movingLabel"
        width = "280"
        height = "60"
        text = "All The Best Videos!"
        horizAlign = "center"
        vertAlign = "center" />
 
    </Rectangle>
 
    <Animation
      id = "scrollbackAnimation"
      duration = "10"
      repeat = "true"
      easeFunction = "linear" >
 
      <Vector2DFieldInterpolator
        key = "[ 0.0, 0.5, 1.0 ]"
        keyValue = "[ [0.0, 0.0], [360.0, 0.0], [0.0, 0.0] ]"
        fieldToInterp = "movingLabel.translation" />
 
    </Animation>
 
    <Timer
      id = "textTimer"
      repeat = "true"
      duration = "5" />
 
  </children>
 
</component>
```

Note that we are setting up an animation that is very similar to the one in [**Vector2DFieldInterpolator Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/animation). But instead of moving a rectangle around the display screen, we are moving a **Label** node. We make the animated **Label** node a child node of an invisible parent **Rectangle** node that sets the boundary of the furthermost limits of the animation:

```
<Rectangle 
  id = "textRectangle"
  width = "640" 
  height = "60" 
  color = "0x10101000" >

  <Label 
    id = "movingLabel" 
    width = "280" 
    height = "60" 
    text = "All The Best Videos!" 
    horizAlign = "center" 
    vertAlign = "center" />

</Rectangle>
```

Then we define the **Animation** node to move the **Label** node around, which uses the same **Vector2DFieldInterpolator** node we used before to change the `translation` field values of a **Rectangle** node:

```
<Animation 
  id = "scrollbackAnimation" 
  duration = "10" 
  repeat = "true" 
  easeFunction = "linear" >

  <Vector2DFieldInterpolator 
    key = "[ 0.0, 0.5, 1.0 ]" 
    keyValue = "[ [0.0, 0.0], [360.0, 0.0], [0.0, 0.0] ]" 
    fieldToInterp = "movingLabel.translation" />

</Animation>
```

But the important difference in this example is that we add a **Timer** node, which we intend to change the text of the **Label** node half-way through the animation. We give it an ID, which for this particular use, is required, because we must be able to identify the node in BrightScript code in the **<script>** element:

```
id = "textTimer"
```

We also define the `repeat` and `duration` fields in the same way as an **Animation** node, but note that we set the `duration` field value to 5, half the value of the same field in the **Animation** node:

```
repeat = "true" 
duration = "5"
```

This is how we can change  the text of the **Label** node half-way through the animation. All we need is to add the following BrightScript code to the **init()** function:

```
m.movinglabel = m.top.findNode("movingLabel")
scrollback = m.top.findNode("scrollbackAnimation")
texttimer = m.top.findNode("textTimer")
m.defaulttext = "All The Best Videos!"
m.alternatetext = "All The Time!!!"
m.textchange = false
texttimer.observeField("fire", "changetext")
scrollback.control = "start"
texttimer.control = "start"
```

Most of the code is setting up variables and objects we will need to actually change the text itself. The most important line of code for this example is the use of the **observeField()** method to set an observer on the `fire` field of the **Timer**node:

texttimer.observeField("fire", "changetext")

As described in **Timer Markup**, the **Timer** node `fire` field will be set after the number of seconds specified by the `duration` field value. By setting the observer on this field, we can trigger an event handling callback function `changetext()`when the field changes:

```
sub changetext()
  if (m.textchange = false) then
    m.movinglabel.text = m.alternatetext
    m.textchange = true
  else
    m.movinglabel.text = m.defaulttext
    m.textchange = false
  end if
end sub
```

This is the function that actually changes the **Label** node text every five seconds, as the repeating animation reaches its furthermost limits. The text alternates between **All The Best Videos!** and **All The Time!!!** every five seconds:

![img](https://sdkdocs.roku.com/download/attachments/1606023/eventobserverdoc14pt.jpg?version=2&modificationDate=1472829441110&api=v2)

Again, as in [**Vector2DFieldInterpolator Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/animation), you can watch the animation scroll back and forth, and the text change, over and over and over again...