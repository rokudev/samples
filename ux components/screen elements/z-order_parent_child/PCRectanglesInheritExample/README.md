# Parent-Child Inheritance Markup

Let's look at another way to combine renderable nodes together in a group, but with some important differences. Remember the **Rectangle** nodes we defined in z-order in [**Z-Order Rendering Markup**](https://github.com/rokudev/samples/blob/master/ux%20components/screen%20elements/z-order_parent_child/ZORenderablesExample.zip)? Here's some XML markup that shows how to define successive levels of parent-child node relationships, using the same size and color rectangles as before:

```
<children>
  <Group id = "exampleRectangles" >
    <Rectangle 
      id = "lowestRectangle" 
      width = "180" 
      height = "60" 
      color = "0xEB1010FF" >
      <Rectangle 
        id = "middleRectangle" 
        translation = "[ 60, 30 ]" 
        width = "360" 
        height = "120" 
        color = "0x10EB10FF" 
        opacity = "0.5" >
        <Rectangle 
          id = "highestRectangle" 
          translation = "[ 120, 60 ]" 
          width = "720" 
          height = "240" 
          color = "0x1010EBFF" 
          opacity = "0.25" />
      </Rectangle>
    </Rectangle>
  </Group>
</children>
```

 

This markup puts the rectangles in exactly the same position as before, but the way they are positioned is different than in previous examples, and just to make it more confusing we've added some `opacity`fields. The result is this:

![img](https://sdkdocs.roku.com/download/attachments/1606018/pcinheritdoc.jpg?version=2&modificationDate=1472835958936&api=v2)

The z-order rendering of the rectangles is the same as for other methods of grouping renderable nodes together, the blue rectangle defined last is drawn on top of the green rectangle. But it's almost impossible to see the blue rectangle! 

That's because in this method of grouping nodes together, where nodes are defined as a child of the previous parent node, the last node defined inherits its characteristics from the previous node. That node in turn inherits its characteristics from its parent node, and so forth. The various fields you can define for a child node are either added to, or multiplied, by the corresponding field in the parent node. This is the same as how nodes in a **Group** node define their `translation` fields as offsets from the **Group** node `translation` field definition (see [**Parent-Child Grouping Markup**](https://github.com/rokudev/samples/tree/master/ux%20components/screen%20elements/z-order_parent_child/PCRenderablesExample)).

In looking at the XML markup, we can see that the first parent node defined, the **red rectangle**, does not have a `translation` field defined, meaning that the default X,Y screen coordinate values of 0,0 will be used.

This means the screen position for the next child node, the **green rectangle**, is defined as an offset from the **red rectangle** screen coordinates:

```
`translation = ``"[ 60, 30 ]"`
```

So the child node **green rectangle** is offset 60 pixels to the right, and 30 pixels down from the position of the parent node **red rectangle**. Then another node for the **blue rectangle** is defined as a child of the **green rectangle**, so its screen coordinates are an offset from its parent node, the **green rectangle**:

```
`translation = ``"[ 120, 60 ]"`
```

So the **blue rectangle** is offset 120 pixels to the right, and 60 pixels down from the **green rectangle**. So why is it almost invisible?

Note that we added an `opacity` field to the green rectangle definition. 

**50% opacity**

```
`opacity = ``"0.5"`
```

Opacity is the inverse of transparency, ranges from 0.0 (completely transparent) to 1.0 (completely visible - opaque), and is a definable field for all renderable nodes, because they are derived from the **Group** node class. So if a renderable node has an `opacity` field definition of 0.5, it is half transparent, like the **green rectangle** (note the lowest red rectangle shows through the **green rectangle**).

In this example, the **blue rectangle** is a child of the **green rectangle** with its own `opacity` field definition:

**25% opacity**

```
`opacity = ``"0.25"`
```

Remember that the characteristics of child nodes are based on the corresponding characteristics of their parent node. In this case, the opacity of the **blue rectangle** is based on the 0.5 opacity of its parent **green rectangle**...but since it has its own opacity definition of 0.25, that 0.25 definition is multiplied by the 0.5 opacity definition of the **green rectangle**, resulting in an effective 0.125 opacity definition for the **blue rectangle**.

This is why the **blue rectangle** is almost invisible, despite being in front of the other rectangles in z-order. It inherited, and then further increased, its own lack of visibility.

Now that you understand all of that, we can move on to making renderable nodes move around and even gradually disappear from the screen...
