<h1>Add-on/Bundles sample channel</h1>

This sample channel demonstrates how to integrate add-ons and bundles in your channel to offer customers premium content, additional channels, bundled packages, and other upgrades and features. It lets you purchase base subscription products and bundles in your product catalog, and then purchase any eligible add-ons.

<h2>Billing</h2>
The Billing component implements the new versions of the GetCatalog, DoOrder, and GetPurchases/GetAllPurchases ChannelStore commands, which use Roku's generic request framework. This component initializes the ChannelStore API generic request framework,  monitors whether any commands have been sent, and then sends the request results to the dedicated parser for the command.<br/><br/>

When the Base/Bundle or Add-ons tab is selected in the UI, the component sends the GetCatalog command to get the list of purchase options in the catalog. The associated OnGetCatalog() callback function creates associative array holders for the purchase options and products returned by the GetCatalog command, and then calls the createPurchaseOptionMap() function. The createPurchaseOptionMap() function does a lookup of the purchase options in your catalog using the sku field, and then checks whether a purchase option is for an add-on.<br/>

When a product is selected, the component sends a DoOrder command to purchase the base prerequisite product and any add-ons, and then check the order status. It then checks the order status via the DoOrder command response.

<h2>Screens</h2>
The sample channel includes separate screen components for displaying information about the products in your catalog (ProductScreen), purchases that have been made (PurchasesScreen), and for upgrades/downgrades (UpgradeScreen).
