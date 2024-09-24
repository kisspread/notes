title: powershell commands
comments:true


### PowerShell 

#### count code lines


```bash title="files count"
(Get-ChildItem -Recurse -Include *.cpp,*.h | Measure-Object).Count
```

```bash title="lines count"
(Get-ChildItem -Recurse -Include *.cs, *.py, *.cpp,*.h | Get-Content | Measure-Object -Line).Lines
```

