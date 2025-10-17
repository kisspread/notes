# Chaos

调试命令：
开启调试绘制
```bash
p.Chaos.DebugDraw.Enabled 1
```

睡眠状态可以用孤岛状态查看，黑色就是休眠中（调试发现，休眠和屏幕空间距离有关）
```bash
p.Chaos.Solver.DebugDrawIslands 1
```

解算Transforms
```bash
p.Chaos.Solver.DebugDrawTransforms 1
```

速度相关
```bash
p.Chaos.Solver.DebugDraw.VelScale 1
p.Chaos.Solver.DebugDraw.AngVelScale 1
```

形状
```bash
p.Chaos.Solver.DebugDrawShapes 1
```

约束
```bash
p.Chaos.Solver.DebugDraw.Cluster.Constraints 1
```

- reference: https://zhuanlan.zhihu.com/p/547758729


## Chaos 更新
5.6 支持异步的物理状态的创建和销毁
![alt text](../assets/images/Chaos_image.webp)
![alt text](../assets/images/Chaos_image-1.webp)


