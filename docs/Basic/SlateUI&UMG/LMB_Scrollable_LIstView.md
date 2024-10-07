title: UE5 Make Left Mouse Button Enable dragging to scroll the ListView.
comments:true

## 从根源上让UE5支持鼠标左键来滚动ListView

看了很多文章，想要让List View支持左键拖动来滚动列表，需要在项目设置里,**勾选UseMouseForTouch** ,也就是鼠标模拟触摸。

但这会改变非常多的默认行为, 导致很多其他行为不是预期内的.

不修改源码的情况下， 继承大法应该能做到。

### 成果 TL;DR

代码不多，200多行。

[SourceCode](https://github.com/kisspread/notes/blob/main/samplecode/LeftClickToScroll/ULeftClickScrollListView.h) 

### 分析

- **默认支持右键滚动**

    虚幻默认支持右键滚动, 那么**直接把右键滚动的的条件改成左键**,继承一下UListView,简单改下是不是就能成功呢?

    事情不会那么简单, epic把功能做到别扭的右键上去. epic 这样做一定是有原因的.

- **让ai阅读源码**
    
    这里涉及到 slate 和 UMG， 源码非常庞大，ai给出的线索非常有限，但还是快速定位到了 默认的右键滚动关键代码：

    `FReply STableViewBase::OnMouseMove( const FGeometry& MyGeometry, const FPointerEvent& MouseEvent )`

    但ai的作用很难在这种复杂的代码里发挥，即使是sonnet也只适合简单的定位工作，让它实现左键的版本，非常容易范低级错误逻辑非常差，这可能是训练集没有针对虚幻“U++”的原因，况且虚幻的代码模板套模板，各种多继承，Slate的魔法Marco都能把ai搞傻。

- **明确目标，支持左键滚动的同时，不干扰正常的点击**
    
    阅读源码的过程中意识到，方法是重写是会影响到点击事件的传播的，所以必须理清点击事件的传播，才能正确修改。
    

### 解析

![alt text](../../assets/images/LMB_Scrollable_LIstView_image-1.png){ align=center }

#### 虚幻的事件传播

虚幻的事件传递策略有4种：
![alt text](../../assets/images/LMB_Scrollable_LIstView_image-3.png)

主要用到是 Tunnel 和 Bubble，既隧穿和和冒泡。事件都是从父控件开始的，一层层下去的过程叫做 tunnel。到达最里面后，反向传播的过程叫做 冒泡。

不会画图，借用Android的图来说明，[出处](https://proandroiddev.com/android-touch-system-part-2-common-touch-event-scenarios-a37a885f5f75)
![alt text](../../assets/images/LMB_Scrollable_LIstView_image.png)

大部分UI框架都是相似，图里左边是 tunnel，右边是 bubble。

虚幻widget里，`OnPreviewMouseButtonDown` 是 tunnel策略，`OnMouseButtonDown,up,move` 是冒泡策略。他们的返回值都是FReply，FReply主要有2种情况：

1. **Handled**：表示事件已经被处理，不再继续传播，不会被其他控件处理。
2. **Unhandled**：表示事件没有被处理，可以继续传播，被其他控件处理。

另外，经过测试。即使是 **Unhandled**, 也存在一些 **阻断传播** 的情况，这是和Android非常不一样的地方。

1. 调用了` FReply::Unhandled().CaptureMouse()` 捕获会让事件只在当前widget上生效，也就是其他控件全部不响应。（只测试了子控件，推测是全部）。
2. 调用了 `Reply.UseHighPrecisionMouseMovement(this->AsShared())` 因为它内部也调用了**CaptureMouse**，其实还是第一种。

另外，顺带研究了一下，带preview的都是tunnel 策略：

    OnPreviewKeyUp
    OnPreviewCharacterInput
    OnPreviewAnalogInputEvent

##### 调试事件

可以用 slatedebug 命令来调试，像event.start启用后， log里会显示更多的事件日志。但没有详细的使用资料，感觉并不是很好用，不如自己打log。
![alt text](../../assets/images/LMB_Scrollable_LIstView_image-4.png)

####  虚幻为何默认右键来拖动

理解了事件传播机制，快速定位相关代码位置：

主要在**SObjectTableRow.h** （子） 和 **STableViewBase.cpp** (父)

粗略阅读，进行合理猜测：

- **多选这滚动冲突**：它实现了列表选择，就像window按住shift可以多选文件这样。而多选支持拖动来进行，这里拖动就和滚动列表的功能冲突了。
- **可以解决但会让逻辑变得很复杂**：因为touch模式下，既支持多选也支持滚动，但逻辑不一样，而鼠标存在右键，干脆把逻辑写作右键里算了所以这就是现在看到的模样。

#### 明确需求，确定取舍

大概了解了缘由，虚幻左键不支持拖拽滚动列表，就是**多选导致**。这是官方取舍的结果，我们可以继承它，继续细分它的功能，取舍自己要的。

我只是想要一个列表，点击哪个就响应哪个，这种需求是非常常见的，至于多选，用于展示的列表很少需要这样的功能，完全可以舍弃。所以，继承后，只要**保留单选的能力**即可。


#### STableViewBase

STableViewBase 是底层控件，由于我用到了CommonUI, 所以继承 `public SCommonListView<ItemType>`

逻辑上，照搬右键的逻辑即可，改改即可。问题在于 是否要用OnPreviewMouseButtonDown 拦截事件传递。考虑到 子控件会处理掉消费事件，导致父控件收不到冒泡事件。
所以选择在OnPreviewMouseButtonDown 添加一些逻辑稳妥些，但不拦截，用FReply::Unhandled() 放行。

然后就是 OnMouseMove的重写，里面调用了UseHighPrecisionMouseMovement，这个会阻断事件传播，所以需要区分是点击还是滚动，move是多次调用，如果不做区分，子控件就收不到事件。表现未，必须双击，才会收到事件。

#### SObjectTableRow

这是默认的Item控件的父容器，如果是用UListView，它就是用来放UMG定义的“容器”控件。代码截图：
![alt text](../../assets/images/LMB_Scrollable_LIstView_image-5.png)
它用来EntryWidgetPool控件池的方式来构建widget，SObjectTableRow的构造参数里包含了WidgetObject，表明SObjectTableRow是WidgetObject的容器。

而这个控件的 `virtual FReply OnMouseButtonDown` 方法，会capture事件，把后续事件都锁定在 SObjectTableRow 里。
![alt text](../../assets/images/LMB_Scrollable_LIstView_image-6.png)
这将会导致，父布局的OnMouseMove不再调用。

分析：

- 如果不重写这方法，只能让 UListView 的Item Widget（就是上面提到的WidgetObject） 的 OnMouseButtonDown 返回  `FReply::Handle`，这样就不会进入这个 capture的逻辑里。
- 如果 WidgetObject返回了 `FReply::Handle`，虽然父布局有机会处理Move，能够滚动了，但原生自带的 单选功能也会同样消失。
- 为了避免这些问题，只能继承这个SObjectTableRow，重写它的捕获，同时抛弃多选的功能，保持原始的单选。

#### SCommonButtonTableRow

这个类是 SObjectTableRow 的子类，如果是使用 CommonUI，可能会继承它。但SCommonButtonTableRow内部 重写处理了一些事件逻辑，（主要由CommonButton处理），继承它有更多的工作需要进行，暂时列为todo。

### References
- [【UE·底层篇】Slate源码分析——点击事件的触发流程梳理](https://zhuanlan.zhihu.com/p/448050955)
- [【UE·UI篇】ListView使用经验总结](https://zhuanlan.zhihu.com/p/370249957)
- [ Slate介绍](https://myslate.readthedocs.io/en/latest/index.html)


  ![解析成功](../../assets/images/LMB_Scrollable_LIstView_image-2.png)