---
title: Git LFS
comments: true
---

## git lfs 统计文件磁盘占用

统计当前引用的Git LFS 文件大小

- 只显示当前工作树中的 LFS 文件大小总和
- 仅包括当前检出版本中存在的文件

```bash
git lfs ls-files -s | awk '
{
    
    if (match($0, /\((.*)\)/, arr)) {
        size = arr[1];  # 获取括号中的完整内容 "1.2 MB" 这样的格式
        split(size, parts, " ");  # 分割数字和单位
        if (parts[2] == "MB")
            total += parts[1] * 1024 * 1024;
        else if (parts[2] == "KB")
            total += parts[1] * 1024;
    }
}
END {
    printf "Total size: %.2f MB (%.2f GB)\n", total/1024/1024, total/1024/1024/1024
}'
```

统计包括提交记录在内的所有Git LFS 文件大小
- 包括已删除的文件和文件的所有历史版本
- 这个数字最大是因为它统计了所有版本的"逻辑大小"总和

```bash
git lfs ls-files --all -s | awk '
{
    
    if (match($0, /\((.*)\)/, arr)) {
        size = arr[1];  # 获取括号中的完整内容 "1.2 MB" 这样的格式
        split(size, parts, " ");  # 分割数字和单位
        if (parts[2] == "MB")
            total += parts[1] * 1024 * 1024;
        else if (parts[2] == "KB")
            total += parts[1] * 1024;
    }
}
END {
    printf "Total size: %.2f MB (%.2f GB)\n", total/1024/1024, total/1024/1024/1024
}'
```

### 测试记录


- git lfs ls-files  --all -s 显示是 Total size: 3565.12 MB (3.48 GB)

- git lfs ls-files   -s 显示是 Total size: 2169.97 MB (2.12 GB)

-  du -sh .git/lfs   是 2.1G 

**而gitlab 服务端显示已使用的LFS额度是 3.34G**  

说明是 gitlab 服务端统计的是 包含历史的。实际占用空间其实是 2.1G，gitlab也在玩 统计学经济。。


