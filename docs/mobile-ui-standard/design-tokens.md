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
