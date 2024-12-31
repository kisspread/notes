---
Title: 编辑器BUG
comments: true
---
 

### 物理资产出现一个锁头标志

有锁头图标的，是kinematic。
没有的，是simulated 和 default

5.4.4版本有bug，修改物理类型后，锁头图标不消失，也不添加。
这时，按下 alt + H，再按 alt + G，才会刷新出来。或者保存后，重新打开资产。
![alt text](../../assets/images/physisc_image.png)
 

