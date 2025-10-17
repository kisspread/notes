
$RootDir = "E:\git\notes\notes\docs\assets\test"

# 配置
$MinMB = 0
$MaxMB = 1
$WebpQuality = 95           
$UseLossless = $false
$KeepBackup = $false
$MagickCmd = "magick"
$HeaderReadBytes = 4096

if (-not (Get-Command $MagickCmd -ErrorAction SilentlyContinue)) {
    Write-Error "找不到 ImageMagick 可执行: $MagickCmd。"
    return
}

$extensions = @("*.png","*.jpg","*.jpeg")

Get-ChildItem -Path $RootDir -Recurse -File -Include $extensions | ForEach-Object {
    $file = $_
    try {
        if ($file.Extension -ieq ".webp") { return }

        # $sizeMB = [math]::Round($file.Length / 1MB, 2)
        # if ($sizeMB -lt $MinMB -or $sizeMB -gt $MaxMB) { return }

        # $ext = $file.Extension.ToLower()
        # if ($ext -notin ".png", ".jpg", ".jpeg") { return }


        Write-Host ("Compressing: {0} ({1} MB) -> WebP (quality={2}, lossless={3})" -f $file.FullName, $sizeMB, $WebpQuality, $UseLossless)

        # 确保临时输出文件以 .webp 结尾
        $tempWebp = Join-Path $file.DirectoryName ("{0}.{1}.webp" -f $file.BaseName, [guid]::NewGuid().ToString("N"))
        $finalWebp = [System.IO.Path]::ChangeExtension($file.FullName, ".webp")

        # 组装参数
        $args = @()
        $args += $file.FullName
        if ($UseLossless) {
            $args += "-define"
            $args += "webp:lossless=true"
        } else {
            $args += "-quality"
            $args += $WebpQuality.ToString()
        }
        $args += $tempWebp
        Write-Host ("args={0}" -f $file.FullName, $sizeMB, $WebpQuality, $UseLossless)
        # 运行 magick
        $proc = Start-Process -FilePath $MagickCmd -ArgumentList $args -NoNewWindow -Wait -PassThru -ErrorAction Stop

        if (Test-Path $tempWebp) {
            if ($KeepBackup) {
                $bakPath = "$($file.FullName).bak"
                if (Test-Path $bakPath) { Remove-Item $bakPath -Force }
                Rename-Item -Path $file.FullName -NewName (Split-Path $bakPath -Leaf)
            } else {
                Remove-Item $file.FullName -Force
            }

            Rename-Item -Path $tempWebp -NewName (Split-Path $finalWebp -Leaf) -Force
            Write-Host "✔ Done: $finalWebp"
        } else {
            Write-Warning "转换失败，未生成临时文件: $tempWebp"
        }
    }
    catch {
        Write-Warning ("Failed processing {0}: {1}" -f $file.FullName, $_.Exception.Message)
    }
}
 