---
title:  Multi section Montage Anim Notify Not Fire In Client
comments: true
---


在多人游戏里，montage动画如果有定义了多个section，如果是服务端在gameplay ability 里面触发该动画，那么只有第一section里面的动画notify 会发送到 client，其他section的 的 notify 只会 在 server 调用，我认为这是一个引擎内部的bug。
![alt text](../../assets/images/MontageSection_image-2.webp)
上图调试结果显示，grab只在server执行，而Release是正常的。

![alt text](../../assets/images/MontageSection_image.webp)

如图，由于资源提供的动画序列顺序不太对，于是是用section 自定义了播放序列：先播放Grab 再播放Release，表现效果在server 是正常的，在client 无法触发 grab下面的 anim notify。

 由于是引擎的bug，一时半会儿无法解决。
 - 要么打回blender 重新导出顺序符合游戏要求的序列，不熟悉放弃了。
 - 删掉 section，复制2份该动画序列，裁剪成两部分，在montage里重新拼接

 复制裁剪拼接确实可以实现想要的效果，但是裁切的地方并不精确，容易跳帧：
 ![alt text](../../assets/images/MontageSection_image-1.webp)
 如图，在第8帧切一刀，分成两部分，但手动切出来的两部分并不是完美贴合。

 如果有人知道更好的办法，请请留言告诉我，谢谢。
 