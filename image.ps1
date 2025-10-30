param(
    [Parameter(Mandatory=$true, HelpMessage="请输入要处理的图片文件或目录路径")]
    [string]$Path,
    
    [int]$MinMB = 2,
    [int]$MaxMB = 5,
    [int]$WebpQuality = 50,
    [bool]$UseLossless = $false,
    [bool]$KeepBackup = $false,
    [string]$MagickCmd = "magick",
    [int]$HeaderReadBytes = 4096
)

# 验证路径是否存在
if (-not (Test-Path $Path)) {
    Write-Error "路径不存在: $Path"
    exit 1
}

$extensions = @("*.png","*.jpg","*.jpeg")

# 确定要处理的文件列表
$filesToProcess = @()

if (Test-Path $Path -PathType Container) {
    # 如果是目录，递归获取所有图片文件
    Write-Host "处理目录: $Path" -ForegroundColor Green
    $filesToProcess = Get-ChildItem -Path $Path -Recurse -File -Include $extensions
} else {
    # 如果是单个文件，检查扩展名
    $file = Get-Item $Path
    if ($extensions -contains "*$($file.Extension)" -or $file.Extension -ieq ".webp") {
        $filesToProcess = @($file)
        Write-Host "处理单个文件: $Path" -ForegroundColor Green
    } else {
        Write-Error "不支持的文件类型: $($file.Extension)"
        exit 1
    }
}

if ($filesToProcess.Count -eq 0) {
    Write-Host "没有找到可处理的图片文件" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 $($filesToProcess.Count) 个文件待处理" -ForegroundColor Green

$filesToProcess | ForEach-Object {
    $file = $_
    try {
        if ($file.Extension -ieq ".webp") { 
            Write-Host "跳过 WebP 文件: $($file.FullName)" -ForegroundColor Yellow
            return 
        }

        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        # 取消注释下面这行来启用文件大小过滤
        # if ($sizeMB -lt $MinMB -or $sizeMB -gt $MaxMB) { return }

        Write-Host "Compressing: $($file.FullName) ($sizeMB MB) -> WebP (quality=$WebpQuality, lossless=$UseLossless)"

        # 确保临时输出文件以 .webp 结尾
        $tempWebp = Join-Path $file.DirectoryName ("{0}.{1}.webp" -f $file.BaseName, [guid]::NewGuid().ToString("N"))
        $finalWebp = [System.IO.Path]::ChangeExtension($file.FullName, ".webp")

        # 组装参数 - 使用转义引号
        $args = @()
        $args += "`"$($file.FullName)`""  # 用引号包裹输入文件路径
        if ($UseLossless) {
            $args += "-define"
            $args += "webp:lossless=true"
        } else {
            $args += "-quality"
            $args += $WebpQuality.ToString()
        }
        $args += "`"$tempWebp`""  # 用引号包裹输出文件路径
        
        # 运行 magick
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $MagickCmd
        $processInfo.Arguments = $args -join " "
        $processInfo.RedirectStandardError = $true
        $processInfo.RedirectStandardOutput = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start() | Out-Null
        $process.WaitForExit()
        
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()

        if ($process.ExitCode -ne 0) {
            throw "ImageMagick return error code: $($process.ExitCode). Error: $stderr"
        }

        if (Test-Path $tempWebp) {
            if ($KeepBackup) {
                $bakPath = "$($file.FullName).bak"
                if (Test-Path $bakPath) { Remove-Item $bakPath -Force }
                Rename-Item -Path $file.FullName -NewName (Split-Path $bakPath -Leaf)
            } else {
                Remove-Item $file.FullName -Force
            }

            Rename-Item -Path $tempWebp -NewName (Split-Path $finalWebp -Leaf) -Force
            Write-Host "完成: $finalWebp" -ForegroundColor Green
        } else {
            Write-Warning "生成临时文件失败: $tempWebp"
        }
    }
    catch {
        Write-Warning "处理 $($file.FullName) 失败: $($_.Exception.Message)"
    }
}

Write-Host "所有文件处理完成!" -ForegroundColor Green
