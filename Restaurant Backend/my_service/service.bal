import ballerina/http;

type Menu readonly & record {|
    int itemnumber;
    string name;
    boolean availability;
|};

table<Menu> key(name) menu = table[
    {itemnumber: 1, name:"Chicken Kottu Roti", availability:true},
    {itemnumber: 2, name:"Lamprais", availability:true},
    {itemnumber: 3, name:"Risotto", availability:true},
    {itemnumber: 4, name:"Pasta Carbonara", availability:false},
    {itemnumber: 5, name:"Paneer Tikka", availability:true}
];


type Order readonly & record {|
    int ordernumber;
    int itemnumber;
    int tablenumber;
|};


table<Order> key(ordernumber) orders = table[];

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    
    # A resource for generating greetings
    # + name - name as a string or nil
    # + return - string name with hello message or error

    # //Greetings from Deval's Food Court
    resource function get greeting(string? name) returns string|error {
        // Send a response back to the caller.
        if name is () {
            return error("Name should not be empty!");
        }
        return string `Hello, ${name}!, the culinary commander!`;
    }

    //get function to get the menu of the restuarant
    resource function get menu() returns Menu[]|error {
        // Send a response back to the caller.
        return menu.toArray();
    }

    //post method to put an order to the kitchen
    resource function post addorder(@http:Payload Order neworder) returns http:Response|error {
        //add order to the list
        orders.add(neworder);

        // send a success message
        http:Response response = new;
        response.setPayload({ message: "Item added successfully"});
        return response;
    }


    //get function to get the order list 
    resource function get orderlist() returns Order[]|error {
        // Send a response back to the caller.
        return orders.toArray();
    }


    //delete order from order list 
    resource function delete deleteitem(@http:Payload Order deleteorder) returns http:Response|error {
        //delete item from list and return the response
        var result = orders.remove(deleteorder.ordernumber);
         
        if result == deleteorder{
            // send a success message
            http:Response response = new;
            response.setPayload({ message: "Item Deleted successfully"});
            return response;
        } else {
            // send a unsuccesful message
            http:Response response = new;
            response.setPayload({ message: "Item Not Found"});
            return response;
        }
    }


    //update order from order list 
    resource function put updateitem(int? ordernumber, int? tablenumber, int? itemnumber) returns http:Response|error {
        //delete item from list and return the response
        
        if (ordernumber is int) && (tablenumber is int) && (itemnumber is int){

            Order updateorder ={ordernumber: ordernumber, itemnumber: itemnumber, tablenumber: tablenumber};

            Order? result = orders.get(updateorder.ordernumber);
            
            if result is Order{
                // update order
                orders.put(updateorder);

                http:Response response = new;
                response.setPayload({ message: "Item Updated successfully"});
                return response;
            } else {
                // send a unsuccesful message
                http:Response response = new;
                response.setPayload({ message: "Item Not Found"});
                return response;
            }
        }else {
            http:Response response = new;
            response.statusCode = 400;
            response.setPayload({message: "Bad Request"});
            return response;
        }
    }
}
