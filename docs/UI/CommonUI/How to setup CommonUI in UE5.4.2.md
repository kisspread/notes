Title:How to Setup CommonUI in UE5.4.2
commenst: true

So far, the documentation for commonUI is very basic and doesn't clearly tell us how to configure it correctly. It took me a long time to figure it out, so I'm going to record the main process here.

---

### Concept of Activation
An Activatable Widget is an important concept in Common UI. It can be simply understood that once activated, it will be displayed, and deactivated means hidden. Additionally:

  - Once an activatable widget is activated, it will take over the Input Action, similar to manually calling `setInputMode` in UE4. This can cause conflicts, and it is not recommended to use the old method in CommonUI. I have tried this, and it led to various issues with Mouse Capture.
  - Taking over input action is a thoughtful design because many games need to show the mouse once the menu is displayed. We only need to override GetDesiredInputConfig to decide the various behaviors of the mouse and controls.
  - Therefore, we need to configure the default InputAction of the game on a resident HUD and abandon the use of UE4's `setInputMode`.

### Concept of Stack
Similar to mobile apps, the stack in CommonUI is the effect of stacking interfaces layer by layer as you enter them, and you can go back layer by layer through the back button.

 - You can create this UCommonActivatableWidgetStack in Blueprint or C++ and set the width and height to fill the screen.
 - With this stack, the activatable widget can be added into it. Once added, it will be displayed immediately, similar to Android's startActivity.
 - You can use a RootLayout to manage the stack. A RootLayout can have multiple stacks. The Lyra project uses two: MenuStack and GameStack.
 - The Game Stack is the game's resident HUD.
 - The Menu Stack is the stack into which various menus are added.
 - Pay attention to the stacking order between stacks. It's best to place the Menu above the Game.
 - There is no good communication method between stacks. For example, when the Menu Stack is empty, meaning no menus are displayed on the screen, I want to notify the activated widget in the GameStack to react, such as playing a restore animation. CommonUI does not provide a ready-made method for this. If you know how, please be sure to let me know.
 - Code example: You can use Blueprint, but I find C++ more convenient. I also did some hack operations to notify the default widget in the GameStack that the MenuStack has been emptied.
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
---

### Prerequisites
some config if not setup correctly, it will not work.

- Player Controller: Make sure "Block Input" is unchecked.
![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image.png>)
- Create a HUD or Menu widget derived from CommonActivatable Widget.
- Ensure that your HUD or Menu Widget set "supports Activation Focus" to **true**.
  ![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-1.png>)
- Create a specific UI InputConfig for your menu widget. Avoid using `Setup Input Mode Game & UI` as it is not suitable for CommonUI!
  ![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-2.png>)
- If your game is a TopDown Game and you want to retain Mouse Capture, in your HUD Widget, set the input config Mouse Capture Mode to "Capture Permanently including Initial Mouse Down." Otherwise, your game will require a double-click to trigger a single mouse click.
  ![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-3.png>)


### Enhanced Input and Automatic Button Icon Display

- In `Game->CommonInputSetting`, add your platform icon data and set "Enable Enhanced Input Support" to true.

    ![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-4.png>)

- Create a `CommonBaseButton`, place a `CommonActionWidget` inside it, and rename it to `InputActionWidget`. **It must be named this way, otherwise it will not display.**

- Configure the `CommonBaseButton` input action, setting an `InputAction` for it. Here, an 'E' key is set, and the `CommonActionWidget` inside the button will display the corresponding icon.
  ![image](<../../assets/images/How to setup CommonUI in UE5.4.2_image-5.png>)

- If no `InputAction` is specified for the above `CommonBaseButton`, the system will automatically set the relevant action icon based on the platform when it is in focus. For example, the Xbox's down button icon is usually the gamepad face button down, so it will display an 'A' icon.
- This 'A' icon can be specified through configuring `CommonUIInputData`.
  ![image](<../../assets/images/How to setup CommonUI in UE5.4.2.zh_image.png>)
- You can change the `ForwardAction` from the 'A' button to the 'X' button. However, this only modifies the icon, as the platform still passes the 'A' button's `InputAction`. Visually, it will show the 'X' icon, but the key binding remains 'A'. I can only consider this a bug. If you know the correct approach, please let me know.

### Gamepad Navigation Configuration
When using a gamepad, you need to navigate through the menu using the gamepad's directional buttons (up, down, left, right) so that players can select which button to interact with. 

You only need to override `GetDesiredFocusTarget` to let the system know which Common BaseButton should be focused by default.

- This only works for gamepads; keyboard navigation is very cumbersome now, presumably due to the mouse capture. The Lyra project disables keyboard navigation. If you know simeple way to setup keyboard navigation , please let me konw. :)

 ![alt text](<../../assets/images/How to setup CommonUI in UE5.4.2.zh_image-1.png>)
