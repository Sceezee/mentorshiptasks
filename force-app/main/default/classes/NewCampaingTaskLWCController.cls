public with sharing class NewCampaingTaskLWCController {
    @AuraEnabled
    public static Id insertTask(
        Id CampaignId,
        Id AssignId,
        Date dueDate,
        String Comments,
        String mSubject,
        String mPriority,
        String mStatus
    ) {
        try {
            Task taskForInserting = new Task(
                WhatId = CampaignId,
                OwnerId = AssignId,
                ActivityDate = dueDate,
                Description = Comments,
                Priority = mPriority,
                Subject = mSubject,
                Status = mStatus
            );
            insert taskForInserting;
            return taskForInserting.Id;
        } catch (Exception ex) {
            throw ex;
        }
    }
}
