title:Modeling with Blender
comments:true


## 问题合集

---

### MMD 角色的模型 在虚幻展现的似乎，面部有细微的凹凸不平，坑坑洼洼，需要在blender里修复。

参考：

1. [Blender角色模型脸部凹凸不平？教你Blender修改傻瓜式修改脸部法向使其平面化！](https://www.aplaybox.com/article/details/998609384)
1. [从 Blender 导出 FBX 模型到 UE5 的设置小贴士](https://juejin.cn/post/7150683086059995150)

步骤：

1. 参考上述链接，用球面传递拐面修改器的方式，影响角色面部的法向信息。其中的球面的细分决定精细度
1. 导出的 平滑勾选 面 和 Tangent Space 切线空间
2. 导入的虚幻Normal Import Method 中勾选 Import Normals and Tangents 选项。

---

### 法向朝向没问题，但模型着色时候，出现伪影，黑斑
1. 尝试平滑着色
2. 如果上一步不像，点击 数据，几何数据，清除自定义拆边法向数据 就可以了。（clear custom spilt normals data）
![alt text](../assets/images/blender_image.png)