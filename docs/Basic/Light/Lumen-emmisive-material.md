---
title: UE5 Lumen 基础打光
comments: true
---

# UE5 Lumen 基础打光

记录打光需要的一些最基础的参数设置

## 打光三件套

- Post-Processing Volume
- Directional Light
- Sky Light

### Post-Processing Volume 设置
首先要关掉曝光自适应，它是模拟人眼自动调节曝光，但这个东西非常烦人，搜索Ev，Min Ev100，Max Ev100，都设置为0；数值越大越暗。关掉之后后续的打光更好调节。

### Directional Light 设置
就是模拟月光，日光
- Intensity：光照强度，默认10 lux 是大中午，小于 lux 可以模拟月光
- Light Color：光照颜色, 默认白色即可
- Use Temperature：色温，最好开启，比颜色好用，模拟各种氛围，地下洞穴可以调冷色调，沙漠可以调暖色调。

### Sky Light 设置
主要用于照亮材质的默认颜色，默认创建的天光会开启 real time capture，如果开启，需要一个 天空球或者volumetric Cloud 作为依据。不开启，就需要配置一个Cubemap来作为光源，不同的cubemap模拟不同的天空环境。
- Intensity：天光强度，使用T_Clear Sky Cubemap 的时候，1已经很亮了；根据情况调整。
- Light Color：天光颜色，是相乘关系，通常当做色调使用，`FinalColor = CubemapColor * SkyLightColor * Intensity;`

## 可能存在的问题

### UE5 Lumen Emissive Flickering （自发光材质闪烁问题）
如果使用自发光材质，且开始了Lumen，在暗环境下会经常出现阴影闪烁，伪影等。搜集了一些解决办法：

- 关闭自发光对环境的影响
这是针对Mesh Component的设置，在Mesh Component的Details 关闭Affect Distance Field Lighting/Dynamic Indirect Lighting

- 调整材质的自发光强度
如果关闭了Affect Distance Field Lighting/Dynamic Indirect Lighting，发现对环境还是有影响，是因为材质的自发光真的太强了，调低即可。

- 调整后处理的Final Gather Quality
如果还有阴影问题，可以调整后处理的Final Gather Quality，这个值越高越好，但会增加计算开销。我测试5左右就适合我的场景，看情况可以调高。
![alt text](../../assets/images/Lumen-emmisive-material_image.webp)

- Temporal AA 关闭
TAA 可能加剧 emissive materials 的 flickering, 尝试其他anti-aliasing方法
