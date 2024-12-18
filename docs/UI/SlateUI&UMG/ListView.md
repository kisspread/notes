title: ListView 用法分析
comments:true

---

reference:
- [Directory TreeView Example](https://santa.wang/customwidget_directorytreeview/)
- [FlowGraph-TreeView用例](https://santa.wang/flowgraph-search-not-rely-on-engine/)

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

如果数据项不是UObject类型，那么选择 继承于UListViewBase，自定义一个比较好。如果是基于UListView，而数据项是FMyData的话，那么就得用UObject 来 包裹这个 FMyData。

UListViewBase本身不是模板类，如果要支持模板化，可以实现 **ITypedUMGListView** 接口

```cpp
/**
 * Mirrored SListView<T> API for easier interaction with a bound UListViewBase widget
 * See declarations on SListView for more info on each function and event
 *
 * Note that, being a template class, this is not a UClass and therefore cannot be exposed to Blueprint.
 * If you are using UObject* items, just use (or inherit from) UListView directly
 * Otherwise, it is up to the child class to propagate events and/or expose functions to BP as needed
 *
 * Use the IMPLEMENT_TYPED_UMG_LIST() macro for the implementation boilerplate in your implementing class.
 * @see UListView for an implementation example.
 */
template <typename ItemType>
class ITypedUMGListView
```



---

## FCommonNativeListItem 

如果选择继承UListViewBase并自定义模板，**CommonUI** 提供一个更好的父类，**FCommonNativeListItem**

它实现了一个轻量级的运行时类型系统，性能更好。

```cpp
/** 
 * Base item class for any UMG ListViews based on native, non-UObject items.
 *
 * Exclusively intended to provide bare-bones RTTI to the items to allow one array of list items to be multiple classes 
 * without needing a different, more awkward identification mechanism or an abstract virtual of every conceivable method in the base list item class
 */
class FCommonNativeListItem : public TSharedFromThis<FCommonNativeListItem>
 ```

- RTTI 的含义：

RTTI 是 C++ 的一个特性，允许程序在运行时确定对象的类型。标准的 C++ RTTI 包括 dynamic_cast 和 typeid 操作符。

- bare-bones RTTI：

这里的 "bare-bones" 意味着基本的、简化的。它暗示这个 RTTI 系统比标准 C++ RTTI 更加轻量和简单

它提供的一段小 demo

```c++
class FMyCustomListItem : public FCommonNativeListItem
{
	DERIVED_LIST_ITEM(FMyCustomListItem, FCommonNativeListItem);
}

class FMyCustomUsualListItem : public FMyCustomListItem
{
	DERIVED_LIST_ITEM(FMyCustomUsualListItem, FMyCustomListItem);
};

class FMyCustomSpecialCaseListItem : public FMyCustomListItem
{
	DERIVED_LIST_ITEM(FMyCustomSpecialCaseListItem, FMyCustomListItem);
}; 

class UMyCustomListView : public UListViewBase, ITypedUMGListView<TSharedPtr<FMyCustomListItem>>
{
	GENERATED_BODY()
	IMPLEMENT_TYPED_UMG_LIST(TSharedPtr<FMyCustomListItem, MyListView>)

public:
	...

private:
	TSharedPtr<SListView<TSharedPtr<FMyCustomListItem>>> MyListView;
}
```



## SListView

