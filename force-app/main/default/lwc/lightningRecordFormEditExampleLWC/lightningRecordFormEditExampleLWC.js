import { LightningElement, api } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import Rating_Feild from '@salesforce/schema/Account.Rating';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
export default class LightningRecordFormEditExampleLWC extends LightningElement {
    @api recordId;
    @api objectApiName;
    fields = [NAME_FIELD, REVENUE_FIELD, INDUSTRY_FIELD,Rating_Feild];
    handleSubmit(event){
        //you can change values from here
        //const fields = event.detail.fields;
        //fields.Name = 'My Custom  Name'; // modify a field
        console.log('Account detail : ',event.detail.fields.Rating);
        console.log('Account name : ',event.detail.fields.Name);
    }
}