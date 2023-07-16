import { LightningElement, track } from 'lwc';
import conrecords from '@salesforce/apex/Accsearchcontroller.getContactlist';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const COLUMNS1= [
        {label:'FirstName',fieldName:'FirstName'},
        {label:'LastName',fieldName:'LastName'},
        {label:'Account Id',fieldName:'AccountId'},
        {label:'Account Name',fieldName:'Account.name'},
        {label:'Email',fieldName:'Email'},
        {label:'Name',fieldName:'Name'}
         ];
export default class accountToContact extends LightningElement
 {
    @track columns1= COLUMNS1;
    @track Accounts;
    @track Contacts;
    sword = '';

 
    // update sVal var when input field value change
    Handlechange(event) {
        this.sword = event.target.value;
    }
 
    // call apex method on button click 
    Searchaccounts() {
        // if search input value is not blank then call apex method, else display error msg 
        if (this.sword != '') {
                conrecords({
                    inpname: this.sword
                    })
                    .then(result => {
                        // set @track contacts variable with return contact list from server  
                        this.Contacts = result;
                    })
                    .catch(error => {
                        // display server exception in toast msg 
                        const event = new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: error.body.message,
                        });
                        this.dispatchEvent(event);
                        // reset contacts var with null   
                        this.Contacts = null;
                    });
        } else {
            // fire toast event if input field is blank
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Search text missing..',
            });
            this.dispatchEvent(event);
        }
    }
}