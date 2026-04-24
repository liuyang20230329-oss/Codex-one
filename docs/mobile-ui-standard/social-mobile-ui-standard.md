# 综合型社交平台 — 移动端UI设计标准与实现规范

> **技术栈**: SwiftUI (iOS 17+) + Jetpack Compose (Android API 26+)
> **版本**: v1.0 | **日期**: 2026-04-22
> **用途**: OpenCode Skill — 供AI编码代理自动加载使用

---
# 社交平台移动端UI标准

## 技术栈

- **iOS**: SwiftUI (最低支持 iOS 17+)
- **Android**: Jetpack Compose (最低支持 API 26+ / Android 8.0)
- **设计工具参考**: Figma

## 文档结构

本 Skill 包含以下子文档，按需加载：

| 文件 | 内容 | 何时参考 |
|------|------|----------|
| `design-tokens.md` | 颜色、字体、间距、圆角、阴影、动效时长 | 需要精确的视觉参数时 |
| `components.md` | 原子/分子/有机体组件的规格与代码模板 | 创建或修改 UI 组件时 |
| `patterns.md` | 交互手势、导航模式、状态管理、动画规范 | 设计页面交互逻辑时 |
| `screen-specs.md` | 各核心页面的完整布局规格 | 实现具体页面时 |

## 核心设计原则

1. **内容优先** — UI服务于社交内容，减少装饰性元素，让用户内容成为视觉焦点
2. **拇指友好** — 核心操作区域在屏幕下方60%范围内，支持单手操作
3. **一致性** — iOS遵循Human Interface Guidelines，Android遵循Material Design 3，但保持品牌视觉统一
4. **无障碍** — 所有可交互元素最小触控目标44pt(iOS)/48dp(Android)，支持动态字体和VoiceOver/TalkBack
5. **性能感知** — 列表滚动保持60fps，图片渐进加载，骨架屏替代loading spinner

## 应用模块概览

综合社交平台包含以下核心模块：

```
App
├── 认证模块 (Auth)
│   ├── 登录/注册
│   ├── 手机验证码
│   ├── 第三方登录
│   └── 个人资料设置
├── 首页/信息流 (Feed)
│   ├── 推荐/关注双Tab
│   ├── 图文帖子卡片
│   ├── 短视频卡片
│   └── Stories/动态
├── 即时通讯 (Chat)
│   ├── 会话列表
│   ├── 单聊/群聊
│   ├── 语音/视频通话
│   └── 消息类型(文字/图片/文件/位置等)
├── 社区/发现 (Discover)
│   ├── 搜索
│   ├── 话题/标签
│   ├── 热门内容
│   └── 附近的人
├── 个人中心 (Profile)
│   ├── 个人主页
│   ├── 相册/作品集
│   ├── 收藏/点赞
│   └── 设置
├── 内容创作 (Creation)
│   ├── 发布图文
│   ├── 拍摄短视频
│   ├── 写动态/Stories
│   └── 直播
└── 通知 (Notifications)
    ├── 互动通知(赞/评论/转发)
    ├── 系统通知
    └── 私信通知
```

## 使用方式

在开发社交应用UI时，OpenCode 应：

1. **先读取** `design-tokens.md` 获取所有基础设计参数
2. **再查阅** `components.md` 确认组件规格
3. **参考** `patterns.md` 确保交互一致性
4. **最后查阅** `screen-specs.md` 获取具体页面布局

所有代码必须同时提供 SwiftUI 和 Jetpack Compose 两套实现。

---

# 设计令牌 (Design Tokens)

## 1. 颜色系统

### 1.1 品牌主色

| Token名称 | 用途 | 色值(Light) | 色值(Dark) |
|-----------|------|------------|------------|
| `brand.primary` | 主按钮、Tab高亮、链接 | `#FF4757` | `#FF6B7A` |
| `brand.primary.light` | 按压态背景、标签底色 | `#FFF0F1` | `#3D1A1D` |
| `brand.secondary` | 辅助操作、图标 | `#5352ED` | `#7B7AFF` |
| `brand.accent` | 通知红点、重要标记 | `#FF3B30` | `#FF453A` |

### 1.2 功能色

