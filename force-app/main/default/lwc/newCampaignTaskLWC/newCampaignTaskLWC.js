import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import insertTask from "@salesforce/apex/NewCampaingTaskLWCController.insertTask";

export default class newCampaignTaskLWC extends LightningElement {
    @api recordId;
    @track AssignedToFieldValue;
    @track DueDateFieldValue;
    @track SubjectFieldValue;
    @track PriorityFieldValue;
    @track StatusFieldValue;
    @track CommentsFieldValue;
    @track isModalOpen = false;

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }

    handleAssignedToChange(event) {
        this.AssignedToFieldValue = event.target.value;
    }
    handleDateChange(event) {
        this.DueDateFieldValue = event.target.value;
    }
    handleSubjectChange(event) {
        this.SubjectFieldValue = event.target.value;
    }
    handlePriorityChange(event) {
        this.PriorityFieldValue = event.target.value;
    }
    handleStatusChange(event) {
        this.StatusFieldValue = event.target.value;
    }
    handleCommentsChange(event) {
        this.CommentsFieldValue = event.target.value;
    }
    handleClick() {
        if (
            this.CommentsFieldValue === undefined ||
            this.CommentsFieldValue === ""
        ) {
            const evt = new ShowToastEvent({
                title: "Error!",
                message: "Check all fields or contact sysadmin",
                variant: "error"
            });
            this.dispatchEvent(evt);
        } else {
            insertTask({
                CampaignId: this.recordId,
                AssignId: this.AssignedToFieldValue,
                dueDate: this.DueDateFieldValue,
                Comments: this.CommentsFieldValue,
                mSubject: this.SubjectFieldValue,
                mPriority: this.PriorityFieldValue,
                mStatus: this.StatusFieldValue
            })
                .then((result) => {
                    const event = new ShowToastEvent({
                        title: "Success!",
                        message: "New Task created." + result,
                        variant: "success"
                    });
                    this.dispatchEvent(event);
                    //this.handleClickCancel();
                    this.isModalOpen = false;
                })
                .catch((error) => {
                    const event = new ShowToastEvent({
                        title: "Error",
                        message: "Check all fields or contact sysadmin" + error,
                        variant: "error"
                    });
                    this.dispatchEvent(event);
                });

        }
    }
    /*handleClickCancel() {
        this.template.querySelectorAll("lightning-input").forEach((element) => {
            element.value = undefined;
            this.DueDateFieldValue = undefined;
        });
        this.template
            .querySelectorAll("lightning-combobox")
            .forEach((element) => {
                element.value = undefined;
                this.SubjectFieldValue = undefined;
                this.PriorityFieldValue = undefined;
                this.StatusFieldValue = undefined;
            });
        this.template
            .querySelectorAll("lightning-textarea")
            .forEach((element) => {
                element.value = undefined;
                this.CommentsFieldValue = undefined;
            });
    }*/

    get optionsPriority() {
        return [
            { label: "High", value: "High" },
            { label: "Normal", value: "Normal" },
            { label: "Low", value: "Low" }
        ];
    }


    get optionsSubject() {
        return [
            { label: "Call", value: "Call" },
            { label: "Email", value: "Email" },
            { label: "Send Letter", value: "Send Letter" },
            { label: "Send Quote", value: "Send Quote" },
            { label: "Other", value: "Other" }
        ];
    }
    get optionsStatus() {
        return [
            { label: "Not Started", value: "Not Started" },
            { label: "In Progress", value: "In Progress" },
            { label: "Completed", value: "Completed" },
            {
                label: "Waiting on someone else",
                value: "Waiting on someone else"
            },
            { label: "Deferred", value: "Deferred" }
        ];
    }
}