# Codex One API 清单

- 文档版本: `2026.03.28-r1`
- App 版本: `0.2.0-dev.1+20260327`
- 日期: `2026-03-28`
- 状态: `Draft`

## 1. 当前说明

当前仓库还没有自建服务端 API，登录注册流程主要通过客户端接 Firebase Auth，未配置真实 Firebase 时使用 Demo 认证。

因此，下面这份清单属于服务端 `API V1` 规划稿，用来指导后续后端实现与前后端联调。

## 2. P0 认证 API

### `POST /api/v1/auth/register`

- 用途: 用户注册
- 鉴权: 否
- 请求体:
  - `email: string`
  - `password: string`
  - `nickname: string`
- 成功返回:
  - `userId`
  - `email`
  - `nickname`
  - `accessToken`
  - `refreshToken`

### `POST /api/v1/auth/login`

- 用途: 用户登录
- 鉴权: 否
- 请求体:
  - `email: string`
  - `password: string`
- 成功返回:
  - `userId`
  - `email`
  - `nickname`
  - `accessToken`
  - `refreshToken`

### `POST /api/v1/auth/logout`

- 用途: 用户退出登录
- 鉴权: 是
- 请求体:
  - `refreshToken: string`
- 成功返回:
  - `success: true`

### `POST /api/v1/auth/refresh`

- 用途: 刷新登录令牌
- 鉴权: 否
- 请求体:
  - `refreshToken: string`
- 成功返回:
  - `accessToken`
  - `refreshToken`
  - `expiresIn`

### `GET /api/v1/users/me`

- 用途: 获取当前登录用户资料
- 鉴权: 是
- 成功返回:
  - `userId`
  - `email`
  - `nickname`
  - `avatarUrl`
  - `bio`
  - `createdAt`

### `PATCH /api/v1/users/me/profile`

- 用途: 更新个人资料
- 鉴权: 是
- 请求体:
  - `nickname?: string`
  - `avatarUrl?: string`
  - `bio?: string`
- 成功返回:
  - 更新后的用户资料对象

## 3. P1 文字社交 API

### `GET /api/v1/conversations`

- 用途: 获取会话列表
- 鉴权: 是
- 成功返回:
  - 会话数组
  - 每个会话包含 `conversationId`、`type`、`title`、`lastMessage`、`unreadCount`

### `POST /api/v1/conversations`

- 用途: 创建单聊或群聊
- 鉴权: 是
- 请求体:
  - `type: direct | group`
  - `memberUserIds: string[]`
  - `title?: string`
- 成功返回:
  - `conversationId`

### `GET /api/v1/conversations/{conversationId}/messages`

- 用途: 拉取消息列表
- 鉴权: 是
- 查询参数:
  - `cursor?: string`
  - `limit?: number`
- 成功返回:
  - 消息数组
  - 下一页游标

### `POST /api/v1/conversations/{conversationId}/messages`

- 用途: 发送消息
- 鉴权: 是
- 请求体:
  - `type: text | image | voice | video | system`
  - `text?: string`
  - `mediaUrl?: string`
  - `durationMs?: number`
- 成功返回:
  - `messageId`
  - `createdAt`
  - `deliveryStatus`

## 4. P2 语音社交 API

### `POST /api/v1/voice-rooms`

- 用途: 创建语音房
- 鉴权: 是
- 请求体:
  - `roomName: string`
  - `isPrivate: boolean`
- 成功返回:
  - `roomId`
  - `rtcChannel`

### `POST /api/v1/voice-rooms/{roomId}/join`

- 用途: 加入语音房
- 鉴权: 是
- 成功返回:
  - `roomId`
  - `rtcToken`
  - `memberRole`

### `POST /api/v1/voice-rooms/{roomId}/leave`

- 用途: 退出语音房
- 鉴权: 是
- 成功返回:
  - `success: true`

## 5. P2 视频社交 API

### `POST /api/v1/video-calls`

- 用途: 发起视频通话
- 鉴权: 是
- 请求体:
  - `targetUserId: string`
  - `callType: one_to_one | multi_user`
- 成功返回:
  - `callId`
  - `rtcChannel`
  - `rtcToken`

### `POST /api/v1/video-calls/{callId}/accept`

- 用途: 接听视频通话
- 鉴权: 是
- 成功返回:
  - `success: true`

### `POST /api/v1/video-calls/{callId}/end`

- 用途: 结束视频通话
- 鉴权: 是
- 成功返回:
  - `success: true`

## 6. 今天建议先落地的接口顺序

优先级建议如下：

1. `POST /api/v1/auth/register`
2. `POST /api/v1/auth/login`
3. `GET /api/v1/users/me`
4. `PATCH /api/v1/users/me/profile`
5. `POST /api/v1/auth/logout`

这五个接口足够支撑登录注册、资料初始化和首页展示。
