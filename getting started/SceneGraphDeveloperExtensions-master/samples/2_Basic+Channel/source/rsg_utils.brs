
' Converts associative array to a node of a given type
' @param inputAA associative array, which will be transformed to roSGNode
' @param nodeType type of node, which will be created
function Utils_AAToNode(inputAA = {} as Object, nodeType = "Node" as String) as Object
    node = createObject("roSGNode", nodeType)

    Utils_forceSetFields(node, inputAA)

    return node
end function


'converts AA to ContentNode
Function Utils_AAToContentNode(inputAA = {} as Object, nodeType = "ContentNode" as String)
    return Utils_AAToNode(inputAA, nodeType)
End Function


' Force sets fields to a given node. If node doesn't have a field, it adds it and then sets
' @param node roSGNode, to which you want to set fields
' @param fieldsToSet associative array of field names and values to be set
sub Utils_forceSetFields(node as Object, fieldsToSet as Object)
    ' if not fw_isSGNode(node) or not fw_isAssociativeArray(fieldsToSet) then return

    existingFields = {}
    newFields = {}

      'AA of node read-only fields for filtering'
    fieldsFilterAA = {
        focusedChild    :   "focusedChild"
        change          :   "change"
        metadata        :   "metadata"
    }

    for each field in fieldsToSet
        if node.hasField(field)
            if NOT fieldsFilterAA.doesExist(field) then existingFields[field] = fieldsToSet[field]
        else
            newFields[field] = fieldsToSet[field]
        end if
    end for

    node.setFields(existingFields)
    node.addFields(newFields)
end sub


'converts array of AAs to content node with child content nodes
Function Utils_ContentList2Node(contentList as Object) as Object
    result = createObject("roSGNode","ContentNode")

    for each itemAA in contentList
        item = Utils_AAToContentNode(itemAA, "ContentNode")
        result.appendChild(item)
    end for

    return result
End Function
