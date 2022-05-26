import { LightningElement, wire, api,track } from 'lwc';
import getOrderProducts from '@salesforce/apex/OrderController.getOrderProducts';
import activateOrder from '@salesforce/apex/OrderController.activateOrder';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const COLS = [
    { label: 'Name', fieldName: 'productName',editable: false,displayReadOnlyIcon: true,sortable:true },
    { label: 'UnitPrice', fieldName: 'UnitPrice',editable: false,displayReadOnlyIcon: true},
    { label: 'Quantity', fieldName: 'Quantity',editable: false,displayReadOnlyIcon: true },
    { label: 'TotalPrice', fieldName: 'TotalPrice',editable: false,displayReadOnlyIcon: true}
];

export default class OrderProducts extends LightningElement {

    @api recordId;
    @api responseTest;
    error;    
    columns = COLS;
    @track buttonDisable = false;

    _wiredData;
        @wire(getOrderProducts, { orderId: '$recordId' })
        orderProducts(wireResult){
            const { data, error } = wireResult;
            this._wiredData = wireResult;
            if(data){
                this.responseTest = data.map(row=>{
                return{...row, productName: row.Product2.Name, OrderStatus:row.Order.Status}
                });
                
                if(this.responseTest && this.responseTest[0].OrderStatus == 'Activated') {
                      this.buttonDisable = true;
                  }

            }
            if(error) {
                console.error(error);
            }
        }
        
            // To refresh orderProduct data table
            @api handleClick() {
                refreshApex(this._wiredData);
            }

    activateOrder() { 
        
    activateOrder({ ordProducts : this.responseTest }) // from here passing orderitems to apex controller and getting response result
            .then(result => {
                this.message = result;
                this.error = undefined;
                if(this.message !== undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Order Activated successfully!',
                            variant: 'success',
                        }),
                    );
                }
                    return refreshApex(this._wiredData);
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'There was an error activating Order',
                        variant: 'error',
                    }),
                );
            });
    }    
}