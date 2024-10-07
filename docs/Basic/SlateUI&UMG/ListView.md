title: ListView
comments:true

## UListView

**UListView** 是专门处理 以 **UObject** 作为父类的数据项的列表。可以认为它是一个专门为UObject 类型优化使用的ListView。

其中，它有专门处理子类是 **AActor** 的类型的情况。

```cpp
void UListView::OnItemsChanged(const TArray<UObject*>& AddedItems, const TArray<UObject*>& RemovedItems)
{
	// Allow subclasses to do special things when objects are added or removed from the list.

	// Keep track of references to Actors and make sure to release them when Actors are about to be removed
	for (UObject* AddedItem : AddedItems)
	{
		if (AActor* AddedActor = Cast<AActor>(AddedItem))
		{
			AddedActor->OnEndPlay.AddDynamic(this, &UListView::OnListItemEndPlayed);
		}
		else if (AActor* AddedItemOuterActor = AddedItem->GetTypedOuter<AActor>())
		{
			// Unique so that we don't spam events for shared actor outers but this also means we can't
			// unsubscribe when processing RemovedItems
			AddedItemOuterActor->OnEndPlay.AddUniqueDynamic(this, &UListView::OnListItemOuterEndPlayed);
		}
	}
    
```    
当Actor 被销毁的时候，会调用 OnListItemEndPlayed

```cpp
void UListView::OnListItemOuterEndPlayed(AActor* ItemOuter, EEndPlayReason::Type EndPlayReason)
{
	for (int32 ItemIndex = ListItems.Num() - 1; ItemIndex >= 0; --ItemIndex)
	{
		UObject* Item = ListItems[ItemIndex];
		if (Item->IsIn(ItemOuter))
		{
			RemoveItem(Item);
		}
	}
}
```
也就是 当Actor 被销毁的时候会自动更新本列表同步数据。

---

## UListViewBase

如果数据项不是UObject类型，那么选择 继承于UListViewBase，自定义一个比较好。如果是基于UListView，而数据项是FMyData，那么就得用UObject 来 warp一层。


---

## FCommonNativeListItem 

```cpp
/** 
 * Base item class for any UMG ListViews based on native, non-UObject items.
 *
 * Exclusively intended to provide bare-bones RTTI to the items to allow one array of list items to be multiple classes 
 * without needing a different, more awkward identification mechanism or an abstract virtual of every conceivable method in the base list item class
 */
 ```

- RTTI 的含义：

RTTI 是 C++ 的一个特性，允许程序在运行时确定对象的类型。标准的 C++ RTTI 包括 dynamic_cast 和 typeid 操作符。

- bare-bones RTTI：

这里的 "bare-bones" 意味着基本的、简化的。它暗示这个 RTTI 系统比标准 C++ RTTI 更加轻量和简单



## SListView

