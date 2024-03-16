/* Assignment #1 - Customers & Orders */

% Include the data file containing facts about customers, orders, companies to boycott & alternatives
:-consult(data).

% Required Predicates

/* 1. List all orders of a specific customer (as a list) */
list_orders(CustomerName, ListOfOrders).


/* 2. Get the number of orders of a specific customer given customer id. */
% Helper Predict: get the customer id from the customer name
getCustomerId(CustomerName, CustomerId) :-
    customer(CustomerId, CustomerName).

% Helper Pridict: Get the length of the orders
ordersLength([], 0).
ordersLength([_Head|Tail], N):-
    ordersLength(Tail, N1),
    N is N1 + 1.

% Helper Predict: Define the append predicate used in get orders
append([], List, List).
append([Head|Tail1], List2, [Head|Result]) :-
    append(Tail1, List2, Result).

% Helper Pridict: Define the getOrdersForCustomer
getOrdersForCustomer(CustomerId, Orders) :-
    getOrdersForCustomer(CustomerId, 1, [], Orders).

getOrdersForCustomer(CustomerId, OrderNum, AccOrders, Orders) :- % Recursive Call
    order(CustomerId, OrderNum, Order),
    append(AccOrders, [Order], NewAccOrders),
    NextOrderNum is OrderNum + 1,
    getOrdersForCustomer(CustomerId, NextOrderNum, NewAccOrders, Orders).

getOrdersForCustomer(_CustomerId, _OrderNum, Orders, Orders). % Base case

% The main poredict: count all orders of customer id
countOrdersOfCustomer(CustomerName, Count) :-
    getCustomerId(CustomerName, CustomerId),
    getOrdersForCustomer(CustomerId, Orders),
    ordersLength(Orders, Count).


/* 3. List all items in a specific customer order given customer id and order id. */
getItemsInOrderById(CustomerName, OrderId, ListOfItems).

/* 4. Get the number of items in a specific customer order given customer name and order id. */
getNumOfItems(CustomerName, OrderId, ItemCount).

/* 5. Calculate the price of a given order given customer name and order id. */
calcPriceOfOrder(CustomerName, OrderId, TotalPrice).

/* 6. Given the item name or company name, determine whether we need to boycott or not. */
isBoycott(ItemName).

/* 7. Given the company name or an item name, find the justification why you need to boycott this company/item. */
whyToBoycott(ItemName, Justification).

/* 8. Given an username and order ID, remove all the boycott items from this order. */
removeBoycottItemsFromAnOrder(CustomerName, OrderId, NewOrderList).

/* 9. Given an username and order ID, update the order such that all boycott items are replaced by an alternative (if exists). */
replaceBoycottItemsFromAnOrder(CustomerName, OrderId, NewOrderList).

/* 10. Given an username and order ID, calculate the price of the order after replacing all boycott items by its alternative (if it exists). */
calcPriceAfterReplacingBoycottItemsFromAnOrder(CustomerName, OrderId, NewOrderList, TotalPrice).

/* 11. Calculate the difference in price between the boycott item and its alternative. */
getTheDifferenceInPriceBetweenItemAndAlternative(ItemName, Alternative, PriceDiff).

/* 12. [BONUS] Insert/Remove (1)Item, (2)Alternative, and (3)New boycott company to/from the knowledge base. */

