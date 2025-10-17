---
title: The CommonUI Gamepad FaceButton-Bottom is already taken.
comments:  true
---

When using CommonUI, the FaceButton-Bottom is already reserved by the system to simulate a Mouse Left Click. It's quite annoying, so I dug into the code and "fixed" the issue.

---

## Custom FCommonAnalogCursor

The FCommonAnalogCursor is an InputAction pre-processor. When an input action is consumed by this pre-processor, the EnhancedInput Subsystem won't receive this input action.

I discovered that this function in FCommonAnalogCursor is intercepting our original InputAction. So, we just need to override it to prevent FCommonAnalogCursor from handling the InputAction of FaceButton-Bottom.


```cpp title='FCommonAnalogCursor.cpp'
bool FCommonAnalogCursor::IsRelevantInput(const FKeyEvent& KeyEvent) const
{
	return IsUsingGamepad() && FAnalogCursor::IsRelevantInput(KeyEvent) && (IsGameViewportInFocusPathWithoutCapture() || (KeyEvent.GetKey() == EKeys::Virtual_Accept && CanReleaseMouseCapture()));
}
```

Here is my solution: 

- Create those classes:

    ![alt text](../../assets/images/07CustomAnalogCursor_image-1.webp)

- like so:

    (UCommonUIActionRouterBase not need to manually call, the SubSystem will handle it, [Subsystem](../../Basic/C++/USubSystem.md))

    ```cpp title='UAuraUIActionRouterBase'
    #pragma once

    #include "CoreMinimal.h"
    #include "Input/CommonUIActionRouterBase.h"
    #include "AuraUIActionRouterBase.generated.h"
    UCLASS()
    class AURA_API UAuraUIActionRouterBase : public UCommonUIActionRouterBase
    {
        GENERATED_BODY()

    protected:
        virtual TSharedRef<FCommonAnalogCursor> MakeAnalogCursor() const override;

    };

    #include "AuraUIActionRouterBase.h"

    #include "AuraAnalogCursor.h"
    #include "Input/CommonAnalogCursor.h"

    TSharedRef<FCommonAnalogCursor> UAuraUIActionRouterBase::MakeAnalogCursor() const
    {
        return FCommonAnalogCursor::CreateAnalogCursor<FAuraAnalogCursor>(*this);
    }

    ```

    ```cpp title='FAuraAnalogCursor.h'
    #pragma once
    #include "Input/CommonAnalogCursor.h"

    class FAuraAnalogCursor final : public FCommonAnalogCursor
    {
        
    public:
        explicit FAuraAnalogCursor(const UCommonUIActionRouterBase& InActionRouter)
            : FCommonAnalogCursor(InActionRouter)
        {
        }

    protected:
        virtual bool IsRelevantInput(const FKeyEvent& KeyEvent) const override;

        
    };

    ```

- Only when the Active Input Mode is Menu Mode, should it simulate the Mouse Left Click.
    ![alt text](../../assets/images/07CustomAnalogCursor_image.webp)


## Other Problem

At this moment, the FaceButton-Bottom doesn't simulate a Left Mouse Click in "Game Input Mode". However, if the FaceButton-Bottom doesn't handle your custom event properly, try opening the console and typing `showdebug EnhancedInput`. It's possible that some other Input-Action is overriding it, so you may need to adjust the Mapping priority. Or there could be another issue to consider. Please refer to [Priority](./01EnhancedInput.md/#commonui).

## Doc
文档还告诉我们，光标的可见性，是否居中，都可以重写这个类来自定义自己要的行为。
![alt text](../../assets/images/07CustomAnalogCursor_image-2.webp)