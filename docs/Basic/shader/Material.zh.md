 Title:Material
comments:ture

材质函数里画圈圈的几种方式

---

## 坐标系
根据喜好，选择你的坐标系

### 简单坐标系
普通好用，节点少，（-1，-1）在右上角，和书本上的不同有点反直觉，但习惯就好
![alt text](../../assets/images/Material_image-1.png)

### 创建标准坐标系
标准坐标系多了两个步骤，旋转 和交换 XY轴，虽然多了两条指令，但好的坐标系有助于理解
![](../../assets/images/Material_image.png)

## 画圆

### lerp 一个
距离场作为比例，对0和-1 插值
![alt text](../../assets/images/Material_image-2.png)

### 减了再乘
小于0.8都是负数，全黑。用乘法控制边缘，只越大越锐利
![alt text](../../assets/images/Material_image-3.png)

### RadialGradientExponential
使用内置函数，画普通圆用这个不推荐，计算量相对大，上面都是47个指令，而这个要51个。它能生成棉花糖一样的圆
![RadialGradientExponential](../../assets/images/Material_image-4.png)

内部实现也很复杂，不是特别需要这种效果，没必要使用它
![alt text](../../assets/images/Material_image-5.png)

### SphereGradient
内置函数SphereGradient球形渐变的圆，实现类型下图，利用圆方程实现平滑过渡的效果，普通画圆依然不建议使用
![alt text](../../assets/images/Material_image-6.png)

### smoothstep
推荐，用它画的圆是最简单的，max =min 就不用处理渐变值，输出值只有纯粹的0-1。值得一提的是，min 和 max对调的话，会反向。不过要方向最好用1-x
![alt text](../../assets/images/Material_image-9.png)

## 画圈
综上所述，使用最简的画出大圆，再画小圆，就可以画出圈的

### 相乘
两圆，一正一反，重叠的部分是正数，相乘向上取整
![alt text](../../assets/images/Material_image-7.png)

### dot
两圆点乘
dot 范围-1 到 1，重叠部分越相似，越接近1
![alt text](../../assets/images/Material_image-8.png)

### 相减
smoothstep 输出纯粹的0和1，非常棒
![alt text](../../assets/images/Material_image-10.png)

## 动画
这里用周期时间驱动
![alt text](../../assets/images/Material_image-11.png)
atan2的取值范围是
$\left[ -\pi,\pi \right]$
这里有个妙处，就是除以2π 和 用frac取小数。之所以除以2π不是π是因为：

- 除以2π范围变成$\left[ -0.5,0.5 \right]$
- frac 对负数的处理是 1-x,比如-0.4，取小数部分0.4，然后1-0.4=0.6
- 由于这frac操作值继续上升，直到1, 于是就可以完整走完一圈。  



### 简单结合

 ![alt text](../../assets/images/Material_image-12.png)


 
