## Z-Order Rectangles Markup

By default, renderable nodes are drawn on the screen in z-order, that is, the first node defined at the top of the SceneGraph XML file is drawn first, the second node down is drawn second, and so forth.

For renderable nodes that occupy all or part of a display screen area already occupied by another renderable node, the node drawn last is drawn on top of the previously drawn node. This means that a node drawn first because it was at the top of the XML node tree will be partially or completely covered by successively-drawn nodes lower in the XML node tree. 

Just to illustrate this concept, this example draws three **Rectangle** nodes of successively larger sizes and different colors overlapping each other in z-order. Note that because this is a component extended from a scene node, we must use a [**Group**](https://developer.roku.com/docs/references/api-index/scenegraph/layout-group-nodes/group.md) node to contain multiple renderable nodes in the **<children>** element:

**Z-Order Rectangles XML Example** 
```
<?xml version = "1.0" encoding = "utf-8" ?>
<!--********** Copyright 2016 Roku Corp.  All Rights Reserved. **********-->
<component name = "ZORectanglesExample" extends = "Scene" >
  <script type = "text/brightscript" >
    <![CDATA[
    sub init()
      m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
      example = m.top.findNode("exampleRectangles")
      examplerect = example.boundingRect()
      centerx = (1280 - examplerect.width) / 2
      centery = (720 - examplerect.height) / 2
      example.translation = [ centerx, centery ]
      m.top.setFocus(true)
    end sub
    ]]>
  </script>
  
  <children>
    <Group id = "exampleRectangles" >
      <Rectangle
        id = "lowestRectangle"
        translation = "[ 0.0, 0.0 ]"
        width = "180"
        height = "60"
        color = "0xEB1010FF" />
      <Rectangle
         id = "middleRectangle"
         translation = "[ 60.0, 30.0 ]"
         width = "360"
         height = "120"
         color = "0x10EB10FF" />
      <Rectangle
         id = "highestRectangle"
         translation = "[ 180.0, 90.0 ]"
         width = "720"
         height = "240"
         color = "0x1010EBFF" />
    </Group>
  </children>
</component>
```

This node tree results in this SceneGraph scene:

![img](https://sdkdocs.roku.com/download/attachments/1606018/zorectanglesdoc.jpg?version=2&modificationDate=1472835755062&api=v2)

Note that the **Rectangle** node drawn last, the largest blue rectangle defined last in the XML node tree, is partially drawn on top of the next highest defined rectangle, the medium-sized green rectangle. The smallest red rectangle, because it was drawn first as the first rectangle defined in the node tree, is partially covered by the green rectangle. 

This allows you to do things like "reveal" first-drawn nodes by "fading out" later-drawn nodes using an **Animation** node to control the `opacity` field of the node...but we're getting slightly ahead of ourselves here.

So let's step back and see how some of our previous renderable node classes (**Rectangle**, **Label**, and **Poster** from [**Renderable Node Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes)) could be combined by drawing them in z-order. Download and side-load `ZORenderablesExample.zip`, which has the following SceneGraph node tree XML markup:

```
<children>
  <Group id = "exampleRenderables" >
    <Poster 
      id = "examplePoster" 
      width = "512" 
      height = "288" 
      uri = "http://sdktestinglab.com/Tutorial/images/videopg.jpg" />
    <Rectangle 
      id = "bottomRectangle" 
      translation = "[ 0, 244 ]" 
      width = "512" 
      height = "34" 
      color = "0x1010EBFF" />
    <Label 
      id = "bottomLabel" 
      translation = "[ 0, 244 ]" 
      width = "512" 
      height = "34" 
      font = "font:SmallBoldSystemFont" 
      text = "All the Best Videos...All the Time!" 
      horizAlign = "center" 
      vertAlign = "center" />
  </Group>
</children>
```

The result is:

![img](https://sdkdocs.roku.com/download/attachments/1606018/zorenderablesdoc.jpg?version=2&modificationDate=1472835838055&api=v2)

The XML definitions of the **Rectangle**, **Label**, and **Poster** nodes are similar or identical to what we used previously in [**Renderable Nodes Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/renderable%20nodes). The only difference is we combined them on the screen by listing them in z-order.

Again, because the **Poster** node was drawn first, it is partially covered by the **Rectangle** node, which itself is partially covered by the **Label** node, drawn second and last respectively. But there's a more interesting way to achieve the same effect...