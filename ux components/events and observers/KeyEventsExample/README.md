# Key Events Markup

**SceneGraph References:** [****](https://developer.roku.com/docs/references/api-index/scenegraph/xml-elements/script.md), **onKeyEvent()**

Pressing the keys on the Roku remote control generate specific events for each key, as well as a general event when any key is pressed. This gives you full control to initiate actions in your SceneGraph application in response to remote control key presses, many times in the **<script>** element of a SceneGraph XML component file (see **<script>**). The SceneGraph API includes a special function, **onKeyEvent()**, that can be used in the **<script>** element to control the component defined in the XML file (see [**onKeyEvent()**](https://developer.roku.com/docs/references/api-index/scenegraph/component-functions/onkeyevent.md)).

In this example, we use the **OK** key on the remote control to show and hide a **Label** node.

**Key Events Example**

```
<component name = "KeyEventsExample" extends = "Scene" >
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
 
      m.label = m.top.findNode("exampleLabel")
 
      examplerect = m.label.boundingRect()
      centerx = (1280 - examplerect.width) / 2
      centery = (720 - examplerect.height) / 2
      m.label.translation = [ centerx, centery ]
 
      m.top.setFocus(true)
    end sub
 
    function onKeyEvent(key as String, press as Boolean) as Boolean
      if press then
        if (key = "OK") then
          if (m.label.visible = true)
            m.label.visible = false
          else
            m.label.visible = true
          endif
 
          return true
        end if
      end if
 
      return false
    end function
 
    ]]>
 
  </script>
 
  <children>
 
    <Label
      id = "exampleLabel"
      width = "600"
      height = "60"
      text = "Press OK to Hide/Show"
      horizAlign = "center"
      vertAlign = "center"
      visible = "true" />
 
  </children>
 
</component>
```

The **Label** node is defined like the example in [**Renderable Node Markup**](https://sdkdocs.roku.com/display/sdkdoc/Renderable+Node+Markup). But we've defined the `visible` field that is normally set to true by default:

```
visible = "true"
```

We're just doing this to absolutely ensure the starting condition of the **Label** node, which is visible, because we'll be setting this field alternating between true and false depending on the user pressing the **OK** remote control key. This is all done in the **onKeyEvent()** function, after declaring the `m.label` object in the **init()** function using the **findNode()** method:

```
function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then
    if (key = "OK") then 
      if (m.label.visible = true)
        m.label.visible = false
      else
        m.label.visible = true
      endif

      return true
    end if
  end if

  return false
end function
```

The logic is simple. If the **OK** key is pressed, and if the `m.label` object is visible based on the setting of the `visible` field, the label is made invisible by setting the field to false. If the `m.label` object `visible` field value is false when the **OK**key is pressed, the field value is set to true, making the label visible.

There's a few important things to note in this event handler function definition. First, the function returns either true or false to the firmware, and by default we want to make sure the return value is false (the remote key press event has not been handled), to avoid any possibility that the firmware will prevent further action of the application, or the user to control the application. So we explicitly set the return value to be false at the bottom of the function, after the key press event has not handled by any of the conditions in the function:

```
return false
```

We only want to return true when we are sure we have handled the *specific* key press event correctly. This all typically takes place in an `if press then` conditional statement block as above, which handles the general key press event. We want to add a conditional block to detect and handle the *specific* key event, handle the event, then return true in that block to prevent any possible further processing of that key event. (Remember from the [**SceneGraph XML Guide**](https://developer.roku.com/docs/references/scenegraph/core-concepts.md) that any remote control key events that are not handled by any node in the SceneGraph are automatically are handled by default at the top of the SceneGraph, or by the firmware, by default.)

The main event handling is done in the conditional code block that detects the **OK** key press. On each **OK** key press, the code checks the visibility state of the **Label** node, and toggles visibility according to the current state:

if (key = "OK") then 
  if (m.label.visible = true)
    m.label.visible = false
  else
    m.label.visible = true
  endif

  return true
end if
```

If you haven't done this already, download and side-load `KeyEventsExample.zip`, and press the **OK** key repeatedly.

![img](https://sdkdocs.roku.com/download/attachments/1606023/keyeventsdoc.jpg?version=2&modificationDate=1472836435396&api=v2)