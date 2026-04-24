# 设计模式与交互规范 (Patterns)

---

## 一、导航模式 (Navigation)

### 1.1 主导航结构

采用 **底部Tab + 堆栈导航** 混合架构：

```
TabBar (底部标签栏, 始终可见)
├── Tab1: 首页Feed → NavigationStack
│   ├── Feed列表
│   ├── 帖子详情
│   ├── 用户主页
│   └── 话题页
├── Tab2: 消息 → NavigationStack
│   ├── 会话列表
│   ├── 聊天页
│   ├── 群组详情
│   └── 搜索联系人
├── Tab3: 发布 → Modal呈现
├── Tab4: 发现 → NavigationStack
│   ├── 搜索页
│   ├── 热门话题
│   ├── 附近的人
│   └── 推荐用户
└── Tab5: 我的 → NavigationStack
    ├── 个人主页
    ├── 设置
    ├── 编辑资料
    └── 隐私设置
```

### 1.2 iOS导航规则 (SwiftUI)

```swift
// 主结构
TabView(selection: $selectedTab) {
    NavigationStack(path: $feedPath) {
        FeedView()
            .navigationDestination(for: FeedRoute.self) { route in
                switch route {
                case .postDetail(let id): PostDetailView(postId: id)
                case .userProfile(let id): UserProfileView(userId: id)
                case .topic(let tag): TopicView(tag: tag)
                }
            }
            .tag(Tab.feed)
            .tabItem { Label("首页", systemImage: "house.fill") }
    }
    // ... 其他Tab
}
```

### 1.3 Android导航规则 (Jetpack Compose)

```kotlin
@Composable
fun MainNavHost(navController: NavHostController) {
    NavHost(navController, startDestination = "feed") {
        composable("feed") { FeedScreen(onPostClick = { navController.navigate("post/$it") }) }
        composable("post/{postId}") { backStackEntry ->
            PostDetailScreen(postId = backStackEntry.arguments?.getString("postId"))
        }
        composable("user/{userId}") { backStackEntry ->
            UserProfileScreen(userId = backStackEntry.arguments?.getString("userId"))
        }
    }
}
```

### 1.4 页面转场规范

| 转场类型 | iOS | Android | 时长 |
|---------|-----|---------|------|
| 前进(push) | 从右滑入 | 从右滑入 | 300ms `ease.decelerate` |
| 后退(pop) | 向右滑出 | 向右滑出 | 300ms `ease.accelerate` |
| 模态(modal) | 从底滑入 | 从底滑入 | 400ms `ease.decelerate` |
| 关闭模态 | 向下滑出 | 向下滑出 | 350ms `ease.accelerate` |
| Tab切换 | 淡入淡出 | 淡入淡出 | 200ms `ease.standard` |
| 全屏图片 | 缩放动画 | 缩放动画 | 350ms `ease.spring` |

---

## 二、手势交互 (Gestures)

### 2.1 全局手势

| 手势 | 触发区域 | 行为 |
|------|---------|------|
| 左边缘右滑 | 屏幕左侧20pt | 返回上一页 |
| 列表项左滑 | 列表项右侧 | 显示操作按钮(删除/标为已读/置顶) |
| 下拉 | 列表顶部 | 刷新 |
| 双击Tab图标 | 底部Tab | 滚动到顶部并刷新 |

### 2.2 帖子卡片手势

| 手势 | 行为 |
|------|------|
| 双击 | 点赞(弹出心形动画) |
| 长按 | 弹出操作菜单(收藏/复制/举报/分享) |
| 图片单击 | 全屏预览(支持缩放) |
| 视频单击 | 播放/暂停 |
| 头像单击 | 跳转用户主页 |
| 话题标签单击 | 跳转话题页 |

### 2.3 聊天页手势

| 手势 | 行为 |
|------|------|
| 消息左滑 | 回复/转发/复制 |
| 气泡长按 | 弹出操作菜单 |
| 语音消息长按 | 录音(松手发送) |
| 语音消息上滑 | 取消发送 |
| 相册页下滑 | 关闭 |

### 2.4 左滑操作按钮

列表项左滑后显示的操作按钮，按优先级排列：

**会话列表**: 置顶 / 标为已读 / 删除
**通知列表**: 标为已读 / 删除

