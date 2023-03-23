# Transactional Purchases Using the roChannelStore Component

_A sample demonstrating how to setup transactional purchases using the roChannelStore component_

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

Two new functions have been added to the `roChannelStore` component to facilitate transactional purchasing through Roku Billing.

The first step requires creating a roChannelStore object:

```brightscript
m.channelStore = createObject("roChannelStore")
```

## Verify user's billing status

`RequestPartnerOrder(orderInfo, productID) as Object`

This function is a prerequisite to processing the transaction and checks the user's billing status. This function accepts the following parameters:

| Member | Type | Description |
| ------ | ---- | ----------- |
| orderInfo | roAssociativeArray | contains two String values:<ul><li>priceDisplay - the price displayed</li><li>price - the price to charge</li></ul>
| productID | String | the product's unique ID (as entered when the product was created)

```brightscript
orderInfo = {
  "priceDisplay": "1.99",
  "price": "1.99"
}

orderRequest = m.channelStore.requestPartnerOrder(orderInfo, "tvod-rental")
```

> Note that currency symbols should not be included for `priceDisplay` and `price`.

This function returns an roAssociativeArray containing the following values:

| Key | Type | Value |
| --- | ---- | ----- |
| id | String | This ID must be passed in the `orderInfo` parameter in `confirmPartnerOrder()`
| status | String | `Success` or `Failure`
| tax | String | Cost of tax (if applicable)
| total | String | Total price of transaction

```brightscript
{
    id: "6fccd747-438c-4a45-91ab-847f57e782fa"
    status: "Success"
    tax: "$0.00"
    total: "$1.99"
}
```

If `status` is `Failure`, an roAssociativeArray with the following values will be returned:

| Key | Type | Value |
| --- | ---- | ----- |
| errorCode | String | An error code representing why the transaction failed
| errorMessage | String | If status is `Failure`, this contains an error message explaining why the transaction failed
| status | String | `Failure`

```brightscript
{
    errorCode: "Declined"
    errorMessage: "Your Roku account is currently not set up for Channel Store purchases. Please log into your Roku account at roku.com to modify your account settings."
    status: "Failure"
}
```

## Complete the transaction

After confirming the user has a valid billing status, the `id` returned from `requestPartnerOrder()` must be passed as a parameter into the following function.

`confirmPartnerOrder(confirmOrderInfo, productID) as Object`

This function takes the following parameters:

| Member | Type | Description |
| ------ | ---- | ----------- |
| confirmOrderInfo | roAssociativeArray | see following table
| productID | String | the product's unique ID (as entered when the product was created)

| Member | Type | Required | Description |
| ------ | ---- | -------- | ----------- |
| title | String | Required | the name of the content item (show on user's invoice)
| priceDisplay | String | Required | the original price displayed
| price <sup>1</sup> | String | Required | the price to charge
| orderID | String | Required | the ID returned from `RequestPartnerOrder()`

> <sup>1</sup> If using the `total` from the roAssociativeArray returned from `requestPartnerOrder()`, the currency symbol must not be included for `price` and `priceDisplay`. See example below.

```brightscript
confirmOrderInfo = {
  "title":" The Best Movie Ever",
  "price": Mid(orderRequest.total, 2),
  "priceDisplay": Mid(orderRequest.total, 2),
  "OrderID": orderRequest.id
}

response = m.channelStore.confirmPartnerOrder(confirmOrderInfo, "tvod-rental")
```

As soon as this function is called, the following screen (generated by the Roku OS) will be shown:

![](https://raw.githubusercontent.com/rokudev/docs/master/images/doOrder.jpg)

### Transaction Response

If the user completes the order, an `roAssociativeArray` will be returned containing the following values:

| Key | Type | Value |
| --- | ---- | ----- |
| Purchase ID | String | the transaction ID
| Status | String | `Success` if the transaction is successful, else `Failure`

```brightscript
{
  purchaseId: "6e447262-f607-4b6c-b493-a6f900dc7390"
  status: "Success"
}
```

If `status` is `Failure`, an roAssociativeArray (if using the `roChannelStore` component) with the following values will be returned:

| Key | Type | Value |
| --- | ---- | ----- |
| errorCode | String | An error code representing why the transaction failed
| errorMessage | String | If status is `Failure`, this contains an error message explaining why the transaction failed
| status | String | `Failure`

```brightscript
{
  errorCode: "PurchaseUnsuccessful"
  errorMessage: "We’re sorry your financial institution has declined our payment attempt. Please resolve the matter with your bank and try your purchase again."
  status: "Failure"
}
```
