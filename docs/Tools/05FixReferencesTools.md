---
title: UE5 Fix References Tools
comments:  true
---

# UE5 Fix References Tools

经过对源码的大量搜索研究，发现UE5内部是通过直接操作UAsset二进制文件来修改引用缺失，丢失问题的。

但这个工具是UE5 Internal 标记的，C++ 也无法直接调用它，只能把它复制出来。它就是 `AssetHeaderPatcher`

这种级别的补丁，修复操作还是挺疯狂的，毕竟需要直接操作二进制，但UE5比较是大佬级的项目这种操作不在话下，操作起二进制就和我编辑文本文档一样简单。

我不喜欢.uasset这种格式，它太难了，而且版本控制特别麻烦，每次小小的改动，都会提交一个全新的版本，非常占用空间。

### 场景

日常开发中，需要在不同项目里复制资源文件。通常回使用 UE 自带的资源迁移工具，但必须打开UE编辑器才能进行。

但有时候，不希望打开UE编辑器，但又需要复制资源文件，可能会导致引用路径错误，这个时候就需要用到这个工具。

### 基础概念

UE 通过FLinkerLoad 把 .uasset文件加载到内存, 最终得到 UPackage 对象。
 
任何支持序列化的对象，都可以通过FArchive接口，通过重载 << 运算符，实现各自数据的写入和读取操作。<< 在UE里是一个双向读写操作符。

### .uasset文件格式

其实 可以近似地理解为 UPackage 的构成。

`FAssetHeaderPatcher` 完整地列出了它全部组成部分。Summary 记录了文件的总大小，以及各个部分的偏移和大小，还有各个部分的名字，它是.uasset文件的头部信息。知道了这些信息，就可以进行修改和重写，从而修复引用缺失，丢失等问题。

```cpp
FAssetHeaderPatcher::EResult FAssetHeaderPatcherInner::PatchHeader_WriteDestinationFile()
{
	// Serialize modified sections and reconstruct the file	
	// Original offsets and sizes of any sections that will be patched
	//	  Tag											Offset									Size												bRequired
	const FSectionData SourceSections[] = {
		{ EPatchedSection::Summary,						0,										HeaderInformation.SummarySize,						true	},
		{ EPatchedSection::NameTable,					Summary.NameOffset,						HeaderInformation.NameTableSize,					true	},
		{ EPatchedSection::SoftPathTable,				Summary.SoftObjectPathsOffset,			HeaderInformation.SoftObjectPathListSize,			false	},
		{ EPatchedSection::GatherableTextDataTable,		Summary.GatherableTextDataOffset,		HeaderInformation.GatherableTextDataSize,			false	},
		{ EPatchedSection::ImportTable,					Summary.ImportOffset,					HeaderInformation.ImportTableSize,					true	},
		{ EPatchedSection::ExportTable,					Summary.ExportOffset,					HeaderInformation.ExportTableSize,					true	},
		{ EPatchedSection::SoftPackageReferencesTable,	Summary.SoftPackageReferencesOffset,	HeaderInformation.SoftPackageReferencesListSize,	false	},
		{ EPatchedSection::SearchableNamesMap,			Summary.SearchableNamesOffset,			HeaderInformation.SearchableNamesMapSize,			false	},
		{ EPatchedSection::ThumbnailTable,				Summary.ThumbnailTableOffset,			HeaderInformation.ThumbnailTableSize,				false	},
		{ EPatchedSection::AssetRegistryData,			Summary.AssetRegistryDataOffset,		AssetRegistryData.SectionSize,						true	},
	};

	const int32 SourceTotalHeaderSize = Summary.TotalHeaderSize;
 ```   

### 操作步骤

A 文件 在 A项目里引用了 A1文件。此时，把A复制到了B项目，A1是缺失的，B项目对应位置是B1.

这就需要用 Patcher 把 A1 文件的引用路径修正成B1文件的引用路径。

理论上，如果 A1 和 B1 是同名，甚至可以写个自动修复工具。我这里需要开发者自己选择对应的类：


```cpp{7-8,13-14}

bool UYMythEdTools::ReplaceAssetReference(const FString& AssetToFixPath, const FString& InvalidRefPath, const FString& NewRefPath)
{
//省略非核心代码

// 设置重定向上下文
	FAssetHeaderPatcher::FContext Context(PackageRenames, false);
	FCoreRedirects::AddRedirectList(Context.Redirects, TEXT("Asset Header Patcher Tests"));

//省略非核心代码

// 创建并执行 AssetHeaderPatcher
	FAssetHeaderPatcher Patcher;
	FAssetHeaderPatcher::EResult Result = Patcher.DoPatch(SrcFilename, TempFilePath, Context);

    auto DoCleanup = [TempFilePath, Context]
	{
		// 清理临时文件
		IFileManager::Get().Delete(*TempFilePath);
		// 清理重定向
		FCoreRedirects::RemoveRedirectList(Context.Redirects, TEXT("Asset Header Patcher Tests"));
	};

	if (Result != FAssetHeaderPatcher::EResult::Success)
	{
		DoCleanup();
		UE_LOG(LogTemp, Error, TEXT("Failed to replace asset reference. Asset: %s, Error: %s"), *SrcFilename, *LexToString(Result));
		return false;
	}

 ```   

## references

- https://hakuya.me/learning/unreal/UE%20%E8%B5%84%E4%BA%A7%E5%AF%BC%E5%87%BA%E5%92%8C%E5%8A%A0%E8%BD%BD/

- https://www.cnblogs.com/wosun/p/18534983
