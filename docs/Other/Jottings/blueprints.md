---
title: 草稿
comments:  true
---

### 编辑器地图里的Actor，数组无法add元素

开发编辑器功能时，在编辑器地图里的Actor，如果属性改变，Actor会重写调用构造函数。这会导致私有变量的值被重置，比如进行数组的add操作，会发现元素根本无法添加，因为一直在刷新，重置。

正确的做法是：
把变量暴露出来，公开，公开的变量不会被重置，这样就能正常add了。





## 巫师4 大世界带给UE5.6的优化总结

![alt text](../../assets/images/blueprints_image-1.png)