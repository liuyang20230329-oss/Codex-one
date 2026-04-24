# 组件规范 (Components)

## 组件层级

```
原子 (Atoms)       → 不可拆分的基础UI元素
分子 (Molecules)    → 由原子组合的功能单元
有机体 (Organisms)  → 由分子组合的完整功能块
模板 (Templates)    → 有机体组合成页面骨架
```

---

## 一、原子组件 (Atoms)

---

### 1. Avatar 头像

**规格**

| 属性 | 值 |
|------|-----|
| 尺寸 | xs(24) / sm(32) / md(40) / lg(48) / xl(56) / xxl(80) / xxxl(120) |
| 圆角 | `radius.full` (圆形) |
| 占位 | 首字母灰底 + 品牌色文字 |
| 边框 | 在线状态: 2pt绿色描边; 群聊: 无描边 |
| 缓存 | 异步加载，本地三级缓存 |

**SwiftUI**

```swift
struct AvatarView: View {
    let url: URL?
    let size: AvatarSize
    let placeholder: String

    enum AvatarSize: CGFloat {
        case xs = 24; case sm = 32; case md = 40
        case lg = 48; case xl = 56; case xxl = 80; case xxxl = 120
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                ZStack {
                    Color.bgTertiary
                    Text(String(placeholder.prefix(1)))
                        .font(.system(size: size.rawValue * 0.4, weight: .medium))
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .frame(width: size.rawValue, height: size.rawValue)
        .clipShape(Circle())
    }
}
```

**Jetpack Compose**

```kotlin
@Composable
fun Avatar(
    url: String?,
    size: Dp,
    placeholder: String,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(MaterialTheme.colorScheme.surfaceVariant),
        contentAlignment = Alignment.Center
    ) {
        if (url != null) {
            AsyncImage(
                model = url,
                contentDescription = null,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
        } else {
            Text(
                text = placeholder.take(1),
                fontSize = (size.value * 0.4).sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
```

---

### 2. Button 按钮

**变体**

| 变体 | 背景 | 文字色 | 用途 |
|------|------|--------|------|
| `primary` | `brand.primary` | `#FFFFFF` | 主操作(发布、发送、确认) |
| `secondary` | `brand.primary.light` | `brand.primary` | 辅助操作(关注、收藏) |
| `outline` | 透明+品牌色边框 | `brand.primary` | 次要操作(取消) |
| `ghost` | 透明 | `brand.primary` | 文字按钮 |
| `danger` | `semantic.error` | `#FFFFFF` | 危险操作(删除、退出) |

**尺寸**

| 尺寸 | 高度 | 水平内边距 | 字号 | 圆角 |
|------|------|-----------|------|------|
| `large` | 48pt/dp | 24pt/dp | `label` (16) | `radius.md` (12) |
| `medium` | 40pt/dp | 20pt/dp | `label` (16) | `radius.sm` (8) |
| `small` | 32pt/dp | 16pt/dp | `label.small` (14) | `radius.xs` (4) |

**状态**: default → pressed(透明度0.7) → disabled(透明度0.4) → loading(Spinner替代文字)

**SwiftUI**

```swift
struct AppButton: View {
    let title: String
    let variant: ButtonVariant
    let size: ButtonSize
    let isLoading: Bool
    let action: () -> Void

    enum ButtonVariant {
        case primary, secondary, outline, ghost, danger
    }

    enum ButtonSize: CGFloat {
        case large = 48; case medium = 40; case small = 32
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: .spaceXS) {
                if isLoading {
                    ProgressView()
                        .tint(variant == .primary || variant == .danger ? .white : .brandPrimary)
                }
                Text(title)
                    .font(size == .small ? .labelSmall : .label)
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.rawValue)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                if variant == .outline {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.brandPrimary, lineWidth: 1)
                }
            }
        }
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: .brandPrimary
        case .secondary: .brandPrimaryLight
        case .outline, .ghost: .clear
        case .danger: .semanticError
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .danger: .white
        case .secondary, .outline, .ghost: .brandPrimary
        }
    }

    private var cornerRadius: CGFloat {
        size == .small ? .radiusXS : .radiusMD
    }
}
```

**Jetpack Compose**

