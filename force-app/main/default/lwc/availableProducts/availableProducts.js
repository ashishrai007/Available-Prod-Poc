import { LightningElement, wire, api,track } from 'lwc';
import getAvailableProducts from '@salesforce/apex/OrderController.getAvailableProducts';
import addtoOrder from '@salesforce/apex/OrderController.addtoOrder';
import getOrderDetails from '@salesforce/apex/OrderController.getOrderDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const COLS = [
    { label: 'Name', fieldName: 'Name',editable: false,displayReadOnlyIcon: true,sortable:true },
    { label: 'List Price', fieldName: 'UnitPrice',editable: false,displayReadOnlyIcon: true}
];

export default class AvailableProducts extends LightningElement {

    
    @api recordId;  
    @track products;
    @track orderDetails;
    error;    
    columns = COLS;
    buttonvisible = false;
    buttonDisable = false;
    

    _wiredData;
    @wire(getAvailableProducts, { orderId: '$recordId' })
    availableProducts(wireResult){
        const { data, error } = wireResult;
        this._wiredData = wireResult;
        if(data){
            this.products = data;
        }
        if(error) {
            this.error = error;
        }
    }

    _wiredData2;
    @wire(getOrderDetails, { orderId: '$recordId' })
    orderDetails(wireResult){
        const { data, error } = wireResult;
        this._wiredData2 = wireResult;
        if(data){
            this.orderDetails = data;
            if(this.orderDetails && this.orderDetails.Status == 'Activated') {
                this.buttonDisable = true;
            }
        }
        if(error) {
            this.error = error;
        }
    }
       
        //This method is used to stored the product to order product component
        addtoOrder() {
        
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
            
        // Calling the apex method with parameters orderid and products to save the record
        addtoOrder({ products : selectedRecords, orderId : this.recordId }) 
            .then(result => {
                this.message = result;
                this.error = undefined;
                if(this.message !== undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Product(s) added to order successfully!',
                            variant: 'success',
                        }),
                    );
                }                             
                
                this.template.querySelector('c-order-products').handleClick();
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'There was an error in adding Products',
                        variant: 'error',
                    }),
                );                
            });       
        return;  
    }
}