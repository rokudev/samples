## MiniKeyboard Markup

**Node Class Reference:**

The **MiniKeyboard** node class provides a simple keyboard to allow the user to enter case-insensitive alphanumeric strings, without punctuation or other special characters. This keyboard can be used to enter search strings or other simple strings that do not require case-sensitivity or special characters.

The example **MiniKeyboard** node is created in the **<children>** element of the `minikeyboardscene.xml` component file with no custom field settings:

```
<children >
  <MiniKeyboard id = "exampleMiniKeyboard" />
</children>
```

And the result is:

![img](https://sdkdocs.roku.com/download/attachments/4262928/minikeyboarddoc.jpg?version=4&modificationDate=1472837860363&api=v2)

In a real application, you would probably want to group the **MiniKeyboard** node with a **Button** node (or possibly a **ButtonGroup** node) to allow the user to inform the application that the string entry is complete (or possibly canceled). Ideally you should write a callback function to perform the operation that requires the string, triggered by an observer on the **Button** node `buttonSelected` field.