```kotlin
@Composable
fun AppButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: ButtonVariant = ButtonVariant.Primary,
    size: ButtonSize = ButtonSize.Large,
    isLoading: Boolean = false
) {
    val height by lazy { when(size) { ButtonSize.Large -> 48.dp; ButtonSize.Medium -> 40.dp; ButtonSize.Small -> 32.dp } }
    val cornerShape by lazy { when(size) { ButtonSize.Small -> CornerRadius.XS; else -> CornerRadius.MD } }

    OutlinedButton(
        onClick = onClick,
        modifier = modifier.height(height),
        enabled = !isLoading,
        shape = cornerShape,
        colors = when (variant) {
            ButtonVariant.Primary -> ButtonDefaults.outlinedButtonColors(
                containerColor = AppColors.brandPrimary,
                contentColor = Color.White
            )
            ButtonVariant.Secondary -> ButtonDefaults.outlinedButtonColors(
                containerColor = AppColors.brandPrimaryLight,
                contentColor = AppColors.brandPrimary
            )
            ButtonVariant.Danger -> ButtonDefaults.outlinedButtonColors(
                containerColor = AppColors.semanticError,
                contentColor = Color.White
            )
            ButtonVariant.Outline -> ButtonDefaults.outlinedButtonColors(
                containerColor = Color.Transparent,
                contentColor = AppColors.brandPrimary
            )
            ButtonVariant.Ghost -> ButtonDefaults.outlinedButtonColors(
                containerColor = Color.Transparent,
                contentColor = AppColors.brandPrimary
            )
        },
        border = if (variant == ButtonVariant.Outline) BorderStroke(1.dp, AppColors.brandPrimary) else null
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.size(16.dp),
                strokeWidth = 2.dp,
                color = if (variant == ButtonVariant.Primary || variant == ButtonVariant.Danger) Color.White else AppColors.brandPrimary
            )
        } else {
            Text(text = text, style = if (size == ButtonSize.Small) MaterialTheme.typography.labelMedium else MaterialTheme.typography.labelLarge)
        }
    }
}

enum class ButtonVariant { Primary, Secondary, Outline, Ghost, Danger }
enum class ButtonSize { Large, Medium, Small }
```

---

### 3. Icon Button 图标按钮

| 属性 | 值 |
|------|-----|
| 触控区域 | 44x44pt(iOS) / 48x48dp(Android) |
| 图标尺寸 | `icon.md` (24) |
| 背景 | 透明/圆形`neutral.bg.tertiary` |
| 状态 | pressed → 缩放0.92 + 透明度0.6 |

---

### 4. TextField 输入框

**变体**: `standard`(底部线) / `filled`(填充背景) / `outlined`(描边)

| 属性 | filled变体值 |
|------|-------------|
| 背景 | `neutral.bg.tertiary` |
| 高度 | 44pt/dp (单行) |
| 水平内边距 | `space.md` (12) |
| 圆角 | `radius.sm` (8) |
| 占位文字色 | `neutral.text.tertiary` |
| 输入文字色 | `neutral.text.primary` |
| 字号 | `body.medium` (15) |
| 聚焦态 | 边框变为 `brand.primary` 1.5pt |
| 错误态 | 边框变为 `semantic.error` + 错误提示文字 |
| 字数限制 | 右下角灰色计数器 `caption` 字号 |

---

### 5. Badge 徽标

| 变体 | 规格 | 颜色 |
|------|------|------|
| 红点 | 8x8 圆 | `brand.accent` |
| 数字 | min 16x16 圆角矩形 `radius.full` | `brand.accent` 背景 + 白色文字 `label.tiny` |
| 文字标签 | auto宽 x 20 高 `radius.xs` | 品牌色或语义色背景 + 白色文字 |

数字超过99显示 "99+"

---

### 6. Tag 标签

| 属性 | 值 |
|------|-----|
| 高度 | 28pt/dp |
| 水平内边距 | `space.md` (12) |
| 圆角 | `radius.xs` (4) |
| 字号 | `label.small` (14) |
| 选中态 | `brand.primary` 背景 + 白色文字 |
| 未选中态 | `neutral.bg.tertiary` 背景 + `neutral.text.secondary` 文字 |

---

## 二、分子组件 (Molecules)

---

### 7. Search Bar 搜索栏

**布局**

```
┌─────────────────────────────────┐
│ 🔍  搜索用户、话题、内容...      │
└─────────────────────────────────┘
  40pt高, radius.md, bgTertiary背景
```

