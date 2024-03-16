/* Assignment #1 - Customers & Orders */

% Include the data file containing facts about customers, orders, companies to boycott & alternatives
:-consult(data).
% Define dynamic predicates for addition/removal of facts
:-dynamic(item/3).
:-dynamic(alternative/2).
:-dynamic(boycott_company/2).

% Required Predicates

/* 1. List all orders of a specific customer (as a list) */
list_orders(CustomerName, ListOfOrders).

/* 2. Get the number of orders of a specific customer given customer id. */
countOrdersOfCustomer(CustomerName, OrderCount).

/* 3. List all items in a specific customer order given customer id and order id. */
getItemsInOrderById(CustomerName, OrderId, ListOfItems).

/* 4. Get the number of items in a specific customer order given customer name and order id. */
getNumOfItems(CustomerName, OrderId, ItemCount).

/* 5. Calculate the price of a given order given customer name and order id. */
calcPriceOfOrder(CustomerName, OrderId, TotalPrice).

/* 6. Given the item name or company name, determine whether we need to boycott or not. */
isBoycott(ItemName):-
	item(ItemName, CompanyName, _),
	boycott_company(CompanyName, _).

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
