@isTest
private class TestOrderController {
    @TestSetup
    static void makeData(){

        // Insert Account
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        // Insert Product
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        insert p;
        
        // Query Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        // Insert Order        
        Order o = new Order();
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = a.id;
        o.Pricebook2Id =  pricebookId ;        
        insert o;
        
        // Insert Order Item
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = p.id;
        i.PricebookEntryId=standardPrice.id;
        insert i;      
            
    }
        
        @IsTest
        static void testGetOrderProducts(){

            List<Order> listOrder = [Select ID from Order limit 1];            
            
            Test.startTest();
            OrderController.getOrderProducts(listOrder[0].ID);
            OrderController.getOrderDetails(listOrder[0].ID);
            OrderController.getAvailableProducts(listOrder[0].ID);            
            Test.stopTest();            
        }

        @IsTest
        static void testAddToOrder(){

            List<Order> listOrder = [Select ID from Order limit 1];
            List<PricebookEntry> listpbe = [Select ID, Product2Id, UnitPrice from PricebookEntry];            
            
            Test.startTest();            
            OrderController.addtoOrder(listpbe, listOrder[0].ID);
            Test.stopTest();            
        }

        @IsTest
        static void testActivatedOrder(){

            List<OrderItem> listOrderItem = [Select ID, orderId from OrderItem ];          
            
            Test.startTest();            
            OrderController.activateOrder(listOrderItem);
            Test.stopTest();            
        }
}