- 高度: 40pt/dp
- 背景: `neutral.bg.tertiary`
- 圆角: `radius.md` (12)
- 左侧: 搜索图标 `icon.sm` (20) + `space.sm` 间距
- 占位文字: `body.small` + `neutral.text.tertiary`
- 点击行为: 跳转搜索页(不原地展开输入)

---

### 8. Post Card 帖子卡片 (信息流核心)

**完整结构**

```
┌──────────────────────────────────────┐
│ [Avatar] 用户名           · 3分钟前  │  ← header (56pt高)
│           @username                  │
├──────────────────────────────────────┤
│ 文字内容最多6行，超出显示"...展开"    │  ← content
│ #话题标签 #话题标签                   │
├──────────────────────────────────────┤
│ ┌────────────────────────────────┐   │
│ │     图片/视频(最多9宫格)        │   │  ← media
│ │     圆角 radius.md             │   │  ← 16:9 / 1:1 / 4:3
│ └────────────────────────────────┘   │
├──────────────────────────────────────┤
│ ♡ 128    💬 32    ↗ 分享   ...      │  ← action bar (44pt高)
└──────────────────────────────────────┘
```

**规格**

| 区域 | 间距 | 说明 |
|------|------|------|
| 卡片整体 | 水平 `space.lg` (16) | 与屏幕边缘间距 |
| 卡片之间 | 垂直 `space.xs` (4) | 用分割线分隔 |
| Header | 垂直内边距 `space.sm` (8) | Avatar(lg:48) + 用户名 + 时间 |
| Content | 水平 `space.lg` (16), 垂直 `space.sm` (8) | 文字+话题 |
| Media | 水平 `space.lg` (16), 上下 `space.sm` (8) | 图片间距2pt |
| Action Bar | 水平 `space.lg` (16), 高44 | 4个操作按钮均匀分布 |

**图片九宫格规则**

| 图片数 | 布局 |
|--------|------|
| 1 | 单张大图, 最大高度300pt, 等比缩放 |
| 2 | 左右各50% |
| 3 | 左1大 + 右2小 |
| 4 | 2x2网格 |
| 5-6 | 第一行3个 + 第二行 |
| 7-9 | 3x3网格 |

---

### 9. Chat Bubble 聊天气泡

| 属性 | 自己(右侧) | 对方(左侧) |
|------|-----------|-----------|
| 背景色 | `brand.primary` | `neutral.bg.tertiary` |
| 文字色 | `#FFFFFF` | `neutral.text.primary` |
| 圆角 | 左上12 右上12 右下12 左下4 | 左上12 右上12 左下12 右下4 |
| 最大宽度 | 屏幕宽70% | 屏幕宽70% |
| 内边距 | 水平12 垂直8 | 水平12 垂直8 |
| 字号 | `body.medium` (15) | `body.medium` (15) |
| 时间戳 | 气泡右下方 | 气泡左下方 |
| 头像 | 不显示 | 显示 Avatar(xs:24) |

**特殊消息类型**

| 类型 | 高度 | 说明 |
|------|------|------|
| 纯文字 | 自适应 | 最大70%宽度 |
| 图片 | 等比缩放, 最大宽200 | 圆角 `radius.sm` (8) |
| 语音 | 固定宽120 | 波形动画 + 时长显示 |
| 视频 | 16:9 缩略图 | 播放按钮叠加 |
| 位置 | 160x100 地图缩略图 | 底部地址文字 |
| 文件 | 固定模板 | 文件图标+名称+大小 |
| 名片 | 固定模板 | Avatar + 用户名 + 简介 |
| 红包 | 固定模板 | 品牌色背景 + 金额/祝福语 |

---

### 10. Story Item 动态/Stories条目

**布局** (横向滚动列表中的单个Item)

```
┌──────────┐
│ ┌──────┐ │
│ │      │ │  ← 渐变边框: 未看=品牌色, 已看=灰色
│ │ 头像  │ │
│ │ 68x68 │ │
│ └──────┘ │
│  昵称    │  ← caption (13pt), 单行截断
└──────────┘
```

