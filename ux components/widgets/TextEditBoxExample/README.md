## TextEditBox Markup

**Node Class Reference:** [**TextEditBox**]

The **TextEditBox** node class is designed to display text as it is entered from a text entry widget, such as a **Keyboard** node. And that's why it is included as an internal node in the [**Keyboard**](https://github.com/rokudev/samples/tree/master/ux%20components/widgets) and **MiniKeyboard** node classes. But the **TextEditBox** node is also available to display any text as it is entered by any method in your application.

For this example, we've just set the `hintText` field to display a "hint" message to users before text entry begins, and set the `width` field to match the length of the `hintText` field value string, in the **<children>** element of the `texteditboxscene.xml` component file: 

```
<children >

  <TextEditBox 
    id = "exampleTextEditBox" 
    width = "780" 
    hintText = "Hint: if you had a Keyboard node, you could enter text here" />

</children>
```

And the result is:

![img](https://sdkdocs.roku.com/download/attachments/4262928/texteditboxdoc.jpg?version=3&modificationDate=1472837717177&api=v2)