| 操作 | 图标色 | 背景色 |
|------|--------|--------|
| 置顶 | `#FFFFFF` | `brand.secondary` |
| 标为已读 | `#FFFFFF` | `semantic.info` |
| 删除 | `#FFFFFF` | `semantic.error` |

按钮宽度: 72pt/dp，圆角: 无

---

## 三、反馈模式 (Feedback)

### 3.1 触觉反馈 (Haptic)

| 场景 | iOS (UIImpactFeedbackGenerator) | Android (HapticFeedback) |
|------|------|---------|
| 点赞 | `.medium` | `KEYBOARD_TAP` |
| 发送消息 | `.light` | `KEYBOARD_TAP` |
| 长按触发 | `.medium` | `LONG_PRESS` |
| 下拉刷新成功 | `.light` | `KEYBOARD_TAP` |
| 错误提示 | `.heavy` | `REJECT` |
| 切换Tab | `.light` | - |
| 开关切换 | `.medium` | `CLOCK_TICK` |

### 3.2 视觉反馈

| 场景 | 反馈方式 |
|------|---------|
| 按钮按压 | 缩放至0.96 + 透明度0.7 |
| 点赞成功 | 红心放大 → 缩小 → 弹跳 动画序列 |
| 发送成功 | 消息气泡从输入栏飞入列表 |
| 操作失败 | 顶部Toast(红色背景) + 震动 |
| 网络断开 | 顶部常驻黄色横幅 "网络连接已断开" |
| 加载中 | 骨架屏(Skeleton) / 旋转Spinner |
| 内容已删除 | 帖子卡片内显示 "该内容已删除" 灰色文字 |

### 3.3 Toast 规范

```
┌─────────────────────────────────┐
│  ✓ 操作成功                     │  ← 成功: 绿色背景
│  或                             │  ← 错误: 红色背景
│  ✗ 网络请求失败，请重试          │  ← 警告: 黄色背景
│  或                             │
│  ℹ 已复制到剪贴板               │  ← 信息: 品牌色背景
└─────────────────────────────────┘
```

| 属性 | 值 |
|------|-----|
| 位置 | 屏幕顶部(SafeArea下方) |
| 高度 | 自适应(最小44) |
| 圆角 | `radius.md` (12) |
| 显示时长 | 2秒(成功) / 3秒(错误) / 2.5秒(信息) |
| 出现动画 | 从顶部下滑 `duration.fast` |
| 消失动画 | 向上滑出 `duration.fast` |
| 文字色 | `#FFFFFF` |
| 字号 | `body.small` (14) |

---

## 四、内容展示模式

### 4.1 列表性能规范

| 规则 | 实现 |
|------|------|
| 虚拟化 | iOS: `LazyVStack` / Android: `LazyColumn` |
| 分页加载 | 距底部30%时预加载下一页 |
| 图片缓存 | 三级缓存(内存→磁盘→网络) |
| 图片解码 | 后台线程解码，使用Downsampling |
| 骨架屏 | 首次加载使用Skeleton，非Spinner |
| 滚动性能 | 60fps目标，避免主线程计算 |

### 4.2 骨架屏 (Skeleton)

```
┌──────────────────────────────────────┐
│ [○ ○○]  ████████  ████             │  ← 圆形Avatar + 灰色矩形条
│         ████████████████            │
├──────────────────────────────────────┤
│ [○ ○○]  ████████  ████             │
│         ████████████████            │
│  ┌─────────────────────────────┐    │
│  │  ███████████████████████    │    │  ← 图片占位块
│  └─────────────────────────────┘    │
└──────────────────────────────────────┘
```

| 属性 | 值 |
|------|-----|
| 骨架色(Light) | `#E8E8E8` |
| 骨架色(Dark) | `#333333` |
| 闪光色 | 从左到右渐变，20%透明度白色 |
| 动画 | 循环闪光，时长1.5秒 |
| 圆角 | 与实际元素一致 |
| 显示时机 | 首次加载(非刷新)时替换整个内容区 |

**SwiftUI Skeleton**

```swift
struct SkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .fill(Color.bgTertiary)
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.2), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: isAnimating ? geo.size.width : -geo.size.width)
                }
            }
            .clipped()
            .onAppear { withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) { isAnimating = true } }
    }
}
```

**Jetpack Compose Skeleton**

