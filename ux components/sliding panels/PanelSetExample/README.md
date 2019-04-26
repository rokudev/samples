## PanelSet Markup

**Node Class References:** **PanelSet**, **Panel**, **ListPanel**, **GridPanel**

The basic idea for developing a dynamic sliding panel user interface is to control the adding of panels to a **PanelSet** node. `PanelSetExample.zip` shows how to dynamically manage the three panel node classes with different sizes, creating or targeting each new panel node with **Content Meta-Data** from the current panel.

The way to accomplish this is by controlling the addition of child panel nodes to the **PanelSet** node. For this example, we will use the same three basic panel nodes we used in [**Panel Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels), [**ListPanel Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels), and [**GridPanel Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels): a medium-sized **Panel** node, a medium-sized **ListPanel** node, and a full-sized **GridPanel** node. We'll modify them slightly, but first, let's look at the `panelsetscene.xml` component file to see how to dynamically add new panels to a **PanelSet**node:

**Dynamic PanelSet Node Example**

```
<component name = "PanelSetExample" extends = "Scene" >
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
 
      m.panelset = createObject("roSGNode", "PanelSet")
      m.top.appendChild(m.panelset)
 
      m.readContentTask = createObject("roSGNode", "ContentReader")
      m.readContentTask.observeField("content", "setpanels")
      m.readContentTask.contenturi = "http://www.sdktestinglab.com/Tutorial/content/panelsetcontent.xml"
      m.readContentTask.control = "RUN"
    end sub
 
    sub setpanels()
      m.listpanel = m.panelset.createChild("ListPanelExample")
      m.listpanel.list.content = m.readContentTask.content
 
 
      m.panel = m.panelset.createChild("PanelExample")
 
 
      m.listpanel.list.observeField("itemFocused", "showpanelinfo")
      m.panel.observeField("focusedChild", "slidepanels")
 
 
      m.listpanel.setFocus(true)
    end sub
 
    sub showpanelinfo()
      panelcontent = m.listpanel.list.content.getChild(m.listpanel.list.itemFocused)
 
      m.panel.description = panelcontent.description
 
      m.gridpanel = createObject("roSGNode", "GridPanelExample")
 
      m.gridpanel.gridcontenturi = panelcontent.url
    end sub
 
    sub slidepanels()
      if not m.panelSet.isGoingBack
        m.panelset.appendChild(m.gridpanel)
        m.gridpanel.setFocus(true)
      else
        m.listpanel.setFocus(true)
      end if
    end sub
 
    ]]>
 
  </script>
 
</component>
```

As in all the previous panel node examples, we create a **PanelSet** node object. But in this example, we use a content reader **Task** node to get the content meta-data we need to add two child panel nodes, the medium-sized **ListPanel** node and the medium-sized **Panel** node. When the **ContentNode** node for this content meta-data is ready, the change in the **Task** node `content` field triggers the `setpanels()` callback function that populates the first two panels:

```
sub setpanels()
  m.listpanel = m.panelset.createChild("ListPanelExample")
  m.listpanel.list.content = m.readContentTask.content
  m.panel = m.panelset.createChild("PanelExample")
  m.listpanel.list.observeField("itemFocused", "showpanelinfo")
  m.panel.observeField("focusedChild", "slidepanels")
  m.listpanel.setFocus(true)
end sub
```

At this point, since we have only added two medium-sized panel nodes, both are visible in the panel set, with the first child panel node added in the default left position, and the second child panel node to the right:

