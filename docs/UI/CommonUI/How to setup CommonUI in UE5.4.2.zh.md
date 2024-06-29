Title:How to Setup CommonUI in UE5.4.2 结合增强输入
comments:true

目前为止，commonUI的文档非常简陋，并未明确告诉我们如何正确配置。我花了好长时间才搞明白，在这里把主要过程记录一下。

---

### Activate 的概念
Activatable Widget是 Common UI 的重要概念。 这里可以简单地理解为激活了就会显示，deactivate就是隐藏。还有：

  - activate widget一旦Activated,就会接管Input Action，类似 UE4里手动调用`setInputMode`，并且这是冲突的，不推荐在CommonUI里使用旧的方式，我试过会，这导致Mouse Capture 出现各种问题。
  - 接管 inputAction是一个贴心的设计，因为很多游戏一旦显示菜单，就需要显示鼠标。我们只需要重写GetDesiredInputConfig就可以决定鼠标和控制的各种行为。
  - 所以，我们需要在常驻的HUD上面配置游戏的默认InputAction，而放弃使用UE4的`setInputMode`
### stack的概念
类比手机app，commonUI的stack就是界面一层层进入后堆叠起来的效果，可以通过返回键一层层地回退。

 - 可以在蓝图或者CPP创建这个UCommonActivatableWidgetStack，并设置宽高沾满屏幕
 - 有了这个stack，activatable widget 就可以 Add到这里面来。运行时一旦add进来就会立刻显示，类似Android的startActivity
 - 可以用一个RootLayout来管理stak，一个RootLayout可以有多个stack。Lyra项目的用到了2个: MenuStack和GameStack
 - Game Stack 就是游戏常驻的HUD
 - Menu Stack 是给各种MenuAdd进来的Stack
 - 要注意 Stack之间堆叠的顺序，Menu最好在Game的上面。
 - Stack之间没有比较好的通信方式，比如当Menu Stack已经清空了，就是没有任何Menu显示在屏幕的时候，我想通知一下GameStack里面的Activated Widget做出一些反应，比如播放还原动画，CommonUI并没有提供现成方法。如果你知道，请务必告诉我。
 - 代码示例，可以用蓝图。但我觉得C++更方便，而且我做了一些hack操作，通知GameStack的默认widget MenuStack已经清空了
    ``` cpp title="YouHUD.cpp"
    void YouHUD::InitHudWidgets(UAttributeSet* AS, UAbilitySystemComponent* ASC, APlayerState* PS, APlayerController* PC)
    {
        checkf(OverlayWidgetClass, TEXT("please initial a OverlayWidgetClass"));
        checkf(OverLayWidgetControllerClass, TEXT("please initial a WidgetControllerClass"));
        checkf(MenuWidgetControllerClass, TEXT("please initial a MenuWidgetControllerClass"));
        UUserWidget* RootLayout = CreateWidget<UUserWidget>(GetWorld(), UCommonUserWidget::StaticClass());

        UOverlay* OverLay = RootLayout->WidgetTree->ConstructWidget<UOverlay>(UOverlay::StaticClass(), TEXT("Overlay"));
        // TSharedRef<SOverlay> RootLayout = SNew(SOverlay);
        RootLayout->WidgetTree->RootWidget = OverLay;

        GameLayerStack = RootLayout->WidgetTree->ConstructWidget<UCommonActivatableWidgetStack>(UCommonActivatableWidgetStack::StaticClass(), TEXT("GameLayerStack"));
        MenuLayerStack = RootLayout->WidgetTree->ConstructWidget<UCommonActivatableWidgetStack>(UCommonActivatableWidgetStack::StaticClass(), TEXT("MenuLayerStack"));


        OverLay->AddChild(GameLayerStack);
        OverLay->AddChild(MenuLayerStack);

        // set horizontal alignment and vertical alignment
        const auto GameBoxSlot = Cast<UOverlaySlot>(GameLayerStack->Slot);
        GameBoxSlot->SetHorizontalAlignment(HAlign_Fill);
        GameBoxSlot->SetVerticalAlignment(VAlign_Fill);

        const auto MenuBoxSlot = Cast<UOverlaySlot>(MenuLayerStack->Slot);
        MenuBoxSlot->SetHorizontalAlignment(HAlign_Fill);
        MenuBoxSlot->SetVerticalAlignment(VAlign_Fill);

        RootLayout->AddToViewport();

        // set up overlay widget
        OverlayWidget = CreateWidget<UAuraActivatableWidget>(GetWorld(), OverlayWidgetClass);
        UAuraWidgetController* OverLayWidController = GetWidgetController<UAuraOverlayWidgetController>(FAuraWidgetControllerParma(AS, ASC, PS, PC));
        OverlayWidget->SetWidgetController(OverLayWidController);
        // OverlayWidget->AddToViewport();
        GameLayerStack->AddWidgetInstance(*OverlayWidget);

        MenuLayerStack->OnDisplayedWidgetChanged().AddLambda([this](UCommonActivatableWidget* DisplayedWidget)
        {
            if (DisplayedWidget == nullptr)
            {
                OverlayWidget->OnMenuEmpty();
            }
        });

        // set up menu widget
        OverLayWidController->BroadcastInitialValue();
    }
    ```

