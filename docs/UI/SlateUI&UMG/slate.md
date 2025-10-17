---
title: slate 入门
comments:  true
---

![alt text](../../assets/images/Pasted%20image%2020241011175926.webp)


### 3个必须了解的基础布局
继承于Swidget的控件有很多，但注释里建议开发者继承的只有3个。
![alt text](../../assets/images/slate_image-1.webp)
Swidget的注释告诉我们它只提供基础实现，按照slate的设计意图，我们自定义的Widget最好不要直接继承于SWidget，而是需要继承于SCompoundWidget，SLeafWidget，SPanel。这种“分类”，可以让slate框架更好地优化布局绘制，控件排列效率。

- **SLeafWidget** 叶控件，没有子控件，也不应该支持添加子控件，相当于“元控件”。

	```cpp
	/**
	* Implements a leaf widget.
	*
	* A LeafWidget is a Widget that has no slots for children.
	* LeafWidgets are usually intended as building blocks for aggregate widgets.
	*/
	class SLeafWidget : public SWidget
	```	


- **SPanel** 布局控件，可以有多个子控件，同时约定基本的布局规则。

	```cpp
	/**
	* A Panel arranges its child widgets on the screen.
	*
	* Each child widget should be stored in a Slot. The Slot describes how the individual child should be arranged with
	* respect to its parent (i.e. the Panel) and its peers Widgets (i.e. the Panel's other children.)
	* For a simple example see StackPanel.
	*/
	class SPanel: public SWidget
	```	
	派生于SPanel的多达216个。
	![alt text](../../assets/images/slate_image-3.webp)



- **SCompoundWidget** 复合控件，默认只有一个ChildSlot，类似web框架Vue里的template控件

	```cpp
	/**
	* A CompoundWidget is the base from which most non-primitive widgets should be built.
	* CompoundWidgets have a protected member named ChildSlot.
	*/
	class SCompoundWidget : public SWidget
	```

	其中，Rider显示，派生于SCompoundWidget的类多达3000多个：

	![alt text](../../assets/images/slate_image-2.webp)


#### SCompoundWidget 和 SPanel 的区别

![alt text](../../assets/images/slate_image-4.webp)

通过理解 STableViewBase 来理解他们的区别，STableViewBase继承于 SCompoundWidget 而不是 SPanel。因为表格控件是由多个控件组合而成，由固定表头，表项，滚动条等，它的职责就是负责如何组装布局，规划布局。

![alt text](../../assets/images/slate_image-5.webp)
通过阅读STableViewBase构造子不控件方式，可以发现它的**根布局**是基于SVerticalBox的，最后通过this->ChildSlot 的中括号操作符添加成为自己的子控件。 

STableViewBase的列表是SListPanel控件，这个控件继承于SPanel，它实现了自己的Slot，用来约定布局规则，就是一个一个排列添加。SPanel比SCompoundWidget更需要重写OnArrangeChildren 和 ComputeDesiredSize 方法。

- 最明显的差异是，SCompoundWidget只有一个Slot，而SPanel可以有多个Slot。
- SPanel被设计成可以根据需要定制自己想要的Slot个数，构造的时候用+操作符添加即可。如`+ SHorizontalBox::Slot()`
- SPanel制定布局规则，而SCompoundWidget是配置布局参数



### 声明式语法

slate是声明式语法，类似DSL，groovy 和 kotlin 都非常支持这种写法。而slate 是虚幻用C++ 搞出来的，原理上相对来来说比较难懂，但用起来很方便。

```cpp
// Add a new section for static meshes
	ContextualEditingWidget->AddSlot()
	.Padding( 2.0f )
	[
		SNew( SDetailSection )  // 构造器，返回 builder
		.SectionName("StaticMeshSection") // 构造器的链式调用
		.SectionTitle( "Static Mesh").ToString() ) // 构造器的链式调用
		.Content() // 构造器的链式调用
		[			// 配置 子控件
			SNew( SVerticalBox )   // 创建子控件的构造器，这里是
			+ SVerticalBox::Slot() // 添加插槽 
			.Padding( 3.0f, 1.0f ) // 插槽的配置
			[
				SNew( SHorizontalBox ) // 插槽里 放的子控件
				+ SHorizontalBox::Slot() // 添加插槽
				.Padding( 2.0f )
				[
					SNew( SComboButton )
					.ButtonContent()
					[
						SNew( STextBlock )
						.Text( LOCTEXT("BlockingVolumeMenu", "Create Blocking Volume") )
						.Font( FontInfo )
					]
					.MenuContent()
					[
						BlockingVolumeBuilder.MakeWidget()
					]
				]
			]

		]
	];
```

这个图也很好懂：
![alt text](../../assets/images/slate_image.webp)

#### 语法解析

- SNew 这是创建一个构造器，New出来的东西其实是Builder，看着有点歧义，这在其他语言可能会叫做SBuilder。这个Bulder会根据模板返回相应的构造器，就可以调用各自独有的方法，并进行链式调用。
- operator  + 加号操作符，用于添加插槽
- operator [] 中括号操作符，用于添加子控件




 


### References
- [slate声明式语法](https://myslate.readthedocs.io/en/latest/pages/Slate%E6%8E%A7%E4%BB%B6%E7%9A%84%E5%88%9B%E5%BB%BA%E8%BF%87%E7%A8%8B%E5%92%8C%E5%A3%B0%E6%98%8E%E5%BC%8F%E8%AF%AD%E6%B3%95.html)
- [slate组织和渲染 -- 返回主页寡人正在Coding](https://www.cnblogs.com/hggzhang/p/16480489.html)
- [slate合批调试 -- 南山搬砖道人](https://zhuanlan.zhihu.com/p/529040584)
- [Slate 开发 -- italink](https://italink.github.io/ModernGraphicsEngineGuide/04-UnrealEngine/1.Slate%E5%BC%80%E5%8F%91/#_1)