# Label Markup

The **Label** node class writes text in a specified position on the display screen. The `LabelExample.zip` example writes **All the Best Videos...All the Time!** on the display screen. The **Label** node is defined in the component XML file as follows:

```
<Label 
  id = "exampleLabel" 
  width = "512"
  height = "44" 
  font = "font:MediumBoldSystemFont" 
  text = "All the Best Videos...All the Time!" 
  horizAlign = "center" 
  vertAlign = "center" />
```

There are a few things to note about the **Label** node definition:

- Again, in this case, we want to define an ID to allow other non-renderable nodes, such as **Animation** node classes, to target the node:

**id = "exampleLabel"**

- We define a `height` field value of 44, and a width field value of 512, to set these explicitly (the **Label** node is able to calculate these values based on the text string to be shown and the font:

**width = "512" height = "44"**

- We use a slightly bolder version of the default Roku SceneGraph font:

**font = "font:MediumBoldSystemFont"** 

- We define the text string to be shown on the display screen:

 **text = "All the Best Videos...All the Time!"**

- We define the position of the text to be horizontally centered in the 512 HD UI resolution pixels label area, and centered within the specified height of 44 HD UI resolution pixels:

**horizAlign = "center" vertAlign = "center"**

And after the standard example centering in the **init()** function, the result on the display screen is:

![img](https://sdkdocs.roku.com/download/attachments/1606014/labeldoc.jpg?version=2&modificationDate=1472835515400&api=v2)