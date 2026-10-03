@addMethod(W3PlayerWitcher)
function STR_SetItemCount(item : name, count : int)
{
	var diff : int;

	diff = inv.GetItemQuantityByName(item) - count;
	if(diff > 0)
		inv.RemoveItemByName(item, diff);
	else if(diff < 0)
		inv.AddAnItem(item, -diff, true, true);
}

@wrapMethod(W3PlayerWitcher)
function ConsumeItem(itemId : SItemUniqueId) : bool
{
	var keepPotion, consumed : bool;
	var count : int;

	keepPotion = STR_KeepClearingPotion() && inv.GetItemName(itemId) == 'Clearing Potion';

	if(keepPotion)
	{
		count = inv.GetItemQuantityByName('Clearing Potion');
		inv.AddAnItem('Clearing Potion', 1, true, true);
	}

	consumed = wrappedMethod(itemId);

	if(keepPotion)
		STR_SetItemCount('Clearing Potion', count);

	return consumed;
}
