# Parent-Child Grouping Markup

The real power of SceneGraph markup is seen when you group nodes together for complex effects. As described in [**SceneGraph XML Reference**](https://developer.roku.com/docs/references/scenegraph/core-concepts.md), you can group nodes together using the **Group** node class, or by adding child nodes to a node in the XML markup (you can also manipulate the parent-child relationships of a SceneGraph object using BrightScript). For example, you could use a **Group** node to achieve the exact same screen display as seen above, but with a somewhat different XML markup:

```
<children >
  <Group id = "exampleRenderables" >
    <Poster 
      id = "examplePoster" 
      width = "512" 
      height = "288" 
      uri = "http://sdktestinglab.com/Tutorial/images/videopg.jpg" >
      <Rectangle 
        id = "bottomRectangle" 
        translation = "[ 0, 244 ]" 
        width = "512" 
        height = "34" 
        color = "0x1010EBFF" >
        <Label 
          id = "bottomLabel" 
          width = "512" 
          height = "34" 
          font = "font:SmallBoldSystemFont" 
          text = "All the Best Videos...All the Time!" 
          horizAlign = "center" 
          vertAlign = "center" />
      </Rectangle>
    </Poster>
  </Group>
</children>
```

 

This results in the exact same screen display as in [`ZORenderablesExample.zip`](https://github.com/rokudev/samples/blob/master/ux%20components/screen%20elements/z-order_parent_child/ZORenderablesExample.zip):

![img](https://sdkdocs.roku.com/download/attachments/1606018/pcrenderablesdoc.jpg?version=4&modificationDate=1472835916514&api=v2)

But can you see the differences in the XML markup? 

The **Rectangle** node we saw in `ZORenderablesExample.zip` is still placed at the X,Y screen coordinates of 0,244 as defined in the `translation` field, but this time as a *child* node of the **Poster** node. And the **Label** node is *now* defined as a child node of the **Rectangle** node. This causes the Rectangle node to inherit the `translation` field values of the **Rectangle** node, which means we don't need a `translation`field at all for the **Label** node (unless we wanted to offset the **Label** node further from the **Rectangle** node translation coordinates, which are *transformed* to 0,0 in the **Label** node).

One advantage of this is that you can move a group of renderable nodes anywhere on the screen by setting the `translation` field of the *group*, and all the renderable nodes are automatically placed in their respective position in the group on the screen. And that is exactly what happens when we center the example in the **init()** function, which we've been doing all along in this tutorial:

```
example = m.top.findNode("exampleRenderables")
examplerect = example.boundingRect()
centerx = (1280 - examplerect.width) / 2
centery = (720 - examplerect.height) / 2
example.translation = [ centerx, centery ]
```

We've been using the **findNode()** method to create an example object, then we find the dimensions of the example object using the **boundingRect()** method. To find the X,Y screen coordinates to center the example in the display screen, we subtract the dimensions of the example from the HD UI resolution screen dimensions these examples are designed for, and divide the results by 2. Finally, we set the X,Y screen coordinate results in the example object `translation` field. All of the various renderable nodes in the example are automatically correctly positioned in the center of the display screen.

But as described in [**SceneGraph XML Reference**](https://developer.roku.com/docs/references/scenegraph/core-concepts.md), it is not only the position of a group of renderable nodes that can be changed, but several other factors as well.