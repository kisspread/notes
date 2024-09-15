title: Nesting actor components isn't exactly straightforward.
comments:true

---


### Nesting actor components isn't exactly straightforward.
 

When I tried nesting one component inside another, I hit this error: 
> Template Mismatch during attachment. Attaching instanced component to template component.

Here's a snippet of the code:
```cpp
UMySpringArmComponent::UCollisionCameraArmComponent()
{
    PrimaryComponentTick.bCanEverTick = true;
    CameraCollisionBox = CreateDefaultSubobject<UBoxComponent>("CameraCollisionBox");
    CameraCollisionBox->SetupAttachment(this, SocketName);  // 'this' is the CDO of the class, not the instance
}
```
I just want to add a box component to the spring arm component, but this code doesn't work.

The problem is with `SetupAttachment(this, SocketName)`. Here, `this` refers to the CDO in the constructor, not the instance, causing the error.

Naturally, I thought of creating a method to let the actor perform `CameraCollisionBox->SetupAttachment(this, SocketName);`
```cpp
void UMySpringArmComponent::SetupCameraCollisionBox()
{
    CameraCollisionBox->SetupAttachment(this, SocketName);
}
void AMyCharacter::AMyCharacter()
{
    Super::AMyCharacter();
    MySpringArmComponent = CreateDefaultSubobject<UMySpringArmComponent>("MySpringArmComponent");
    // Here, the spring arm component is an instance, so the nesting works.
    MySpringArmComponent->SetupCameraCollisionBox();
}
```

This allows the nested component to be created normally. However, in the Unreal component window, you can't drag this component into the Event Graph because it doesn't have a name. When you try, it throws an error saying "cannot find corresponding variable."

I suspect this error happens because `CreateDefaultSubobject` isn't performed by the actor, leading to this issue. The `CreateDefaultSubobject` process likely generates metadata stored internally, allowing the blueprint editor to find the variable by name. But with the nesting method, the metadata isn't recorded by the current actor (CDO), so the variable can't be found via drag-and-drop.

#### Solution:

Let the actor execute `CreateDefaultSubobject` to ensure the metadata is recorded, allowing for drag-and-drop.

```cpp
void AMyCharacter::AMyCharacter()
{
    Super::AMyCharacter();
    MySpringArmComponent = CreateDefaultSubobject<UMySpringArmComponent>("MySpringArmComponent");
    MyCollisonBox = CreateDefaultSubobject<UBoxComponent>("MyCollisonBox");
    MySpringArmComponent->SetupCameraCollisionBox(MyCollisonBox);
}
```

(The reason for nesting components is to organize highly related code together. But in reality, it's not always perfect. MyCollisonBox needs to be created outside and then passed in.)

