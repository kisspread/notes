---
title: powershell commands
comments:  true
---

### PowerShell 

#### count code lines


```bash title="files count"
(Get-ChildItem -Recurse -Include *.cpp,*.h | Measure-Object).Count
```

```bash title="lines count"
(Get-ChildItem -Recurse -Include *.cs, *.py, *.cpp,*.h | Get-Content | Measure-Object -Line).Lines
```

#### 打开环境变量UI

`rundll32.exe sysdm.cpl,EditEnvironmentVariables`

#### 设置用户级环境变量
```sh
[Environment]::SetEnvironmentVariable("MyVariable", "MyValue", "User")
```

#### 设置系统级环境变量

```sh
[Environment]::SetEnvironmentVariable("MyVariable", "MyValue", "Machine")
```


#### 创建快捷方式

不跨分区支持

```sh
New-Item -ItemType SymbolicLink -Path "X:\NewLinkFolder" -Target "X:\YourExistingFolder"
```

or 

跨分区支持/D, 性能较差	

```sh
cmd /c mklink /D "X:\NewLinkFolder" "X:\YourExistingFolder"
```

不跨分区支持/J, 性能较好

```sh
cmd /c mklink /J "X:\NewLinkFolder" "X:\YourExistingFolder"
```