<h1>Sample Channel</h1>

<h2>Summary</h2>
Demonstrates Roku Pay operations, including purchase, upgrade, and downgrade. The Subscriptions menu displays the products available for purchase on this channel. Click on the OK button on the remote to start a Roku Pay operation.

<h2>Running and Testing</h2>
<h3>Preparation:</h3>
Go to Manage My In-Channel Products on the developer dashboard, set up a product group, and add your products to the group.

<h3>How to Use:</h3>
Go to Subscriptions menu and select one product for purchase. When one product is already purchased (has a check mark), next product selected is an upgrade or downgrade.

<h2>Details</h2>
The sample channel uses the ChannelStore node doOrder command to perform an upgrade or downgrade, more information on the doOrder command is available on the developer docs [ChannelStore page](https://developer.roku.com/docs/references/scenegraph/control-nodes/channelstore.md#doorder).

Normally, requesting a doOrder command results in a new purchase. For the upgrade or downgrade, a new Action field is added to the Channel Store order to specify either an upgrade or a downgrade, e.g. the following is a code snippet of a request from function makeUpgrade() in Billing.brs:

    myOrder.action = request.action ' action is either "Upgrade" or "Downgrade"
    m.store.order = myOrder

    m.store.command = "doOrder"
