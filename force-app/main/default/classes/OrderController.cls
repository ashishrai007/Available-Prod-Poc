public with sharing class OrderController {
    
    /* This method is returning order products based on orderid */
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(String orderId) {
        return [
            SELECT Id, OrderId,Order.Status, Product2Id, Product2.Name, UnitPrice, Quantity, TotalPrice
            FROM OrderItem
            WHERE OrderId = :orderId ORDER BY Product2.Name
        ];
    }
    
    /* This method is returning staus and pricebookid based on orderid*/
    @AuraEnabled(cacheable=true)
    public static Order getOrderDetails(String orderId) {

        return [SELECT Id, Status, Pricebook2Id FROM Order WHERE Id = :orderId];
                
    }

    /* This method is updating order product and order status to Activated after the activate button is clicked*/
    @AuraEnabled
    public static void activateOrder(List<OrderItem> ordProducts) {
        
        String orderId;
        
        for(OrderItem o: ordProducts) {
            orderId = o.orderId;
            o.vlocity_cmt__FulfilmentStatus__c = 'Activated';
        }
        
        update ordProducts;  
        Order obj = new Order();
        obj.Id = orderId;   
        obj.Status = 'Activated';     
        update obj;
    }
    
    /* This method is returning products based on pricebookentry and orderid */
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(String orderId) {
        List<PricebookEntry> availableProducts = new List<PricebookEntry>();
        Map<String, PricebookEntry> aProductsMap = new Map<String, PricebookEntry>();
        Order ordObj =  getOrderDetails(orderId);        
        availableProducts = [select Id,Name,Pricebook2Id,Product2Id,UnitPrice from PricebookEntry where IsActive = true AND  Pricebook2Id =: ordObj.Pricebook2Id ORDER BY Name limit 10];//'01s8b000001N0c5AAC'
        
        //Logic to sort -Products that are already added to the order should appear on top
        List<OrderItem> orderProduts = new List<OrderItem>();
        List<PricebookEntry> sortedList = new List<PricebookEntry>();
        List<PricebookEntry> tempList = new List<PricebookEntry>();
        Map<String, OrderItem> oProductsMap = new Map<String, OrderItem>();
        for(PricebookEntry p: availableProducts) {
            aProductsMap.put(p.Product2Id , p);
        }
        orderProduts = getOrderProducts(orderId);
        for(OrderItem o: orderProduts) {
            oProductsMap.put(o.Product2Id , o);
        }
        for(OrderItem o: orderProduts) {
            if(aProductsMap.containsKey(o.Product2Id)) {
                sortedList.add(aProductsMap.get(o.Product2Id));
            }
        }

        for(PricebookEntry p: availableProducts) {
            if(!oProductsMap.containsKey(p.Product2Id)) {
                sortedList.add(p);
            }
        }
        return sortedList;
        
    }

    /*Inserting and Updating Order Item */

    /* if product alredy exist then update the quantity field of the same product and if not present then insert it as frest order item */

    @AuraEnabled
    public static void addtoOrder(List<PricebookEntry> products, String orderId) {
      
        List<OrderItem> itemsToUpdate = new List<OrderItem>();
        List<OrderItem> itemsToInsert = new List<OrderItem>();
        Map<String, OrderItem> orderProdutsMap = new Map<String, OrderItem>();
        List<OrderItem> orderProduts = getOrderProducts(orderId);
        for(OrderItem o: orderProduts) {
            orderProdutsMap.put(o.Product2Id, o);
        }
        
        for(PricebookEntry p: products) {
            if(orderProdutsMap.containsKey(p.Product2Id)) {
                OrderItem obj =  orderProdutsMap.get(p.Product2Id);
                obj.Quantity = obj.Quantity + 1;
                itemsToUpdate.add(obj);
            } else {
                OrderItem obj =  new OrderItem();
                obj.OrderId = orderId;
                obj.Product2Id = p.Product2Id;
                obj.PricebookEntryId=p.Id;
                obj.Quantity = 1;
                obj.UnitPrice = p.UnitPrice;
                itemsToInsert.add(obj);
            }
        }

        if(itemsToUpdate.size() > 0) {
            update itemsToUpdate;
        }
        if(itemsToInsert.size() > 0) {
            insert itemsToInsert;
        }
    }
}