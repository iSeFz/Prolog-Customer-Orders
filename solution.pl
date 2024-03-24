/* Assignment #1 - Customers & Orders */

% Include the data file containing facts about customers, orders, companies to boycott & alternatives
:-[data].
% Define dynamic predicates for addition/removal of facts [BONUS]
:-dynamic(item/3).
:-dynamic(alternative/2).
:-dynamic(boycott_company/2).

% Required Predicates

/* 1. List all orders of a specific customer (as a list) */

getOrdersForCustomer2(CustomerId, OrderNum, AccOrders, Orders):- % Recursive Call
    order(CustomerId, OrderNum, OrderItems),
    NewAccOrders = [order(CustomerId, OrderNum, OrderItems) | AccOrders], % Add new order to the front
    NextOrderNum is OrderNum + 1,
    getOrdersForCustomer2(CustomerId, NextOrderNum, NewAccOrders, Orders).
 getOrdersForCustomer2(_, _, Orders, Orders). % Base case

list_orders(CustomerName, ListOfOrders):-
    customer(CustId, CustomerName),
    getOrdersForCustomer2(CustId, 1, [], ListOfOrders).

/* 2. Get the number of orders of a specific customer given customer id. */
% Helper predicate: Get the length of the orders
ordersLength([], 0).
ordersLength([_ | Tail], N):-
    ordersLength(Tail, N1),
    N is N1 + 1.

% Helper predicate: Define the append predicate used in get orders
append([], List, List).
append([Head | Tail1], List2, [Head | Result]):-
    append(Tail1, List2, Result).

getOrdersForCustomer(CustomerId, OrderNum, AccOrders, Orders):- % Recursive Call
    order(CustomerId, OrderNum, OrderItems),
    append(AccOrders, [OrderItems], NewAccOrders),
    NextOrderNum is OrderNum + 1,
    getOrdersForCustomer(CustomerId, NextOrderNum, NewAccOrders, Orders),
    !. % Cut to prevent backtracking

getOrdersForCustomer(_CustomerId, _OrderNum, Orders, Orders). % Base case

% The main predicate: count all orders of customer id
countOrdersOfCustomer(CustomerName, Count):-
    customer(CustomerId, CustomerName),
    getOrdersForCustomer(CustomerId, 1, [], Orders),
    ordersLength(Orders, Count).

/* 3. List all items in a specific customer order given customer id and order id. */
getItemsInOrderById(CustomerName, OrderId, ListOfItems):-
    customer(CustId, CustomerName),
    order(CustId, OrderId, ListOfItems),
    !. % Cut to prevent backtracking

/* 4. Get the number of items in a specific customer order given customer name and order id. */
getNumOfItems(CustomerName, OrderId, ItemCount):-
    getItemsInOrderById(CustomerName, OrderId, ListOfItems),
    % Calculate the number of items in the order
    ordersLength(ListOfItems, ItemCount).

/* 5. Calculate the price of a given order given customer name and order id. */
% Helper predicate: Calculate the total price of all items in the order
calcPriceOfItems([], 0).
calcPriceOfItems([ItemsHead | ItemsTail], TotalPrice):-
    item(ItemsHead, _, Price),
    calcPriceOfItems(ItemsTail, TotalPriceTail),
    TotalPrice is Price + TotalPriceTail.

calcPriceOfOrder(CustomerName, OrderId, TotalPrice):-
    getItemsInOrderById(CustomerName, OrderId, Items),
    calcPriceOfItems(Items, TotalPrice).

/* 6. Given the item name or company name, determine whether we need to boycott or not. */
isBoycott(ItemName):-
	item(ItemName, CompanyName, _),
	boycott_company(CompanyName, _).

/* 7. Given the company name or an item name, find the justification why you need to boycott this company/item. */
% Helper predicate: This whyToBoycott handle the first argument if it is the company name, then we can get the justification directly
whyToBoycott(CompanyName, Justification):-
    item(_, CompanyName, _),
    !, % Cut to prevent backtracking
    boycott_company(CompanyName, Justification).

