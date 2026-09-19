trigger OpportunityTrigger on Opportunity (after update)
{
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        opportunityRollup.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}