```kotlin
@Composable
fun SkeletonBox(modifier: Modifier = Modifier) {
    val infiniteTransition = rememberInfiniteTransition()
    val shimmerOffset by infiniteTransition.animateFloat(
        initialValue = -1f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1500, easing = LinearEasing)
        )
    )

    Box(
        modifier = modifier
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .drawWithContent {
                drawContent()
                drawRect(
                    brush = Brush.linearGradient(
                        colors = listOf(Color.Transparent, Color.White.copy(alpha = 0.2f), Color.Transparent),
                        start = Offset(size.width * shimmerOffset, 0f),
                        end = Offset(size.width * shimmerOffset + size.width, size.height)
                    )
                )
            }
    )
}
```

### 4.3 图片查看器 (ImageViewer)

| 属性 | 值 |
|------|-----|
| 背景 | `#000000` 95%透明 |
| 手势 | 双指缩放(1x-3x) / 单指拖动 / 双击放大/还原 |
| 多图 | 左右滑动切换，底部显示 "2/9" 页码指示器 |
| 关闭 | 下滑关闭，背景透明度跟随手势进度 |
| 转场 | 共享元素动画(Hero Transition)从卡片缩放到全屏 |

### 4.4 视频播放器

| 属性 | 值 |
|------|-----|
| 自动播放 | 信息流中静音自动播放(WiFi下) |
| 手动播放 | 点击有声播放 |
| 控制栏 | 单击显示/隐藏，3秒后自动隐藏 |
| 进度条 | 底部，可拖动，已播放部分为品牌色 |
| 全屏 | 右下角全屏按钮，横屏模式 |
| 预加载 | WiFi下预加载前3秒 |

---

## 五、弹窗与模态 (Dialogs & Modals)

### 5.1 确认对话框 (Alert)

```
┌─────────────────────────────┐
│                             │
│     确定要删除这条动态吗？    │
│     删除后不可恢复           │
│                             │
│  [取消]          [删除]      │
│                             │
└─────────────────────────────┘
```

| 属性 | 值 |
|------|-----|
| 圆角 | `radius.md` (12) |
| 按钮高度 | 44pt/dp |
| 取消按钮 | `ghost` 变体, `neutral.text.secondary` |
| 确认按钮 | `danger` 变体(危险操作) 或 `primary`(一般操作) |
| 出现动画 | 缩放0.9→1.0 + 背景淡入, `duration.normal` |

### 5.2 Action Sheet 操作菜单

从底部弹出，最多显示6个选项：

```
┌──────────────────────────────┐
│  ┌────────────────────────┐  │
│  │      收藏              │  │
│  ├────────────────────────┤  │
│  │      复制文字           │  │
│  ├────────────────────────┤  │
│  │      不感兴趣           │  │
│  ├────────────────────────┤  │
│  │      举报              │  │  ← 红色文字
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │      取消              │  │  ← 独立区块
│  └────────────────────────┘  │
└──────────────────────────────┘
```

| 属性 | 值 |
|------|-----|
| 选项高度 | 56pt/dp |
| 字号 | `body.large` (17) |
| 圆角(每组) | `radius.lg` (16) |
| 间距(两组之间) | `space.xs` (4) |
| 危险操作色 | `semantic.error` |
| 普通操作色 | `brand.primary` |
| 取消按钮 | `neutral.text.primary` Semibold |

### 5.3 Bottom Sheet 底部面板

用于评论、筛选、分享等复合内容：

| 属性 | 值 |
|------|-----|
| 最大高度 | 屏幕90% |
| 圆角(顶部) | `radius.xl` (20) |
| 拖拽指示条 | 顶部居中 36x4 `neutral.divider` 圆角2 |
| 手势 | 下拉关闭，阈值30% |
| 遮罩 | 黑色50%透明 |
| 出现动画 | 从底部滑入 `duration.normal` + `ease.decelerate` |

---

## 六、状态管理 (States)

### 6.1 页面状态机

每个页面必须处理以下5种状态：

```
┌─────────┐     ┌──────────┐     ┌─────────┐
│ Loading │────▶│ Success  │────▶│ Refresh │
└─────────┘     └────┬─────┘     └─────────┘
                     │
              ┌──────┴──────┐
              ▼             ▼
        ┌──────────┐  ┌─────────┐
        │  Empty   │  │  Error  │
        └──────────┘  └────┬────┘
                           │
                     ┌─────▼─────┐
                     │  Retry   │ ──▶ Loading
                     └───────────┘
```

**SwiftUI 状态枚举**

