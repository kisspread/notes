---
title: Rider C++调试技巧
comments: true
---
# Rider debugger 技巧

### 断点判断当前进程是服务端还是客户端,不依赖UELog：

```sh
{,,UE4Editor-Engine.dll}::GPlayInEditorContextString
{,,UnrealEditor-Engine.dll}::GPlayInEditorContextString 
```

![alt text](../../assets/images/Rider_image.png)

- 把`{,,UnrealEditor-Engine.dll}::GPlayInEditorContextString `添加到rider watch即可,以后每次能用。

- UE4用这个 `{,,UE4Editor-Engine.dll}::GPlayInEditorContextString`


### 调试 UCommandlet 命令行程序

- 命令配置： `-run=MyCommandlet`
- 等待调试: `-waitforattach`  
- [详细参考](../Debug.md)  

