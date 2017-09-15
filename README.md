# Pantri
Grocery inventory app for iOS, currently in development.

INTRODUCTION
------------

This app takes a different approach to managing grocery shopping plans than the traditional shopping list, by maintaining an inventory of items that household users want to keep on hand and whether those items are in or out of stock. Inventories will be shared amongst household members on their different devices, so anyone can quickly mark an item as low or out of stock when they notice it running out. Users can instantly generate grocery lists based on what items are in stock and where they prefer to buy those items, allowing them to make smart shopping decisions even if they didn't have time to plan ahead.

PROGRESS
--------

Implemented features include:
* Inventory stored locally in Core Data
* Inventory synced to CloudKit.
* Most UI features.

Features still in progress:
* Sharing Inventories via CKShare.
* Multiple customizable grocery lists.
  * Shopping trip planning view, allows users to create grocery lists based on 1) what's out of stock & 2) where they like to buy those items.
* Refine interface.
* Make tableview cells expandable for editing.
  * Instead of having an expandable view for generic shopping items, use expandable tableview cell.

Interface Design Plan
---------------------

#### Inventory View
This view will be used the most by everyone in the household. Inventory items can be sorted in different ways so users can easily mark items as out of stock (grey), or take a look at what is in stock for remote meal planning. Users can also swipe right to send an item directly to a grocery list.

![alt text](http://i67.tinypic.com/302s1o0.png)

#### Grocery Planning View
This view will be used mostly by the grocery shoppers in a household. They can see what they need to buy, either by what's most in demand (determined by stock & the priority settings that users set upon item creation) or grouped by what store they like to purchase items at. They can then drag these items into custom grocery lists.

![alt text](http://i65.tinypic.com/bgqu78.png)

#### Grocery Shopping View
This view shows a particular grocery list and will be used only during shopping trips. It organizes items in the same way as standard grocery store sections, so users can find and mark off items easily while shopping. 

![alt text](http://i68.tinypic.com/20749iq.jpg)
  
  