### 一些先决条件
如果未设置，会导致失败

- 参考官方文档 [开启commonUI](https://dev.epicgames.com/documentation/en-us/unreal-engine/common-ui-quickstart-guide-for-unreal-engine)

- 玩家控制器：确保“block input”未被选中。
![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image.png>)
- 创建一个从CommonActivatable Widget派生的HUD或Menu Widget。
- 确保您的HUD或Menu Widget将“Support Activation Focus”设置为**true**。
![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-1.png>)
- 为Menu Widget创建特定的UI输入配置。避免使用`设置输入模式为游戏和UI`，因为这对CommonUI不适用！
![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-2.png>)
- 如果您的游戏是Top Down 类型的游戏，并且希望保留鼠标捕获，请在HUD widget中将InputConfig的鼠标捕获模式设置为“永久捕获，包括初始鼠标按下”。否则，您的游戏将需要双击才能触发单击鼠标。
![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-3.png>)

### 增强输入和按钮自动显示图标

- 在Game->CommonInputSetting中，添加您的平台图标数据。并将“启用增强输入支持”设置为true。

  ![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-4.png>)

- 创建一个CommonBaseButton，在里面放置一个CommonActionWidget，**并且重命名为InputActionWidget，必须是这个名字，否则不显示。**

- 配置CommonBaseButton输入操作，给他设置一个InputAction。这里设置了按键E，按钮里的CommonActionWidget就会显示对应的图标。
![alt text](<../../assets/images/How to setup CommonUI in UE5.4.2_image-5.png>)

- 不给上面的CommonBaseButton指定InputAction，系统就会自动在它**focus**的时候，根据平台自动给它设置相关操作的图标。比如Xbox的按下图标通常是gamepad face button down, 就会显示一个A图标
- 这个A的图标可以通过配置CommonUIInputData来指定
  ![alt text](<../../assets/images/How to setup CommonUI in UE5.4.2.zh_image.png>)
- 可以把ForwardAction 从A键 改成 X键。但这只能修改图标，因为平台的传递过来的还是A键的InputAction。表现上看就是，显示的图标是X，但按键绑定的依然是A。我只能把它当作一个bug，如果你知道正确做法，请告诉我。

### 手柄导航配置

当使用手柄的时候，菜单弹出来后需要用手柄的上下左右来进行导航，让玩家能够选择和哪个button进行操作。
只需重写`GetDesiredFocusTarget`，让系统知道默认哪个Common BaseButon需要focus即可。

 - 以上只针对手柄有效，键盘导航很麻烦，猜测是因为鼠标的存在。Lyra项目是禁用键盘导航的。如果你知道简单的方式，请告诉我。:)
 ![alt text](<../../assets/images/How to setup CommonUI in UE5.4.2.zh_image-1.png>)