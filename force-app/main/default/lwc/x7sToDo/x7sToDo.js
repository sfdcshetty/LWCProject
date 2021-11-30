/**
 * Created by karolbrennan on 5/11/21.
 */

import {LightningElement, track, api} from 'lwc';
import getToDos from '@salesforce/apex/PortalToDoClass.getTodos';
import updateToDo from '@salesforce/apex/PortalToDoClass.updateTodo';

export default class X7SToDo extends LightningElement {

    @track isLoading = false;
    @track allToDos = [];
    @api uploadLink = '/clientportal/s/documents';

    connectedCallback() {
       this.getToDoList();
    }

    getToDoList(){
        this.isLoading = true;
        getToDos().then(result => {
            // format todos
            let todos = [];
            result.forEach(todo => {
                if (todo.hasOwnProperty('Due_Date__c')) {
                    todo.dueDate = this.getFormattedDate(todo.Due_Date__c);
                }
                if (todo.hasOwnProperty('Completed_Date__c')) {
                    todo.completedDate = this.getFormattedDate(todo.Completed_Date__c);
                }
                if (todo.hasOwnProperty('Is_Document_Request__c') && todo.Is_Document_Request__c === true) {
                    todo.Name = todo.Name +
                        ` <a href=${this.uploadLink}>upload the document</a>`
                }
                todos.push(todo);
            })
            this.allToDos = todos;
        }).catch(error => {
            console.error(error);
        }).finally(() => {
            this.isLoading = false;
        });
    }
    
    /*getFormattedDate(date){
        // convert to javascript date object
        date = new Date(date);
        return (date.getMonth() + 1) + '/' + (date.getDate() + 1)+ '/' + date.getFullYear();
    }*/
    getFormattedDate(date){
        // convert to US formatting
        let dateSplit = date.split('-');
        let dateNew = dateSplit[1]+'/'+dateSplit[2]+'/'+dateSplit[0];
        return dateNew;
    }

    handleUpdateTodo(event){
        let id = event.currentTarget.dataset.id;
        let checked = event.currentTarget.checked;

        this.isLoading = true;
        updateToDo({Id: id, Status: checked}).then(() =>{
            this.isLoading = false;
        }).finally(() => {
            // update the to do list
            this.getToDoList();
        });
    }

    get hasOpenToDos(){
        return this.openToDos.length > 0;
    }

    get hasClosedToDos(){
        return this.closedToDos.length > 0;
    }

    get openToDos(){
        let todos = [];
        this.allToDos.forEach(todo => {
            if(todo.hasOwnProperty('Is_Completed__c')) {
                if(todo.Is_Completed__c === false) {
                    todos.push(todo);
                }
            }
        });
        return todos;
    }

    get closedToDos(){
        let todos = [];
        this.allToDos.forEach(todo => {
            if(todo.hasOwnProperty('Is_Completed__c')) {
                if(todo.Is_Completed__c === true) {
                    todos.push(todo);
                }
            }
        });
        return todos;
    }
}