% Helper predicate: This whyToBoycott handle the first argument if it is the item name, then we should get its company name, and finally recall the same predicate but now with the company name
whyToBoycott(ItemName, Justification):-
    item(ItemName, CompanyName, _),
    whyToBoycott(CompanyName, Justification).

/* 8. Given an username and order ID, remove all the boycott items from this order. */
% Helper predicate: Remove any boycott item in the list given
removeBoycottItems([], Acc, Acc). % Base case: if no items in the list

removeBoycottItems([Item | Rest], Acc, NewList):-
    isBoycott(Item), % Check if the item is boycotted
    !, % Cut to prevent backtracking
    removeBoycottItems(Rest, Acc, NewList). % Skip the boycotted item

removeBoycottItems([Item | Rest], Acc, NewList):-
    % If the item is not boycotted, add it to the accumulator
    append(Acc, [Item], UpdatedAcc),
    % and complete the recursive call till the end of the order's list
    removeBoycottItems(Rest, UpdatedAcc, NewList).

removeBoycottItemsFromAnOrder(CustomerName, OrderId, NewList):-
    getItemsInOrderById(CustomerName, OrderId, Items),
    removeBoycottItems(Items, [], NewList).

/* 9. Given an username and order ID, update the order such that all boycott items are replaced by an alternative (if exists). */
% Update the list of order items with non-boycott products
updateList([], []).
updateList([Item | Rest], [AltItem | UpdatedRest]):-
	% Check if the item has an alternative and if so, do nothing
	% Otherwise, modify the AltItem to be the current Item (which is non-boycott)
	(alternative(Item, AltItem) -> true; AltItem = Item),
	% Recursively update the rest of the list
	updateList(Rest, UpdatedRest).

replaceBoycottItemsFromAnOrder(CustomerName, OrderId, NewOrderList):-
	% Retrieve the list of customer's order items by order id
	getItemsInOrderById(CustomerName, OrderId, ListOfItems),
	updateList(ListOfItems, NewOrderList).

/* 10. Given an username and order ID, calculate the price of the order after replacing all boycott items by its alternative (if it exists). */
calcPriceAfterReplacingBoycottItemsFromAnOrder(CustomerName, OrderId, NewList, TotalPrice):-
    replaceBoycottItemsFromAnOrder(CustomerName, OrderId, NewList),
    calcPriceOfItems(NewList, TotalPrice).

/* 11. Calculate the difference in price between the boycott item and its alternative. */
% Helper predicate: Get each alternative item name, then gets the price of the boycott item and each alternative item, and finally assign DifferenceInPrice with the difference in price between them
getTheDifferenceInPriceBetweenItemAndAlternative(BoycottItemName, AlternativeItemName, DifferenceInPrice):-
    item(BoycottItemName, _, BoycottItemPrice),
    alternative(BoycottItemName, AlternativeItemName),
    item(AlternativeItemName, _, AlternativeItemPrice),
    DifferenceInPrice is BoycottItemPrice - AlternativeItemPrice.

/* 12. [BONUS] Insert/Remove (1)Item, (2)Alternative, and (3)New boycott company to/from the knowledge base. */
% Add new item to the knowledge base
addNewItem(ItemName, CompanyName, Price):-
	assert(item(ItemName, CompanyName, Price)).

% Add new alternative to the knowledge base
addNewAlternative(ItemName, AlternativeItem):-
	assert(alternative(ItemName, AlternativeItem)).

% Add new boycott company to the knowledge base
addNewBoycottCompany(CompanyName, Justification):-
	assert(boycott_company(CompanyName, Justification)).

% Remove item from the knowledge base
removeItem(ItemName, CompanyName, Price):-
	retract(item(ItemName, CompanyName, Price)).

% Remove alternative from the knowledge base
removeAlternative(ItemName, AlternativeItem):-
	retract(alternative(ItemName, AlternativeItem)).

% Remove boycott company from the knowledge base
removeBoycottCompany(CompanyName, Justification):-
	retract(boycott_company(CompanyName, Justification)).
