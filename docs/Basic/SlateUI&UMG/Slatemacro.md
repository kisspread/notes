title: Slate Macro
comment: true

---

## SLATE_BEGIN_ARGS 构造器开始
Slate定义参数，是用构造器，也就是建造者模式来构造参数。

SLATE_BEGIN_ARGS 会创建一个FArguments的内部结构体，这个结构体就是建造者模式的构造器。

```cpp
#define SLATE_BEGIN_ARGS(WidgetType) \
	public:\
	struct FArguments : public TSlateBaseNamedArgs<WidgetType> \
	{ \
		typedef FArguments WidgetArgsType; \
		FORCENOINLINE FArguments()

#define SLATE_END_ARGS() \
	};
```

可以想到，**SNew** 一定返回了一个FArguments的实例，这样才能使用构造器。

过程比较复杂，简单分析一下：    
```cpp
//创建ListViewT
SNew(ListViewT<ItemType>)
.HandleGamepadEvents(true)
.ListItemsSource(&ListItems)

//宏展开后是这样的：
MakeTDecl<ListViewT<ItemType>>( "ListViewT<ItemType>", "ListViewBase.h", 235, RequiredArgs::MakeRequiredArgs() ) <<=  ListViewT<ItemType>::FArguments()
			.HandleGamepadEvents(true)
			.ListItemsSource(&ListItems)
```

这里还有个自定义的运算符重载：<<=

```cpp
	/**
	 * Complete widget construction from InArgs.
	 *
	 * @param InArgs  NamedArguments from which to construct the widget.
	 *
	 * @return A reference to the widget that we constructed.
	 */
	TSharedRef<WidgetType> operator<<=( const typename WidgetType::FArguments& InArgs ) &&
	{
		_Widget->SWidgetConstruct(InArgs);
		_RequiredArgs.CallConstruct(_Widget.Get(), InArgs);
		_Widget->CacheVolatility();
		_Widget->bIsDeclarativeSyntaxConstructionCompleted = true;

		return MoveTemp(_Widget).ToSharedRef();
	}
```    

它被设计为只能在右值上调用，这通常意味着它在临时对象上使用。

<<= 运算符在这里起到了"完成构造"的作用。它接收所有设置好的参数，并用这些参数最终构造出小部件。

通过右值引用和移动语义，减少不必要的复制。

总之，过程非常复杂，但实际使用还是很简洁高效的，知道是怎么回事就可以了。

---


## SLATE_EVENT 构造事件宏

该macro提供了多种方法来在FArguments里构造OnSelectionChanged事件，包括：

- 直接绑定委托
- 静态函数绑定（Static）
- Lambda表达式绑定（Lambda）
- 原始指针绑定（Raw）
- 共享指针绑定（SP）
- UObject绑定（UObject）

### 解析
```cpp
//using声明来创建一个类型别名
using FOnSelectionChanged       = typename TSlateDelegates< NullableItemType >::FOnSelectionChanged;
//创建一个事件类型
SLATE_EVENT( FOnSelectionChanged, OnSelectionChanged ) 

//然后，SListView的成员里定义一个，这样构造器模式里下划线那个，就可以赋值给这个真正的成员。似乎用到了通过右值引用和移动语义，减少复制。
/** Delegate to invoke when selection changes. */
FOnSelectionChanged OnSelectionChanged;

``` 

展开 **SLATE_EVENT** 后，会发现它提供特别多便捷设置方法，这个宏就是为我们简化添加这种构造方法的步骤。
可见，每个方法都返回static_cast<WidgetArgsType*>(this)->Me()，允许链式调用，也就形成了构造器模式。
 

```cpp
        WidgetArgsType& OnSelectionChanged(const FOnSelectionChanged& InDelegate)
		{
			_OnSelectionChanged = InDelegate;
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		WidgetArgsType& OnSelectionChanged(FOnSelectionChanged&& InDelegate)
		{
			_OnSelectionChanged = MoveTemp(InDelegate);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <typename StaticFuncPtr, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged_Static(StaticFuncPtr InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateStatic(InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <typename FunctorType, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged_Lambda(FunctorType&& InFunctor, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateLambda(Forward<FunctorType>(InFunctor), Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged_Raw(UserClass* InUserObject, typename FOnSelectionChanged::template TMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateRaw(InUserObject, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged_Raw(UserClass* InUserObject, typename FOnSelectionChanged::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateRaw(InUserObject, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged(TSharedRef<UserClass> InUserObjectRef, typename FOnSelectionChanged::template TMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateSP(InUserObjectRef, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged(TSharedRef<UserClass> InUserObjectRef, typename FOnSelectionChanged::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateSP(InUserObjectRef, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged(UserClass* InUserObject, typename FOnSelectionChanged::template TMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateSP(InUserObject, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged(UserClass* InUserObject, typename FOnSelectionChanged::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateSP(InUserObject, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged_UObject(UserClass* InUserObject, typename FOnSelectionChanged::template TMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateUObject(InUserObject, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& OnSelectionChanged_UObject(UserClass* InUserObject, typename FOnSelectionChanged::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_OnSelectionChanged = FOnSelectionChanged::CreateUObject(InUserObject, InFunc, Vars...);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		FOnSelectionChanged _OnSelectionChanged;
    
```

