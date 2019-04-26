## Panel Markup

**Node Class References:** **Panel**, **PanelSet**

The implementation of sliding panels is designed to work automatically as the user focuses or selects items in the current panel. These user actions in the current panel create a new panel that slides in from the right, containing the content targeted to the panel from the item focused or selected by the user in the current panel. The markup required to cause these panel slides is based on the same event observers, key event handling, and server content access we've seen before in this tutorial. But a lot of the panel sliding functionality is built into the sliding panels node classes, and you'll have to learn how to create and add panels in a **PanelSet** node.

The simplest sliding panel node class is the **Panel** node.  This example contains a component file, `panel.xml`, that configures a **Panel** node using simple markup. But the first thing you'll notice is that there is another component file, `panelsetscene.xml`, in the application. That's because the panel node classes are designed to only work as children of a **PanelSet** node. So we create, configure, and append a **PanelSet** node to our example **Scene** node:

**PanelSet Node Creation Example**

```
<component name = "PanelSetExample" extends = "Scene" >
  <script type = "text/brightscript" >
    <![CDATA[
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
      m.panelset = createObject("roSGNode", "PanelSet")
      m.panel = m.panelset.createChild("PanelExample")
      m.top.appendChild(m.panelset)
      m.panel.setFocus(true)
    end sub
    ]]>
  </script>
</component>
```

Configuring the **PanelSet** node in this example consists only of creating a child `PanelExample` **Panel** node as configured in `panel.xml`:

**Panel Node Markup Example**

```
<component name = "PanelExample" extends = "Panel" >
  <script type = "text/brightscript" >
    <![CDATA[
    sub init()
      m.top.panelSize = "medium"
      m.top.focusable = true
      m.top.hasNextPanel = false
    end sub
    ]]>
  </script>
  
  <children>
    <Rectangle
      id = "infoRectangle"
      translation = "[ 0, 40 ]"
      width = "520"
      height = "460"
      color = "0x101010C0" >
 
      <Label
        id = "infoLabel"
        translation = "[ 15, 15 ]"
        text = "Example Panel"
        width = "430"
        height = "490"
        wrap = "true"
        font = "font:MediumBoldSystemFont" />
    </Rectangle>

  </children>

</component>

```

The XML markup in the **<children>** element just creates a black **Rectangle** node with a child **Label** node, as we've done several times before in this tutorial. But in this case we want the **Label** node to fit into the medium-sized panel node configured in the **<script>** element **init()** function:

```
sub init()
  m.top.panelSize = "medium"
  m.top.focusable = true
  m.top.hasNextPanel = false
end sub
```

For this example, the `focusable` and `hasNextPanel` fields are not important, since we are only adding the one panel to the panel set. But you should almost always set the `panelSize` field to one of the default sizes listed in [**PanelSet**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels) when configuring any of the panel node classes. This will ensure that the panels in your panel set slide correctly, based on the size of each panel as it is added to the panel set.

When this single medium panel is added to the panel set, it shows up in the default left position of the panel set:

![img](https://sdkdocs.roku.com/download/attachments/4262988/paneldoc.jpg?version=3&modificationDate=1472838384731&api=v2)

In the other sliding panel examples in this folder, you'll see how to add several panels to a panel set, with each new panel causing a panel slide, and the content meta-data in a focused or selected item in the current panel sent to the new panel.