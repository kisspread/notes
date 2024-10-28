title: Common UI
comments:true

### UcommonGroupBase

当只有一个子widget的时候，会默认调用“选中”方法。在219行

（默认没有声音）

所以第一个add进来的widget，默认是一定会选中的，触发不满足 相关条件。

但这个时机通常不太好，建议 bSelectedRequired 为 false, 然后自己手动调用选中。


![alt text](../assets/images/commonui_image.png)