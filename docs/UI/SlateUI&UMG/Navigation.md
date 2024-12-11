title: UMG Navigation
comments:true

---

## UMG Navigation 用法记录

键盘或手柄导航键是指在不捕获鼠标的情况下,使用键盘或手柄进行导航的功能。UE里，UMG提供了 Navigation相关的设置和方法。

- 支持focus的widget，会被 加入到 Focus Path 中。
- Focus Path 就是 键盘或手柄导航时，导航的路径。
- Widget 可以设置不同方向的导航行为，可以自定义到哪个 Widget。


### 从问题思考

Widget 是树状结构。比如 A 内部有 B，C，D。第一行是 B，C。 第二行是 D。也就是D在下方。

B内部有，B1，B2，B3，C内部有 C1，C2

此时，focus在 B2上面，此时，按下导航键“下（down）”，focus会去到哪个widget？

数据结构

```code
A
├── B (第一行)
│   ├── B1
│   ├── B2 (当前focus)
│   └── B3
├── C (第一行)
│   ├── C1
│   └── C2
└── D (第二行)
```


这个问题，答案其实是不确定的，因为没有说明Widget是什么类型，像STileView内部是重写了 `	virtual FNavigationReply OnNavigation(const FGeometry& MyGeometry, const FNavigationEvent& InNavigationEvent) override` 方法。

只考虑默认导航规则的话，逻辑是这样的, 核心逻辑很简单，就是几何运算，判断和导航方向最近的那个widget，（投影占比最大的）就是导航的目标。


## Usage

### 在Widget上设置导航规则

```cpp
// --------------SetNavigationRuleCustom

// 示例1：循环导航
Widget->SetNavigationRuleCustom(EUINavigation::Down, FCustomWidgetNavigationDelegate::CreateLambda(
    [](EUINavigation Navigation) -> UWidget* {
        // 返回第一行的Widget
        return FirstRowWidget;
    }
));

// 示例2：条件导航
Widget->SetNavigationRuleCustom(EUINavigation::Down, FCustomWidgetNavigationDelegate::CreateLambda(
    [](EUINavigation Navigation) -> UWidget* {
        // 根据某些条件决定导航目标
        if (SomeCondition) {
            return WidgetA;
        }
        return WidgetB;
    }
));

// --------------SetNavigationRuleCustomBoundary

// 示例2：循环列表
ListWidget->SetNavigationRuleCustomBoundary(EUINavigation::Down, FCustomWidgetNavigationDelegate::CreateLambda(
    [](EUINavigation Navigation) -> UWidget* {
        // 到达列表底部时回到顶部
        return GetFirstListItem();
    }
));

// 示例3：分页导航
PageWidget->SetNavigationRuleCustomBoundary(EUINavigation::Right, FCustomWidgetNavigationDelegate::CreateLambda(
    [](EUINavigation Navigation) -> UWidget* {
        // 在页面边界处理翻页
        if (HasNextPage()) {
            SwitchToNextPage();
            return GetFirstWidgetOfNextPage();
        }
        return nullptr; // 保持在当前位置
    }
));
``` 

### 或者重写SWidget的OnNavigation

参考STileView 的部分代码

```cpp
virtual FNavigationReply OnNavigation(const FGeometry& MyGeometry, const FNavigationEvent& InNavigationEvent) override
{
    if (this->HasValidItemsSource() && this->bHandleDirectionalNavigation && (this->bHandleGamepadEvents || InNavigationEvent.GetNavigationGenesis() != ENavigationGenesis::Controller))
    {
        const TArrayView<const ItemType> ItemsSourceRef = this->GetItems();
        const int32 NumItemsPerLine = GetNumItemsPerLine();
        const int32 CurSelectionIndex = (!TListTypeTraits<ItemType>::IsPtrValid(SelectorItem)) ? -1 : ItemsSourceRef.Find(TListTypeTraits<ItemType>::NullableItemTypeConvertToItemType(SelectorItem));
        int32 AttemptSelectIndex = -1;

        // 根据方向计算目标索引
        if ((Orientation == Orient_Vertical && NavType == EUINavigation::Up) ||
            (Orientation == Orient_Horizontal && NavType == EUINavigation::Left))
        {
            // 向上/向左导航
            AttemptSelectIndex = CurSelectionIndex - NumItemsPerLine;
        }
        else if ((Orientation == Orient_Vertical && NavType == EUINavigation::Down) ||
                 (Orientation == Orient_Horizontal && NavType == EUINavigation::Right))
        {
            // 向下/向右导航
            AttemptSelectIndex = CurSelectionIndex + NumItemsPerLine;
        }
    }
}
```

-  bHandleDirectionalNavigation 只能继承后修改默认值


### ListView Navigation的一些注意事项

常见问题：

- ListView 设置为focusable, 就会自动支持ItemWidget的导航， ItemWidget 不设置 focus无所谓。
- 但修改ItemWidget的导航导航规则，是有效的。比如循环导航需要获得最后一个ItemWidget，然后设置导航到第一个ItemWidget。
- 如果ItemWidget 内部 也有focusable的widget（称之SubWidget吧），那么这些SubWidget的导航规则，会出现不在预期的行为。
- 不在预期的情况是ListView 重写了 OnNavigation 导致的，比如按下左边，并不会在Subwidget之间导航，而会去到下一个ItemWidget。只能重写 OnNavigation，然后自己实现导航逻辑。
- 也就是导航事件，会被父布局的 OnNavigation 事件一层层地拦截，FNavigationReply 的返回值，会决定导航的结果。
- 默认实现下，ListView 导航去到最后一个ItemWidget的时候，如果继续往后面导航，返回的FNavigationReply不拦截它，可以成功逃出ListView，导致ListView失去焦点。


还有一个导航被 “空的ListView”锁定的情况：
    - 如果ListView 获得焦点后，清空List View，看起来好像被隐藏了一样。
    - 此时，导航就被ListView锁定了，上下左右都无法导航。
    - 可以手动设置其他Widget为当前焦点来解决。