$RootDir = "E:\git\notes\notes\docs\assets\images"

# 配置
$MinMB = 2
$MaxMB = 5
$WebpQuality = 50           
$UseLossless = $false
$KeepBackup = $false
$MagickCmd = "magick"
$HeaderReadBytes = 4096

$extensions = @("*.png","*.jpg","*.jpeg")

Get-ChildItem -Path $RootDir -Recurse -File -Include $extensions | ForEach-Object {
    $file = $_
    try {
        if ($file.Extension -ieq ".webp") { return }

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
            Write-Host "Done: $finalWebp"
        } else {
            Write-Warning "failed to generate temp file: $tempWebp"
        }
    }
    catch {
        Write-Warning "Failed processing $($file.FullName): $($_.Exception.Message)"
    }
}
