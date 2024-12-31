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