### 用法

引擎内部的帮助函数，提供构造帮助类：ListView construction helpers

可以看到，用到了OnSelectionChanged_UObject函数设置值，因为Implementer是Uobject。

```cpp
template <template<typename> class ListViewT = SListView, typename UListViewBaseT>
	static TSharedRef<ListViewT<ItemType>> ConstructListView(UListViewBaseT* Implementer, 
		const TArray<ItemType>& ListItems,
		const FListViewConstructArgs& Args = FListViewConstructArgs())
	{
		static_assert(TIsDerivedFrom<ListViewT<ItemType>, SListView<ItemType>>::IsDerived, "ConstructListView can only construct instances of SListView classes");
		return SNew(ListViewT<ItemType>)
			.HandleGamepadEvents(true)
			.ListItemsSource(&ListItems)
			.IsFocusable(Args.bAllowFocus)
			.ClearSelectionOnClick(Args.bClearSelectionOnClick)
			.ConsumeMouseWheel(Args.ConsumeMouseWheel)
			.SelectionMode(Args.SelectionMode)
			.ReturnFocusToSelection(Args.bReturnFocusToSelection)
			.Orientation(Args.Orientation)
			.ListViewStyle(Args.ListViewStyle)
			.ScrollBarStyle(Args.ScrollBarStyle)
			.PreventThrottling(Args.bPreventThrottling)
			.OnGenerateRow_UObject(Implementer, &UListViewBaseT::HandleGenerateRow)
			.OnSelectionChanged_UObject(Implementer, &UListViewBaseT::HandleSelectionChanged)
```            

## SLATE_ATTRIBUTE 属性构造宏
该宏用来在FArguments里构造属性，支持以下几种方式，包括：

- 直接设置值
- 静态函数（Static）
- Lambda表达式（Lambda）
- 原始指针（Raw）
- 共享指针（SP）
- UObject方法（UObject）

### 解析

```cpp
SLATE_ATTRIBUTE( float, ItemHeight )
```

展开后, 新增的属性以下滑线开头。

```cpp
		TAttribute<float> _ItemHeight;

		WidgetArgsType& ItemHeight(TAttribute<float> InAttribute)
		{
			_ItemHeight = MoveTemp(InAttribute);
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <typename... VarTypes>
		WidgetArgsType&
		ItemHeight_Static(TIdentity_T<typename TAttribute<float>::FGetter::template TFuncPtr<VarTypes...>> InFunc, VarTypes... Vars)
		{
			_ItemHeight = TAttribute<float>::Create(TAttribute<float>::FGetter::CreateStatic(InFunc, Vars...));
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		WidgetArgsType& ItemHeight_Lambda(TFunction<float(void)>&& InFunctor)
		{
			_ItemHeight = TAttribute<float>::Create(Forward<TFunction<float(void)>>(InFunctor));
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& ItemHeight_Raw(UserClass* InUserObject, typename TAttribute<float>::FGetter::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_ItemHeight = TAttribute<float>::Create(TAttribute<float>::FGetter::CreateRaw(InUserObject, InFunc, Vars...));
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& ItemHeight(TSharedRef<UserClass> InUserObjectRef, typename TAttribute<float>::FGetter::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_ItemHeight = TAttribute<float>::Create(TAttribute<float>::FGetter::CreateSP(InUserObjectRef, InFunc, Vars...));
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& ItemHeight(UserClass* InUserObject, typename TAttribute<float>::FGetter::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_ItemHeight = TAttribute<float>::Create(TAttribute<float>::FGetter::CreateSP(InUserObject, InFunc, Vars...));
			return static_cast<WidgetArgsType*>(this)->Me();
		}

		template <class UserClass, typename... VarTypes>
		WidgetArgsType& ItemHeight_UObject(UserClass* InUserObject, typename TAttribute<float>::FGetter::template TConstMethodPtr<UserClass, VarTypes...> InFunc, VarTypes... Vars)
		{
			_ItemHeight = TAttribute<float>::Create(TAttribute<float>::FGetter::CreateUObject(InUserObject, InFunc, Vars...));
			return static_cast<WidgetArgsType*>(this)->Me();
		}
```        
