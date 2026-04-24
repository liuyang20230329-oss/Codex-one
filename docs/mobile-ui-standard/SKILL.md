---
name: social-mobile-ui-standard
description: 综合型社交平台移动端UI设计标准与实现规范(SwiftUI/Kotlin原生)。涵盖设计令牌、组件库、交互模式、页面规格。当用户要求构建社交类App的UI、页面、组件时自动加载此规范。
license: MIT
compatibility: opencode
metadata:
  category: ui-design-system
  platform: ios-android-native
  stack: swiftui-jetpack-compose
  app_type: social-platform
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
