# Customer Revenue Tracking and High-Value Customer Identification

This Salesforce use case keeps Account revenue metrics synchronized with related Closed Won Opportunities and identifies Accounts that reach the high-value customer threshold.

## What is included

- Account custom fields for total won amount, total won deals, and VIP status.
- `OpportunityTrigger`, which recalculates Account totals after Opportunity updates.
- `opportunityRollup`, the bulk-safe Apex handler that aggregates Closed Won Opportunities.
- `OpportunityRollupHandlerTest`, covering stage changes, multiple deals, reversals, and bulk processing.
- `Automatic_Account_Revenue_Rollup_VIP_Customer_Flag`, a record-triggered Flow that marks an Account as a VIP customer when total won amount reaches 500,000 and sends a notification email.

## Business rules

1. Only Opportunities in the `Closed Won` stage contribute to Account totals.
2. `Total_Won_Amount__c` stores the sum of non-null Opportunity amounts.
3. `Total_Won_Deals__c` stores the count of Closed Won Opportunities.
4. The Flow sets `VIP_Customer__c` to true when `Total_Won_Amount__c` is at least 500,000 and the Account is not already marked as VIP.

## Deployment order

1. Deploy the Account custom fields.
2. Deploy the Apex handler, trigger, and test class.
3. Deploy and activate the Flow.
4. Run `OpportunityRollupHandlerTest` and verify the Flow notification recipient in the target org.

## Notes

- The trigger is an `after update` trigger. New Opportunity inserts do not recalculate totals unless the records are subsequently updated.
- The Flow metadata currently contains a notification email address from the source org. Replace it with the intended recipient before deploying to another environment.
- The Apex classes and metadata use API version 67.0.