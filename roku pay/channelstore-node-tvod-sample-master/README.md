# Transactional Purchases using the ChannelStore Node
_A sample demonstrating how to setup transactional purchases using the ChannelStore node_

**Overview**

The Spring 2017 Roku OS release now includes the ability to do transactional purchasing through Roku's billing system. The functionality is available for both the `roChannelStore` component and `ChannelStore` node and allows partners to dynamically set the amount to charge to a user's payment method on file with Roku. Prior to this feature, each title in a partner's catalog required an associated product on Roku's backend. Now a single generic product can be used across all titles in a partner's catalog.

**Sections:**

* [Create in-channel product](#create-in-channel-product)
* [Initialization](#initialization)
* [Verify user's billing status](#verify-users-billing-status)
* [Complete the transaction](#complete-the-transaction)

---

## Create in-channel product

Login to your Roku developer account and select [**Add a Product**](https://developer.roku.com/products/create/digital) on the **Manage In-Channel Products** page.

![](https://raw.githubusercontent.com/rokudev/docs/master/images/add-a-product.png)

Refer to the following table to create a TVOD specific product:

| Product Information | Value |
| ------------------- | ----- |
| Channels | Add channel(s) that can access this product
| Product Name | Any <sup>1</sup>
| Identifier | a unique product identifier
| Purchase Type | One-Time Purchase
| Classification | Video
| Internet Connection Required | Yes
| Requires Additional Purchase | No
| Cleared for Sale | Yes
| Price Tier | Any <sup>1</sup>

> <sup>1</sup> This value can be modified for each transaction.

This product will be referred to as `tvod-rental` in the examples below.

## Initialization

Two new commands have been added to the `ChannelStore` node to facilitate transactional purchasing through Roku Billing:

* [requestPartnerOrder](https://sdkdocs.roku.com/display/sdkdoc/ChannelStore#ChannelStore-requestPartnerOrder)
* [confirmPartnerOrder](https://sdkdocs.roku.com/display/sdkdoc/ChannelStore#ChannelStore-confirmPartnerOrder)

The first step requires creating a ChannelStore node:

```brightscript
m.channelStore = createObject("roSGNode", "channelStore")
```

## Verify user's billing status

[`RequestPartnerOrder`](https://sdkdocs.roku.com/display/sdkdoc/ChannelStore#ChannelStore-requestPartnerOrder): This command is a prerequisite to processing the transaction and checks the user's billing status.

Prior to setting this command, create a `ContentNode` with 3 fields: `priceDisplay`, `price`, and `code`. The `code` is the productID and must be added as a field to the `ContentNode` via the [`addField()`](https://sdkdocs.roku.com/display/sdkdoc/ifSGNodeField) method.

```brightscript
m.orderInfo = createObject("roSGNode", "contentNode")
m.orderInfo.priceDisplay = "1.99"
m.orderInfo.price = "1.99"

m.orderInfo.addField("code", "string", false)
m.orderInfo.code = "tvod-rental"

m.channelStore.requestPartnerOrder = m.orderInfo
m.channelStore.command = "requestPartnerOrder"
```

> Note that currency symbols should not be included for `priceDisplay` and `price`.

If `status` is `Success`, `requestPartnerOrderStatus` will be set to a ContentNode containing the following fields:

| Key | Type | Value |
| --- | ---- | ----- |
| orderID | String | This ID is required for the `confirmPartnerOrder` command
| status | String | `Success`
| tax | String | Cost of tax (if applicable)
| total | String | Total price of transaction

```brightscript
{
    change: <Component: roAssociativeArray>
    focusable: false
    focusedChild: <Component: roInvalid>
    id: ""
    orderID: "6fccd747-438c-4a45-91ab-847f57e782fa"
    status: "Success"
    tax: "$0.00"
    total: "$1.99"
}
```

To capture this response, set an observer on the `requestPartnerOrderStatus` field with an associated callback function.

```brightscript
m.store.observeField("requestPartnerOrderStatus", "requestPartnerOrderStatusChanged")

'callback function
function requestPartnerOrderStatusChanged()
    if m.store.requestPartnerOrderStatus.status = "Success"
        'user's billing status is valid - prompt the user to purchase
    else
        'display an appropriate error message
    end if
end function
```

If `status` is `Failure`, `requestPartnerOrderStatus` will be set to a ContentNode containing the following fields:

| Field | Type | Description |
| --- | ---- | ----- |
| errorCode | String | An error code representing why the transaction failed
| errorMessage | String | An error message explaining why the transaction failed
| status | String | `Failure`

```brightscript
{
    change: <Component: roAssociativeArray>
    focusable: false
    focusedChild: <Component: roInvalid>
    id: ""
    errorCode: "Declined"
    errorMessage: "Your Roku account is currently not set up for Channel Store purchases. Please log into your Roku account at roku.com to modify your account settings."
    status: "Failure"
}
```

## Complete the transaction

[`confirmPartnerOrder`](https://sdkdocs.roku.com/display/sdkdoc/ChannelStore#ChannelStore-confirmPartnerOrder): After confirming the user has a valid billing status, create a `ContentNode` containing these fields: `title`, `priceDisplay`, `price`, `orderID` and `code`.
`code` represents the productID and must be added as a new field via [`addField()`](https://sdkdocs.roku.com/display/sdkdoc/ifSGNodeField) (see example below).

| Field | Type | Description |
| ----- | ---- | ----------- |
| title | String | the name of the content item (show on user's invoice)
| priceDisplay | String | the original price displayed
| price | String | the price to charge
| orderID | String | the ID from `RequestPartnerOrder`
| code | String | the product identifier as entered on the Developer Dashboard when the product was created

Once those fields have been populated in a ContentNode, set the ContentNode to `confirmPartnerOrder`.
Finally, set the ChannelStore `command` field to `confirmPartnerOrder` to create a prompt for the user to complete the purchase.

```brightscript
'Create a ContentNode containing the details of the purchase
m.confirmOrderInfo = CreateObject("roSGNode", "ContentNode")
m.confirmOrderInfo.title = "The Best Movie Ever"
m.confirmOrderInfo.price = Mid(m.channelStore.requestPartnerOrderStatus.total, 2)
m.confirmOrderInfo.priceDisplay = m.orderInfo.priceDisplay
m.confirmOrderInfo.orderID = m.store.requestPartnerOrderStatus.orderID

'Add a code field to the ContentNode
m.confirmOrderInfo.addField("code", "string", false)

'Set the code to the product identifier of your generic tvod product
m.confirmOrderInfo.code = "tvod-rental"

'Set the ContentNode to the ChannelStore node
m.store.confirmPartnerOrder = m.confirmOrderInfo

'Prompt the user to complete the transaction
m.store.command = "confirmPartnerOrder"
```

As soon as this command is set, the following screen (generated by the Roku OS) will be shown:

![](https://raw.githubusercontent.com/rokudev/docs/master/images/doOrder.jpg)

### Transaction Response

If the user completes the order, `confirmPartnerOrderStatus` will be set to a ContentNode containing the following fields:

| Field | Type | Description |
| --- | ---- | ----- |
| PurchaseId | String | the transaction ID
| Status | String | `Success`

```brightscript
{
  change: <Component: roAssociativeArray>
  focusable: false
  focusedChild: <Component: roInvalid>
  id: ""
  purchaseId: "6e447262-f607-4b6c-b493-a6f900dc7390"
  status: "Success"
}
```

> This response must also be captured via an observer (on the `confirmPartnerOrderStatus` field) and an associated callback function.

If `status` is `Failure`, `confirmPartnerOrderStatus` will be set to a ContentNode containing the following fields:

| Key | Type | Value |
| --- | ---- | ----- |
| errorCode | String | An error code representing why the transaction failed
| errorMessage | String | An error message explaining why the transaction failed
| status | String | `Failure`

```brightscript
{
  change: <Component: roAssociativeArray>
  focusable: false
  focusedChild: <Component: roInvalid>
  id: ""
  errorCode: "PurchaseUnsuccessful"
  errorMessage: "We’re sorry your financial institution has declined our payment attempt. Please resolve the matter with your bank and try your purchase again."
  status: "Failure"
}
```