![img](https://sdkdocs.roku.com/download/attachments/4262988/panelsetdoc.jpg?version=4&modificationDate=1472838551251&api=v2)

The **ListPanel** node is used for user selection of an item in the list, and the **Panel** node is used to supply additional information to the user about the currently-focused item. The full-sized **GridPanel** node has yet to be created, so we'll handle that with a callback function triggered by an `itemFocused` field change in the **ListPanel** node list:

```
sub setpanels()
  ...
  m.listpanel.list.observeField("itemFocused", "showpanelinfo")
  ...
end sub

sub showpanelinfo()
  panelcontent = m.listpanel.list.content.getChild(m.listpanel.list.itemFocused)
  m.panel.description = panelcontent.description
  m.gridpanel = createObject("roSGNode", "GridPanelExample")
  m.gridpanel.gridcontenturi = listpanelcontent.url
end sub
```

The `showpanelinfo()` callback function does a few things. First, it gets the item **Content Meta-Data** for the focused item in the list, using the **getChild()** method on the **ListPanel** node list `content` field, with the `itemFocused` field value as an index into the **ContentNode** child node. Then the `description` field of the **Panel** node is set to the value of the `description` attribute field of the item **Content Meta-Data** (if you guessed that we added an **<interface>** element with a `description` field to the **Panel** node, you're right). And then the **GridPanel** node object is created, and the `gridcontenturi` field is set to the `url` attribute field of the item **Content Meta-Data**.

At this point, the full-sized **GridPanel** node object exists, and is set with the necessary **Content Meta-Data** to be fully configured. But since it has not been added to the **PanelSet** node, it is not visible, and doesn't cause the other panels to slide offscreen to the left. We handle that, and sliding the panels back to the original position, with another callback function triggered by focus being moved to the **Panel** node by a user remote key press action:

```
sub setpanels()
  ...
  m.panel.observeField("focusedChild", "slidepanels")
  ...

end sub
...
sub slidepanels()
  if not m.panelSet.isGoingBack
    m.panelset.appendChild(m.gridpanel)
    m.gridpanel.setFocus(true)
  else
    m.listpanel.setFocus(true)
  end if
end sub
```

The **PanelSet** node responds automatically to certain remote key presses. If the user presses the **OK** or **Right** key in a focused panel list or grid, focus is automatically sent to the next panel node to the right. If the user presses the **Back** or **Left**key, focus is automatically sent to the previous panel node to the left. We rely on this action in the `slidepanels()` callback function, by observing the `focusedChild` field of the **Panel** node. The **Panel** node is only used to supply additional information about the item focused in the **ListPanel** node list, so we actually don't want to focus on the **Panel** node at all. Instead, we use the focused state of the panel to determine whether to add the full-sized **GridPanel** node object, causing the panels to slide to the left, or set focus back on the **ListPanel** node, causing the panels to slide back to the right. We do this by checking the Boolean value of the **PanelSet** node `isGoingBack` field, which is set by the user remote key press. A **OK** or **Right** remote key press sets the field to false, a **Back** or **Left** remote key press sets the field to true. So if the field is not set to true, we append the full-sized **GridPanel** node object to the **PanelSet** node, causing the panels to slide to the left showing the grid panel. If the field is true, we set focus back on the **ListPanel** node, and the panels slide back to their original position.

![img](https://sdkdocs.roku.com/download/attachments/4262988/gridpaneldoc.jpg?version=6&modificationDate=1472838617705&api=v2)

We did have to make a few changes to the panel nodes compared to **Panel Markup**, **ListPanel Markup**, and **GridPanel Markup**. If you look at the `listpanel.xml` component file, you'll see that there aren't any significant changes. Actually, the biggest change is the addition of more **Content Meta-Data** for each item in the list, as seen in the server content meta-data file for this example:

<http://www.sdktestinglab.com/Tutorial/content/panelsetcontent.xml>

We've added `description` and `url` attribute fields to each item, in addition to the `title` attribute field in **ListPanel Markup**. That's because we'll be sending the values of these fields to the other panel nodes for automatic configuration of the panel nodes.

We do this by adding an **<interface>** element to the other panel nodes. This allows the **Scene** node to set fields in the panel node **<interface>** element, which causes an automatic trigger of a callback function in the node using the `onChange`attribute of the field.

For example, look at the **<interface>** element in the `panel.xml` component file:

```
<interface >
  <field id = "description" type = "string" onChange = "showdescription" />
</interface>
```

When the **Scene** node sets the `description` field of the panel node with the equivalent **Content Meta-Data** attribute field in the **ListPanel** node focused list item:

```
panelcontent = m.listpanel.list.content.getChild(m.listpanel.list.itemFocused)
m.panel.description = panelcontent.description
```

The change in the **Panel** node `description` field triggers the `showdescription()` callback function:

```
sub showdescription()
  m.infolabel.text = m.top.description
end sub
```

And the value of the `description` **Content Meta-Data** attribute field is automatically displayed as the **Label** node `text` field in the panel node. As the user moves the focus up or down the **ListPanel** node list, the corresponding `description`**Content Meta-Data** attribute field is automatically displayed in the panel node for each list item.

The same is true for the **GridPanel** node. There an **<interface>** element field is used to set the URI of the XML file that will configure the **GridPanel** node grid:

```
<interface >
  <field id = "gridcontenturi" type = "uri" onChange = "readpostergrid" />
</interface>
```

So when the **Scene** node sets the `gridcontenturi` field, the field change triggers the `readpostergrid()` callback function:

```
sub readpostergrid()
  m.readPosterGridTask = createObject("roSGNode", "ContentReader")
  m.readPosterGridTask.contenturi = m.top.gridcontenturi
  m.readPosterGridTask.observeField("content", "showpostergrid")
  m.readPosterGridTask.control = "RUN"
end sub
```

This reads the server XML file with the grid configuration **Content Meta-Data**. We've seen how this poster grid content reader works before, and as usual we set an observer on the **Task** node to trigger a callback function when the **ContentNode**node is complete. So the poster grid in the **GridPanel** node is configured and ready to be displayed as soon as the user selects the list item in the **ListPanel** node.