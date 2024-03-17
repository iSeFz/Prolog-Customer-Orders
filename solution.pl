/* Assignment #1 - Customers & Orders */

% Include the data file containing facts about customers, orders, companies to boycott & alternatives
:-[data].
% Define dynamic predicates for addition/removal of facts
:-dynamic(item/3).
:-dynamic(alternative/2).
:-dynamic(boycott_company/2).

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
getItemsInOrderById(CustomerName, OrderId, ListOfItems):-
  customer(CustId,CustomerName),            % get the customerId
  order(CustId,OrderId,ListOfItems).        

/* 4. Get the number of items in a specific customer order given customer name and order id. */
getNumOfItems(CustomerName, OrderId, ItemCount):-
  customer(CustId,CustomerName),           % get the customerId
  order(CustId,OrderId,ListOfItems),      % get the customer list of items of a specific id
  ordersLength(ListOfItems,ItemCount).    % calc the number of items in the list

/* 5. Calculate the price of a given order given customer name and order id. */
% Helper Pridict: Define the calcPriceOfOrder to get the customer id and the order id so that we can obtain items price
calcPriceOfOrder(CustomerName, OrderId, TotalPrice):- 
    customer(CustomerId, CustomerName),
    order(CustomerId, OrderId, Items),
    calcPriceOfItems(Items, TotalPrice).

% Helper Pridict: Define the calcPriceOfItems to get the Total price of all items array

calcPriceOfItems([], 0).

calcPriceOfItems([ItemsHead|ItemsTail], TotalPrice):- 
    item(ItemsHead, _, Price),
    calcPriceOfItems(ItemsTail, TotalPriceTail),
    TotalPrice is Price + TotalPriceTail.

/* 6. Given the item name or company name, determine whether we need to boycott or not. */
isBoycott(ItemName):-
	item(ItemName, CompanyName, _),
	boycott_company(CompanyName, _).

/* 7. Given the company name or an item name, find the justification why you need to boycott this company/item. */
% Helper Pridict: This whyToBoycott handle the first argument if it is the company name, then we can get the justification directly
whyToBoycott(CompanyName, Justification):- 
    item(_, CompanyName, _),
    !,
    boycott_company(CompanyName, Justification).


% Helper Pridict: This whyToBoycott handle the first argument if it is the item name, then we should get its company name, and finally recall the same predicate but now with the company name
whyToBoycott(ItemName, Justification):-
    item(ItemName, CompanyName, _),
    whyToBoycott(CompanyName, Justification).

/* 8. Given an username and order ID, remove all the boycott items from this order. */
% Helper Pridict: Define the boycott items
boycott_item(boycott, Item) :-
    item(Item, Company, _),
    boycott_company(Company, _).

% Helper Pridict:
removeBoycottItems([], Acc, Acc). % Base case: if no items in the list

removeBoycottItems([Item|Rest], Acc, NewList) :-
    boycott_item(boycott, Item), % Check if the item is boycotted
    removeBoycottItems(Rest, Acc, NewList). % remove the boycotted item

removeBoycottItems([Item|Rest], Acc, NewList) :-
    % If the item is not boycotted, add it to the accumulator
    append(Acc, [Item], UpdatedAcc),
    % and complete the recursive call till the end of the order's list
    removeBoycottItems(Rest, UpdatedAcc, NewList).


removeBoycottItemsFromAnOrder(CustomerName, OrderId, NewList) :-
    getCustomerId(CustomerName, CustomerId),
    order(CustomerId, OrderId, Items),
    removeBoycottItems(Items, [], NewList).



/* 9. Given an username and order ID, update the order such that all boycott items are replaced by an alternative (if exists). */
% Update the list of order items with non-boycott products
updateList([],[]).
updateList([Item|Rest], [AltItem|UpdatedRest]):-
	% Check if the item has an alternative and if so, do nothing
	% Otherwise, modify the AltItem to be the current Item (which is non-boycott)
	(alternative(Item, AltItem) -> true; AltItem = Item),
	% Recursively update the rest of the list
	updateList(Rest, UpdatedRest).

replaceBoycottItemsFromAnOrder(CustomerName, OrderId, NewOrderList):-
	% Retrieve the list of customer's order items by order id
	% TODO: Waiting Anwar's Implementation
	getItemsInOrderById(CustomerName, OrderId, ListOfItems),
	updateList(ListOfItems, NewOrderList).

/* 10. Given an username and order ID, calculate the price of the order after replacing all boycott items by its alternative (if it exists). */
calcPriceAfterReplacingBoycottItemsFromAnOrder(CustomerName, OrderId, NewOrderList, TotalPrice).

/* 11. Calculate the difference in price between the boycott item and its alternative. */
% Helper Pridict: getTheDifferenceInPriceBetweenItemAndAlternative gets each alternative item name, then gets the price of the boycott item and each alternative item, and finally assign DifferenceInPrice with the difference in price between them
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

