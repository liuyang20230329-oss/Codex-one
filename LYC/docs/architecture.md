# LYC 小宇宙学堂架构说明

## 产品定位

`LYC` 是一个为小朋友设计的“听、读、学”型微信小程序，首版重点不是复杂功能，而是建立一种温暖、轻松、有陪伴感的学习体验。

## 页面结构

### 1. 首页 `pages/home`

职责：

- 展示整体产品气质
- 提供四大内容入口
- 呈现继续学习与推荐内容

### 2. 分类页 `pages/discover`

职责：

- 按内容分类切换
- 浏览每类课程列表
- 进入单个内容详情

### 3. 内容详情页 `pages/tool`

职责：

- 展示单个课程/故事/古诗详情
- 承载播放、跟读、收藏等交互入口
- 呈现分段学习内容

### 4. 成长页 `pages/history`

职责：

- 展示星星、连续学习、周节奏
- 轻量任务与徽章激励

### 5. 家长页 `pages/about`

职责：

- 给家长看关键观察结论
- 给出推荐使用节奏
- 汇总下一步待办与配置项

## 组件设计

### `components/portal-card`

用于首页四大入口卡片展示。

### `components/lesson-card`

用于首页推荐、分类列表、详情页推荐等课程卡片展示。

## 数据层

当前为本地演示数据：

- `CATEGORY_LIST`
- `LESSON_LIST`
- `HOME_PLAYLISTS`
- `GROWTH_PANEL`
- `PARENT_PANEL`

统一位于 `utils/content-data.js`。

## 未来云开发数据建议

建议后续迁移到以下集合：

- `content_categories`
  - 分类信息
- `lesson_contents`
  - 正式内容、音频地址、封面图、标签
- `usage_logs`
  - 学习记录、播放记录、收藏记录
- `user_profiles`
  - 孩子年龄段、偏好、家长设置

## 未来云函数建议

- `getHomepageFeed`
  - 拉取首页推荐与继续学习
- `saveLearningProgress`
  - 保存播放进度、学习时长、星星奖励
- `queryGrowthData`
  - 查询成长页统计和家长端摘要

## 当前实现边界

已完成：

- 页面结构
- 首版 UI 主题
- 本地演示内容
- 关键交互占位

待完成：

- 云开发接入
- 正式音频播放
- 学习记录持久化
- 真正的家长配置能力
- 提审所需素材和合规内容
