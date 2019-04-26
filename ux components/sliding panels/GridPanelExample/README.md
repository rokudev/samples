## GridPanel Markup

**Node Class Reference:** **GridPanel**, **PanelSet**

The **GridPanel** node class is very similar to the **ListPanel** node class seen in [**ListPanel Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels), but automatically integrates a grid node class into a **GridPanel** node. Again, the `panelsetscene.xml` is almost identical to the same file in [**Panel Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels).

But the `gridpanel.xml` component file shows some important differences for this example:

**GridPanel Node Configuration Example**

```
<component name = "GridPanelExample" extends = "GridPanel" initialFocus = "examplePosterGrid" >
 
  <script type = "text/brightscript" >
 
    <![CDATA[
 
    sub init()
      m.top.panelSize = "full"
      m.top.isFullScreen = true
      m.top.leftPosition = 130
      m.top.focusable = true
      m.top.hasNextPanel = false
      m.top.createNextPanelOnItemFocus = false
 
      m.top.grid = m.top.findNode("examplePosterGrid")
 
      m.readPosterGridTask = createObject("roSGNode", "ContentReader")
      m.readPosterGridTask.contenturi = "http://www.sdktestinglab.com/Tutorial/content/rendergridps.xml"
      m.readPosterGridTask.observeField("content", "showpostergrid")
      m.readPosterGridTask.control = "RUN"
    end sub
 
    sub showpostergrid()
      m.top.grid.content = m.readPosterGridTask.content
    end sub
 
    ]]>
 
  </script>
 
  <children >
 
    <PosterGrid
      id = "examplePosterGrid"
      basePosterSize = "[ 512, 288 ]"
      caption1NumLines = "1"
      numColumns = "2"
      numRows = "2"
      itemSpacing = "[ 20, 20 ]" />
 
  </children>
 
</component>
```

First, for this panel node that will contain several posters in the **PosterGrid** node, we set the `panelSize` field to full, and also set the `isFullScreen` field to true. This configures the **PanelSet** node to only display this one large panel, sliding the previous panels off the screen to the left. This becomes more important if we create a dynamic panel set with many different panels of varying sizes.

Next we set a field that controls where this full-size panel will be located on the screen, and set the focus on the grid so it can be used. We also set some fields to false that we would set to true for a more dynamic panel set that automatically created new panels in response to user focus and selection actions:

```
m.top.leftPosition = 130
m.top.focusable = true
m.top.hasNextPanel = false
m.top.createNextPanelOnItemFocus = false
```

Then we set the `m.top.grid` field to the **PosterGrid** node created in XML markup in the **<children>** element, just like setting the `m.top.list` field to the **LabelList** node in [**ListPanel Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels). But in this example, we read the [**Content Meta-Data**](https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md) for the **PosterGrid** node from a server XML file. We use the same `contentreader.xml` **Task** node component file to do this as we've done before for poster grids. As always, when the **Task** node content reader completes the **ContentNode** node for the **PosterGrid** node, a `showpostergrid()` callback function is triggered by the event, and the **GridPanel** node shows the completed poster grid:

![img](https://sdkdocs.roku.com/download/attachments/4262988/gridpaneldoc.jpg?version=6&modificationDate=1472838617705&api=v2) 

As you might guess, the poster grid shown can be controlled by the selection of an item in a previous panel node, by including the URI of the server XML file with the **PosterGrid** node **Content Meta-Data** as part of the **Content Meta-Data** for the items in the previous panel. Which leads right to the [PanelSet example](https://github.com/rokudev/samples/tree/master/ux%20components/sliding%20panels).