title:CommonActionWidget Usage
comments:true

## 支持 held progress 动画
一直没成功，一层层调试，找到了原因。

- require held 和  UIHold Data配置正确
    ![alt text](../../assets/images/CommonActionWidget_image.png)
- 必须是支持 hold 类型的trigger 的action 才支持 绑定 held

    ``` cpp
        bool UCommonActionWidget::IsHeldAction() const
        {
            if (EnhancedInputAction && CommonUI::IsEnhancedInputSupportEnabled())
            {
                for (const TObjectPtr<UInputTrigger>& Trigger : EnhancedInputAction->Triggers)
                {
                    if (EnumHasAnyFlags(Trigger->GetSupportedTriggerEvents(), ETriggerEventsSupported::Ongoing))
                    {
                        return true;
                    }
                }

                return false;
            }
    ```
    否则，用来放动画的progress image 会被隐藏
    ```
            if (IsHeldAction())
                        {
                            MyProgressImage->SetVisibility(EVisibility::SelfHitTestInvisible);
                        }
                        else
                        {
                            MyProgressImage->SetVisibility(EVisibility::Collapsed);
                        }
    ```
    所以，打开 对应的InputAction, 增加对Hold的支持：
    ![alt text](../../assets/images/CommonActionWidget_image-1.png)
    