| Token名称 | 用途 | 色值(Light) | 色值(Dark) |
|-----------|------|------------|------------|
| `semantic.success` | 成功状态 | `#34C759` | `#30D158` |
| `semantic.warning` | 警告状态 | `#FF9500` | `#FFD60A` |
| `semantic.error` | 错误状态 | `#FF3B30` | `#FF453A` |
| `semantic.info` | 信息提示 | `#007AFF` | `#0A84FF` |

### 1.3 中性色阶

| Token名称 | 用途 | 色值(Light) | 色值(Dark) |
|-----------|------|------------|------------|
| `neutral.text.primary` | 正文标题 | `#1A1A1A` | `#F5F5F5` |
| `neutral.text.secondary` | 副标题、描述 | `#666666` | `#999999` |
| `neutral.text.tertiary` | 时间戳、提示 | `#999999` | `#666666` |
| `neutral.text.disabled` | 禁用态文字 | `#CCCCCC` | `#444444` |
| `neutral.bg.primary` | 页面主背景 | `#FFFFFF` | `#000000` |
| `neutral.bg.secondary` | 卡片背景 | `#F7F7F7` | `#1C1C1E` |
| `neutral.bg.tertiary` | 输入框背景 | `#F2F2F7` | `#2C2C2E` |
| `neutral.divider` | 分割线 | `#E5E5EA` | `#38383A` |
| `neutral.border` | 边框 | `#D1D1D6` | `#48484A` |

### 1.4 SwiftUI 颜色定义

```swift
import SwiftUI

extension Color {
    static let brandPrimary = Color("BrandPrimary")
    static let brandPrimaryLight = Color("BrandPrimaryLight")
    static let brandSecondary = Color("BrandSecondary")
    static let brandAccent = Color("BrandAccent")
    
    static let semanticSuccess = Color("SemanticSuccess")
    static let semanticWarning = Color("SemanticWarning")
    static let semanticError = Color("SemanticError")
    static let semanticInfo = Color("SemanticInfo")
    
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    static let textDisabled = Color("TextDisabled")
    
    static let bgPrimary = Color("BGPrimary")
    static let bgSecondary = Color("BGSecondary")
    static let bgTertiary = Color("BGTertiary")
    static let divider = Color("Divider")
    static let border = Color("Border")
}
```

> 在 Xcode Asset Catalog 中创建 Color Set，分别设置 Light 和 Dark Appearance。

### 1.5 Jetpack Compose 颜色定义

```kotlin
import androidx.compose.ui.graphics.Color

object AppColors {
    val brandPrimary = Color(0xFFFF4757)
    val brandPrimaryLight = Color(0xFFFFF0F1)
    val brandSecondary = Color(0xFF5352ED)
    val brandAccent = Color(0xFFFF3B30)

    val semanticSuccess = Color(0xFF34C759)
    val semanticWarning = Color(0xFFFF9500)
    val semanticError = Color(0xFFFF3B30)
    val semanticInfo = Color(0xFF007AFF)

    val textPrimaryLight = Color(0xFF1A1A1A)
    val textPrimaryDark = Color(0xFFF5F5F5)
    val textSecondaryLight = Color(0xFF666666)
    val textSecondaryDark = Color(0xFF999999)
    val textTertiaryLight = Color(0xFF999999)
    val textTertiaryDark = Color(0xFF666666)

    val bgPrimaryLight = Color(0xFFFFFFFF)
    val bgPrimaryDark = Color(0xFF000000)
    val bgSecondaryLight = Color(0xFFF7F7F7)
    val bgSecondaryDark = Color(0xFF1C1C1E)
    val bgTertiaryLight = Color(0xFFF2F2F7)
    val bgTertiaryDark = Color(0xFF2C2C2E)
    val dividerLight = Color(0xFFE5E5EA)
    val dividerDark = Color(0xFF38383A)
}
```

---

## 2. 字体排版 (Typography)

### 2.1 字体族

| 平台 | 中文 | 英文/数字 |
|------|------|-----------|
| iOS | 系统默认(PingFang SC) | SF Pro |
| Android | Noto Sans SC | Roboto |

### 2.2 字号层级