```swift
enum ViewState<T> {
    case loading
    case success(T)
    case empty
    case error(String)
    case refreshing(T)

    var isLoading: Bool { if case .loading = self { return true }; return false }
}
```

**Jetpack Compose 状态密封类**

```kotlin
sealed class ViewState<out T> {
    object Loading : ViewState<Nothing>()
    data class Success<T>(val data: T) : ViewState<T>()
    object Empty : ViewState<Nothing>()
    data class Error(val message: String) : ViewState<Nothing>()
    data class Refreshing<T>(val data: T) : ViewState<T>()
}
```

### 6.2 各状态UI

| 状态 | UI表现 |
|------|--------|
| Loading | 全屏骨架屏(Skeleton) |
| Success | 正常内容 |
| Refreshing | 内容保持 + 顶部刷新指示器 |
| Empty | Empty State组件(插画+文字+按钮) |
| Error | 错误插画 + 描述文字 + 重试按钮 |

---

## 七、动画规范 (Animation)

### 7.1 列表动画

| 场景 | 动画 |
|------|------|
| 新内容插入 | 从上方滑入(alpha 0→1, y -20→0), `duration.fast` |
| 内容删除 | 向左滑出(alpha 1→0, x 0→屏幕宽), `duration.fast` |
| 列表首次加载 | 逐项延迟出现(每项延迟50ms, 最多200ms) |

### 7.2 交互动画

| 场景 | 动画 | 参数 |
|------|------|------|
| 点赞 | 心形缩放弹跳 | scale: 0→1.3→0.9→1.1→1.0, 400ms spring |
| 关注按钮 | 文字变化+背景色变化 | crossfade + 背景色过渡, 200ms |
| 头像点击 | 缩放反馈 | scale: 1→0.95→1, 150ms |
| Tab切换 | 图标缩放+文字淡入 | scale: 0.9→1 + alpha: 0→1, 200ms |
| 开关切换 | 滑块滑动+背景色变化 | 200ms `ease.standard` |
| 红点消失 | 缩放到0 | scale: 1→0 + alpha: 1→0, 150ms |

### 7.3 动画禁用

- 用户开启 "减少动态效果" (iOS) / "移除动画" (Android) 时，所有动画降级为即时切换
- 检测方式:
  - iOS: `UIAccessibility.isReduceMotionEnabled`
  - Android: `settings.global.getInt(contentResolver, "animator_duration_scale", 1) == 0`

---

## 八、暗色模式 (Dark Mode)

### 8.1 切换规则

- 跟随系统设置(默认)
- 用户可在App内手动切换: 跟随系统 / 始终浅色 / 始终深色
- 切换时无动画，即时生效

### 8.2 暗色模式调整要点

| 元素 | 调整规则 |
|------|---------|
| 背景 | 不使用纯黑`#000000`，使用系统暗色`#000000`(iOS)/`#121212`(Android) |
| 卡片 | 使用略亮于背景的色值，不用纯白 |
| 阴影 | 改为极细描边(0.5pt `neutral.border`) |
| 图片 | 非必要不降低亮度，保持原始显示 |
| 品牌 | 主色适当提亮增加对比度(见design-tokens.md) |
| 分割线 | 使用比背景略亮的色值 |
| 视频 | 避免自动降低亮度 |

---

## 九、无障碍 (Accessibility)

### 9.1 基本要求

| 要求 | 标准 |
|------|------|
| 最小触控区域 | 44x44pt(iOS) / 48x48dp(Android) |
| 颜色对比度 | 正文 ≥ 4.5:1, 大文字 ≥ 3:1 (WCAG AA) |
| 动态字体 | 支持系统字体缩放(最大1.5x不破坏布局) |
| 屏幕阅读器 | 所有可交互元素添加accessibility label |
| 焦点顺序 | 从上到下、从左到右的逻辑顺序 |

### 9.2 社交特有无障碍

| 场景 | 处理方式 |
|------|---------|
| 用户头像 | Label: "[用户名]的头像" |
| 点赞按钮 | Label: "点赞, 已点赞" / "点赞, 未点赞" |
| 图片帖子 | 使用 `accessibilityAttributedLabel` 描述图片内容 |
| 视频帖子 | 提供字幕轨道, Label描述视频概要 |
| 消息气泡 | Label: "[用户名]说: [消息内容], [时间]" |
| 红点/未读数 | Label追加 "有N条未读消息" |
| 表情键盘 | 每个表情提供文字描述 |