| 属性 | 值 |
|------|-----|
| 整体宽度 | 76pt/dp |
| 边框宽度 | 2.5pt |
| 边框圆角 | `radius.full` |
| 头像尺寸 | 68pt/dp |
| 未读边框 | 品牌色渐变(品牌色 → 品牌辅色) |
| 已读边框 | `neutral.divider` |
| 我的Story | 左上角 "+" 按钮 |

---

## 三、有机体组件 (Organisms)

---

### 11. Navigation Bar 导航栏

**标准导航栏** (非Large Title)

| 平台 | 高度 | 说明 |
|------|------|------|
| iOS | 44pt (不含SafeArea) | 右滑返回手势 |
| Android | 56dp | 遵循Material TopAppBar |

**布局**

```
┌──────────────────────────────────┐
│ ← 返回    页面标题      [操作按钮] │  44pt/56dp
└──────────────────────────────────┘
```

- 标题: `headline` (17) Semibold, 居中
- 返回按钮: 左侧 `<` 或 `←` 图标
- 操作按钮: 右侧最多2个 icon button

---

### 12. Tab Bar 底部标签栏

**规格**

| 平台 | 高度(含安全区) | 图标 | 标签 |
|------|---------------|------|------|
| iOS | 49pt + SafeArea | `icon.md` (24) | `caption.small` (11) |
| Android | 56dp + NavBar高度 | `icon.md` (24) | `label.tiny` (12) |

**标准5Tab布局** (综合社交)

```
┌─────────────────────────────────────────┐
│  🏠首页    💬消息    ➕    🔍发现    👤我的  │
│  首页     消息    发布    发现     我的    │
└─────────────────────────────────────────┘
```

| Tab | 图标 | 选中色 | 未选中色 | 特殊 |
|-----|------|--------|---------|------|
| 首页 | house.fill | `brand.primary` | `neutral.text.tertiary` | - |
| 消息 | message.fill | `brand.primary` | `neutral.text.tertiary` | 支持红点Badge |
| 发布 | plus.circle.fill | `brand.primary` | `neutral.text.tertiary` | 中间凸起, 较大图标(32) |
| 发现 | magnifyingglass | `brand.primary` | `neutral.text.tertiary` | - |
| 我的 | person.fill | `brand.primary` | `neutral.text.tertiary` | - |

---

### 13. Comment Sheet 评论面板

**结构** (从底部弹出的半屏Sheet)

```
┌──────────────────────────────────────┐
│  评论 238                    ✕ 关闭  │  ← 标题栏 44pt
├──────────────────────────────────────┤
│  [热门 ▾]  [最新 ▾]                 │  ← 排序Tab 36pt
├──────────────────────────────────────┤
│  ┌──────────────────────────────┐    │
│  │ [Avatar] 用户名    ❤ 12     │    │  ← 评论项
│  │          评论内容文字...      │    │
│  │          2小时前  回复       │    │
│  ├──────────────────────────────┤    │
│  │ [Avatar] 用户名    ❤ 5      │    │
│  │          评论内容文字...      │    │
│  │          1小时前  回复       │    │
│  └──────────────────────────────┘    │
├──────────────────────────────────────┤
│  [Avatar] 说点什么...    😊 🖼 @  │  ← 输入栏 56pt
└──────────────────────────────────────┘
```

**规格**

| 属性 | 值 |
|------|-----|
| 弹出高度 | 屏幕60% ~ 90% |
| 圆角(顶部) | `radius.xl` (20) |
| 手势 | 下拉关闭(阈值30%) |
| 评论项间距 | `space.md` (12) |
| 输入栏高度 | 56pt/dp (含安全区) |
| 输入栏最大行数 | 4行自适应 |

---

### 14. Empty State 空状态

**结构**

```
┌──────────────────────┐
│                      │
│    [空状态插画]       │  120x120
│                      │
│    暂无内容           │  headline, textSecondary
│    快去发现有趣的内容  │  bodySmall, textTertiary
│                      │
│    [去发现]           │  secondary button, medium
│                      │
└──────────────────────┘
```

居中显示，垂直偏上1/3位置。

---

### 15. Pull-to-Refresh 下拉刷新

| 属性 | 值 |
|------|-----|
| 触发距离 | 60pt/dp |
| 刷新动画 | 旋转的品牌色圆环 |
| 成功反馈 | 轻触震动(Haptic) + "已刷新"文字1秒 |
| 超时 | 10秒自动结束 |