| Token名称 | 用途 | iOS (pt) | Android (sp) | 字重 |
|-----------|------|----------|--------------|------|
| `display.large` | 启动页大标题 | 34 | 34 | Bold |
| `display.medium` | 页面主标题 | 28 | 28 | Bold |
| `display.small` | 区块标题 | 22 | 22 | Semibold |
| `headline` | 卡片标题 | 17 | 17 | Semibold |
| `body.large` | 正文(强调) | 17 | 17 | Regular |
| `body.medium` | 正文(默认) | 15 | 15 | Regular |
| `body.small` | 正文(辅助) | 14 | 14 | Regular |
| `caption` | 说明文字、时间戳 | 13 | 13 | Regular |
| `caption.small` | 极小标注 | 11 | 11 | Regular |
| `label` | 按钮、Tab文字 | 16 | 16 | Medium |
| `label.small` | 小按钮、标签 | 14 | 14 | Medium |
| `label.tiny` | 徽章、角标 | 12 | 12 | Semibold |

### 2.3 SwiftUI 字体定义

```swift
import SwiftUI

extension Font {
    static let displayLarge = .system(size: 34, weight: .bold)
    static let displayMedium = .system(size: 28, weight: .bold)
    static let displaySmall = .system(size: 22, weight: .semibold)
    static let headline = .system(size: 17, weight: .semibold)
    static let bodyLarge = .system(size: 17, weight: .regular)
    static let bodyMedium = .system(size: 15, weight: .regular)
    static let bodySmall = .system(size: 14, weight: .regular)
    static let caption = .system(size: 13, weight: .regular)
    static let captionSmall = .system(size: 11, weight: .regular)
    static let label = .system(size: 16, weight: .medium)
    static let labelSmall = .system(size: 14, weight: .medium)
    static let labelTiny = .system(size: 12, weight: .semibold)
}
```

### 2.4 Jetpack Compose 字体定义

```kotlin
import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

val AppTypography = Typography(
    displayLarge = TextStyle(fontSize = 34.sp, fontWeight = FontWeight.Bold),
    displayMedium = TextStyle(fontSize = 28.sp, fontWeight = FontWeight.Bold),
    displaySmall = TextStyle(fontSize = 22.sp, fontWeight = FontWeight.SemiBold),
    headlineMedium = TextStyle(fontSize = 17.sp, fontWeight = FontWeight.SemiBold),
    bodyLarge = TextStyle(fontSize = 17.sp, fontWeight = FontWeight.Normal),
    bodyMedium = TextStyle(fontSize = 15.sp, fontWeight = FontWeight.Normal),
    bodySmall = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Normal),
    labelLarge = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.Medium),
    labelMedium = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Medium),
    labelSmall = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.SemiBold),
)
```

---

## 3. 间距系统 (Spacing)

### 3.1 基础间距

| Token名称 | 值 (pt/dp) | 用途 |
|-----------|-----------|------|
| `space.none` | 0 | 无间距 |
| `space.xxs` | 2 | 极小间距(图标与文字间) |
| `space.xs` | 4 | 最小间距(紧凑元素) |
| `space.sm` | 8 | 小间距(列表内边距) |
| `space.md` | 12 | 中间距(卡片内间距) |
| `space.lg` | 16 | 标准间距(页面水平边距) |
| `space.xl` | 20 | 大间距(区块间距) |
| `space.xxl` | 24 | 超大间距(模块间距) |
| `space.xxxl` | 32 | 页面级间距 |

### 3.2 页面通用间距规则

- **页面水平边距**: `space.lg` (16pt)
- **卡片水平内边距**: `space.lg` (16pt)
- **卡片垂直内边距**: `space.md` (12pt)
- **列表项间距**: `space.sm` (8pt)
- **模块间间距**: `space.xl` (20pt)
- **安全区域**: 遵循系统Safe Area

### 3.3 SwiftUI 间距定义

```swift
import SwiftUI

extension CGFloat {
    static let spaceNone: CGFloat = 0
    static let spaceXXS: CGFloat = 2
    static let spaceXS: CGFloat = 4
    static let spaceSM: CGFloat = 8
    static let spaceMD: CGFloat = 12
    static let spaceLG: CGFloat = 16
    static let spaceXL: CGFloat = 20
    static let spaceXXL: CGFloat = 24
    static let spaceXXXL: CGFloat = 32
}
```

### 3.4 Jetpack Compose 间距定义

```kotlin
import androidx.compose.ui.unit.dp

object Spacing {
    val None = 0.dp
    val XXS = 2.dp
    val XS = 4.dp
    val SM = 8.dp
    val MD = 12.dp
    val LG = 16.dp
    val XL = 20.dp
    val XXL = 24.dp
    val XXXL = 32.dp
}
```

