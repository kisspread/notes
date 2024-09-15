title:嵌套actor component 并没有那么容易
comments:true


### 嵌套actor component 并没有那么容易.

当我尝试在component中嵌套另一个component的时候，发现报错：
> Template Mismatch during attachment. Attaching instanced component to template component.

代码样例:
```cpp
UMySpringArmComponent::UCollisionCameraArmComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
 	CameraCollisionBox = CreateDefaultSubobject<UBoxComponent>("CameraCollisionBox");
	CameraCollisionBox->SetupAttachment(this, SocketName);	// the this is CDO of the class, not the instance
}
```
I just want to add a box component to the spring arm component. but this code doesn't work.


问题出在SetupAttachment的this这里，this在这里的构造函数中，是CDO，不是实例，所以这里不能用this。于是又上面的报错。

于是，很自然就想到，我们可以写个方法，让actor来执行 CameraCollisionBox->SetupAttachment(this, SocketName);
```cpp
void UMySpringArmComponent::SetupCameraCollisionBox()
{
    CameraCollisionBox->SetupAttachment(this, SocketName);
}
void AMyCharacter::AMyCharacter()
{
        Super::AMyCharacter();
        MySpringArmComponent = CreateDefaultSubobject<UMySpringArmComponent>("MySpringArmComponent");
        //在这里，sprintarmcomponent 是实例了，所以成功嵌套。
        MySpringArmComponent->SetupCameraCollisionBox();
}
```

这样能够正常创建出嵌套的component，但是在虚幻的component窗口中，这个component 无法通过 拖拽的方式 放入 Event Graph 里，因为它居然没有名字。拖动时显示错误“cannot find corresponding variable”

我大概能猜到，这个错误是因为 CreateDefaultSubobject 不是actor来执行，所以导致了这个错误。CreateDefaultSubobject的过程应该会生成相关元信息存储在内部，所以蓝图编辑器可以靠名字找到这个变量，但是通过嵌套的方式，这个变量的元数据信息没有被当前actor（CDO）记录下来，所以无法通过拖拽的方式找到这个变量。

#### 解决办法：

就是让actor来执行 CreateDefaultSubobject，这样元数据信息就记录下来了， 就可以拖拽了。

```cpp
void AMyCharacter::AMyCharacter()
{
    Super::AMyCharacter();
    MySpringArmComponent = CreateDefaultSubobject<UMySpringArmComponent>("MySpringArmComponent");
    MyCollisonBox = CreateDefaultSubobject<UBoxComponent>("MyCollisonBox");
    MySpringArmComponent->SetupCameraCollisionBox(MyCollisonBox);
}
```

（我们之所以用嵌套的方式来整理component，目的是为了把高度关联的代码整合在一起。但现实就是不那么完美,MyCollisonBox需要放在外面创建，然后传递进去）


----
