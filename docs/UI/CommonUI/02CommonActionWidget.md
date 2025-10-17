---
title: How to Use CommonActionWidget
comments:  true
---

## Support for Held Progress Animation
I have been trying to make it work without success, but after debugging layer by layer, I finally found the reason.

- Make sure that "held" and "UIHold Data" are configured correctly.
    ![alt text](../../assets/images/CommonActionWidget_image.webp)
- Only actions with trigger types that support "held" can bind to the "held" action.

    ```cpp
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
        }
    ```
    Otherwise, the progress image used for the animation will be hidden.
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
    Therefore, open the corresponding InputAction and add support for "Hold":
    ![alt text](../../assets/images/CommonActionWidget_image-1.webp)