---

## 4. 圆角系统 (Border Radius)

| Token名称 | 值 (pt/dp) | 用途 |
|-----------|-----------|------|
| `radius.none` | 0 | 直角 |
| `radius.xs` | 4 | 小按钮、Tag |
| `radius.sm` | 8 | 输入框、小卡片 |
| `radius.md` | 12 | 标准卡片、弹窗 |
| `radius.lg` | 16 | 大卡片、底部弹窗 |
| `radius.xl` | 20 | 全屏模态视图 |
| `radius.full` | 9999 | 头像、圆形按钮 |

### SwiftUI

```swift
extension CGFloat {
    static let radiusNone: CGFloat = 0
    static let radiusXS: CGFloat = 4
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20
    static let radiusFull: CGFloat = .infinity
}
```

### Jetpack Compose

```kotlin
import androidx.compose.foundation.shape.RoundedCornerShape

object CornerRadius {
    val None = RoundedCornerShape(0.dp)
    val XS = RoundedCornerShape(4.dp)
    val SM = RoundedCornerShape(8.dp)
    val MD = RoundedCornerShape(12.dp)
    val LG = RoundedCornerShape(16.dp)
    val XL = RoundedCornerShape(20.dp)
    val Full = RoundedCornerShape(50)
}
```

---

## 5. 阴影系统 (Elevation)

| Token名称 | iOS Shadow | Android Elevation | 用途 |
|-----------|-----------|-------------------|------|
| `shadow.none` | 无 | 0dp | 扁平元素 |
| `shadow.sm` | y:1 blur:2 opacity:0.08 | 2dp | 卡片(浅色模式) |
| `shadow.md` | y:2 blur:8 opacity:0.12 | 4dp | 浮动按钮 |
| `shadow.lg` | y:4 blur:16 opacity:0.16 | 8dp | 弹窗、下拉菜单 |
| `shadow.xl` | y:8 blur:32 opacity:0.20 | 16dp | 模态视图 |

> **Dark Mode**: 暗色模式下使用描边替代阴影，描边色为 `neutral.border`，宽度 0.5pt/dp

---

## 6. 动效时长 (Motion)

| Token名称 | 时长 | 用途 |
|-----------|------|------|
| `duration.instant` | 100ms | 按钮按压、开关切换 |
| `duration.fast` | 200ms | Tab切换、颜色过渡 |
| `duration.normal` | 300ms | 页面转场(默认) |
| `duration.slow` | 500ms | 展开/折叠动画 |
| `duration.glacial` | 800ms | 全屏模态出现 |

### 缓动曲线

| Token名称 | iOS | Android | 用途 |
|-----------|-----|---------|------|
| `ease.standard` | `.easeInOut` | `EaseInOut` | 通用过渡 |
| `ease.decelerate` | `.easeOut` | `EaseOut` | 元素进入 |
| `ease.accelerate` | `.easeIn` | `EaseIn` | 元素退出 |
| `ease.spring` | Spring(response:0.4, damping:0.8) | `spring(dampingRatio=0.8)` | 弹性反馈 |

---

## 7. 图标系统

### 图标规格

| 尺寸名称 | 尺寸 (pt/dp) | 用途 |
|---------|-------------|------|
| `icon.xs` | 16 | 行内图标 |
| `icon.sm` | 20 | Tab图标、列表图标 |
| `icon.md` | 24 | 标准操作图标 |
| `icon.lg` | 28 | 导航栏图标 |
| `icon.xl` | 32 | 空状态插画 |
| `icon.xxl` | 48 | 功能入口图标 |

### 图标风格

- 使用 SF Symbols (iOS) / Material Symbols (Android)
- 线条风格: Regular weight
- 颜色跟随文字色或使用 `neutral.text.secondary`

---

## 8. 头像尺寸

| 尺寸名称 | 尺寸 (pt/dp) | 用途 |
|---------|-------------|------|
| `avatar.xs` | 24 | 消息列表小头像 |
| `avatar.sm` | 32 | 评论列表头像 |
| `avatar.md` | 40 | 好友列表头像 |
| `avatar.lg` | 48 | 信息流头像 |
| `avatar.xl` | 56 | 个人页小头像 |
| `avatar.xxl` | 80 | 个人页大头像 |
| `avatar.xxxl` | 120 | 个人资料编辑 |


---

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


---

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
