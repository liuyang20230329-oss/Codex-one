# 37° 现阶段 API 文档

更新日期: `2026-04-02`

适用代码基线:

- 分支: `master`
- 提交: `2da139a`

服务信息:

- 默认 HTTP: `http://127.0.0.1:3001`
- Health: `GET /health`
- Status: `GET /api/v1/status`
- WebSocket: `GET /ws/chat?token=<JWT>`

## 1. 通用规则

### 1.1 认证方式

除登录注册、健康检查外，其余业务接口默认要求:

```http
Authorization: Bearer <JWT>
```

### 1.2 返回格式

成功返回:

```json
{
  "success": true
}
```

或:

```json
{
  "user": {}
}
```

失败返回:

```json
{
  "error": "错误信息"
}
```

### 1.3 当前主要对象

#### User

```json
{
  "id": "user-id",
  "name": "刘洋",
  "email": "13800138000@37degrees.local",
  "phoneNumber": "13800138000",
  "maskedPhoneNumber": "138****8000",
  "avatarKey": "aurora",
  "gender": "undisclosed",
  "birthYear": 2000,
  "birthMonth": 10,
  "city": "上海",
  "signature": "这个人很酷，还没有留下签名。",
  "introVideoTitle": "还没有上传视频介绍",
  "introVideoSummary": "后续可以用一段视频介绍自己，让更多人更快认识你。",
  "phoneStatus": "verified",
  "identityStatus": "verified",
  "faceStatus": "verified",
  "legalName": "刘洋",
  "maskedIdNumber": "3101********1234",
  "faceMatchScore": 0.986,
  "membershipLevel": "standard",
  "isOnline": true,
  "activityScore": 75,
  "works": []
}
```

#### Conversation

```json
{
  "id": "conversation-id",
  "title": "37° 向导",
  "subtitle": "认证、资料与权限提醒",
  "categoryLabel": "系统",
  "segment": "system",
  "lastMessagePreview": "欢迎来到 37°。",
  "unreadCount": 1,
  "isPinned": true,
  "isOnline": true,
  "createdAt": "2026-04-02T00:00:00.000Z",
  "updatedAt": "2026-04-02T00:00:00.000Z"
}
```

#### Message

```json
{
  "id": "message-id",
  "conversationId": "conversation-id",
  "senderId": "user-id",
  "senderName": "刘洋",
  "text": "你好",
  "type": "text",
  "deliveryStatus": "Delivered",
  "mediaUrl": null,
  "metadataLabel": null,
  "isRecalled": false,
  "createdAt": "2026-04-02T00:00:00.000Z"
}
```

#### Circle Post

```json
{
  "id": "post-id",
  "authorName": "林雾",
  "location": "上海·徐汇",
  "content": "今晚在武康路散步。",
  "visibility": "public",
  "attachments": ["夜景图", "徐汇"],
  "media": [
    {
      "media_type": "image",
      "url": "/uploads/sample.jpg",
      "label": "夜景图"
    }
  ],
  "verificationLabel": "真人",
  "distance": "1.5km",
  "likes": 12,
  "comments": 3,
  "createdAt": "2026-04-02T00:00:00.000Z"
}
```

## 2. 系统状态接口

### `GET /health`

说明:

- 服务存活检查
- 不需要登录

返回:

```json
{
  "status": "ok",
  "service": "37degrees-local-api",
  "mode": "sqlite"
}
```

### `GET /api/v1/status`

说明:

- 返回服务版本和资源组
- 不需要登录

## 3. 认证接口

### `POST /api/v1/auth/sms/send`

说明:

- 发送调试短信验证码
- 目前返回固定 `debugCode`

请求体:

```json
{
  "phoneNumber": "13800138000",
  "purpose": "register"
}
```

用途值:

- `register`
- `verify-phone`
- `general`

### `POST /api/v1/auth/register`

说明:

- 手机号注册

请求体:

```json
{
  "name": "刘洋",
  "phoneNumber": "13800138000",
  "smsCode": "246810",
  "password": "Password123!"
}
```

返回:

- `user`
- `token`

### `POST /api/v1/auth/login`

说明:

- 手机号密码登录

请求体:

```json
{
  "phoneNumber": "13800138000",
  "password": "Password123!"
}
```

返回:

- `user`
- `token`

### `GET /api/v1/auth/me`

说明:

- 获取当前登录用户

### `POST /api/v1/auth/phone/confirm`

说明:

- 确认手机号认证

请求体:

```json
{
  "sessionId": "sms-session-id",
  "phoneNumber": "13800138000",
  "code": "246810"
}
```

返回:

- `user`

### `POST /api/v1/auth/password-reset/request`

说明:

- 请求重置密码验证码
- 当前前端仓库已支持调用，但页面未暴露入口

### `POST /api/v1/auth/password-reset/confirm`

说明:

- 完成重置密码

请求体:

```json
{
  "phoneNumber": "13800138000",
  "code": "246810",
  "newPassword": "NewPassword123!"
}
```

### `POST /api/v1/auth/social/wechat`

说明:

- 微信登录占位接口
- 当前固定返回 `501`

### `POST /api/v1/auth/social/qq`

说明:

- QQ 登录占位接口
- 当前固定返回 `501`

### `POST /api/v1/auth/social/bind`

说明:

- 绑定第三方平台

请求体:

```json
{
  "provider": "wechat",
  "providerUid": "openid-or-unionid"
}
```

### `POST /api/v1/auth/social/unbind`

说明:

- 解绑第三方平台

### `POST /api/v1/auth/logout`

说明:

- 登出

## 4. 用户与账号中心接口

### `GET /api/v1/users/me/complete`

说明:

- 获取完整用户资料

### `PUT /api/v1/users/me/profile`

说明:

- 更新个人资料
- 同时支持覆盖 `works`
- 修改头像会自动重置本人头像认证
- 性别仅允许在当前值为 `undisclosed` 时首次设置

请求体支持字段:

- `name`
- `avatarKey`
- `gender`
- `birthYear`
- `birthMonth`
- `city`
- `signature`
- `introVideoTitle`
- `introVideoSummary`
- `works`

### `GET /api/v1/users/me/settings`

说明:

- 获取隐私、通知和缓存占位信息

### `PUT /api/v1/users/me/settings`

说明:

- 保存隐私相关设置

请求体:

```json
{
  "friendsOnly": false,
  "allowSquareExposure": true,
  "preferVerifiedUsers": true
}
```

### `GET /api/v1/users/me/devices`

说明:

- 获取最近登录设备列表

### `POST /api/v1/users/me/devices/:deviceId/revoke`

说明:

- 撤销设备会话

### `GET /api/v1/users/me/blacklist`

说明:

- 获取黑名单列表

### `POST /api/v1/users/me/blacklist`

说明:

- 新增黑名单

请求体:

```json
{
  "targetUserId": "target-user-id"
}
```

### `DELETE /api/v1/users/me/blacklist/:targetUserId`

说明:

- 取消拉黑

### `POST /api/v1/users/me/works`

说明:

- 新增作品

请求体:

```json
{
  "type": "voice",
  "title": "晚安电台",
  "summary": "一段语音作品",
  "mediaUrl": "https://example.com/audio.mp3",
  "duration": 18,
  "isPinned": false
}
```

### `DELETE /api/v1/users/me/works/:workId`

说明:

- 删除作品

### `POST /api/v1/users/me/cancel`

说明:

- 注销账号
- 当前为软删除，返回冷静期结束时间

### `GET /api/v1/users/:userId`

说明:

- 获取用户公开资料详情

## 5. 审核接口

### `GET /api/v1/reviews/summary`

说明:

- 返回当前用户认证状态摘要

### `POST /api/v1/reviews/identity`

说明:

- 提交身份证认证
- 当前本地开发环境自动通过

请求体:

```json
{
  "legalName": "刘洋",
  "idNumber": "310101200001011234"
}
```

### `POST /api/v1/reviews/face`

说明:

- 提交本人头像认证
- 当前本地开发环境自动通过

## 6. 聊天接口

### `GET /api/v1/chat/conversations`

说明:

- 获取当前用户会话列表
- 如果用户还没有会话，会自动种子生成系统会话和演示关系会话

### `POST /api/v1/chat/conversations`

说明:

- 创建会话

请求体:

```json
{
  "title": "今晚聊聊",
  "subtitle": "刚刚创建",
  "categoryLabel": "私聊",
  "segment": "friends"
}
```

### `PATCH /api/v1/chat/conversations/:conversationId/pin`

说明:

- 置顶 / 取消置顶

### `POST /api/v1/chat/conversations/read-all`

说明:

- 所有会话标记已读

### `POST /api/v1/chat/conversations/:conversationId/read`

说明:

- 单会话标记已读

### `DELETE /api/v1/chat/conversations/:conversationId`

说明:

- 删除会话

### `GET /api/v1/chat/messages/:conversationId`

说明:

- 获取会话消息列表

### `POST /api/v1/chat/messages`

说明:

- 发送消息
- 非系统会话要求用户手机号已认证

请求体:

```json
{
  "conversationId": "conversation-id",
  "text": "你好",
  "type": "text",
  "mediaUrl": null,
  "metadataLabel": null
}
```

当前支持 `type`:

- `text`
- `image`
- `voice`
- `emoji`
- `video`
- `location`
- `forwarded`
- `system`

### `GET /api/v1/chat/privacy`

说明:

- 获取聊天隐私设置

### `PUT /api/v1/chat/privacy`

说明:

- 保存聊天隐私设置

请求体:

```json
{
  "friendsOnly": false,
  "allowSquareExposure": true,
  "preferVerifiedUsers": true
}
```

## 7. 广场接口

### `GET /api/v1/square/banner`

说明:

- 获取 Banner 列表

### `GET /api/v1/square/notices`

说明:

- 获取平台通知列表

### `GET /api/v1/square/users`

说明:

- 获取广场用户推荐列表

支持查询参数:

- `region`
- `gender`
- `membershipLevel`
- `verifiedOnly=true`
- `onlineOnly=true`
- `search`

### `POST /api/v1/square/filters`

说明:

- 保存广场筛选条件

### `GET /api/v1/square/filters`

说明:

- 获取已保存的筛选条件

## 8. 圈子接口

### `GET /api/v1/circle/posts`

说明:

- 获取圈子动态列表

### `GET /api/v1/circle/posts/:postId`

说明:

- 获取动态详情和评论

### `POST /api/v1/circle/posts`

说明:

- 发布动态

请求体:

```json
{
  "location": "上海·徐汇",
  "content": "今晚在附近散步",
  "visibility": "public",
  "attachments": [
    {
      "type": "image",
      "url": "https://example.com/image.jpg",
      "label": "图片 1"
    }
  ]
}
```

### `PUT /api/v1/circle/posts/:postId`

说明:

- 编辑动态

### `POST /api/v1/circle/posts/:postId/comments`

说明:

- 发表评论或回复

请求体:

```json
{
  "content": "留下一条评论",
  "parentCommentId": null
}
```

### `POST /api/v1/circle/posts/:postId/reports`

说明:

- 举报动态

## 9. 通知接口

### `GET /api/v1/notifications`

说明:

- 获取当前用户通知列表
- 首次访问时会自动生成种子通知

### `PUT /api/v1/notifications/:notificationId/read`

说明:

- 单条已读

### `PUT /api/v1/notifications/read-all`

说明:

- 全部已读

## 10. 搜索接口

### `GET /api/v1/search/users?q=关键词`

说明:

- 搜索用户
- 在 `name`、`signature`、`city` 范围内模糊匹配

## 11. 上传接口

### `POST /api/v1/upload/single`

字段:

- `file`

### `POST /api/v1/upload/multiple`

字段:

- `files`

### `POST /api/v1/upload/avatar`

字段:

- `avatar`

### `POST /api/v1/upload/video`

字段:

- `video`

### `POST /api/v1/upload/audio`

字段:

- `audio`

### `DELETE /api/v1/upload/:filename`

说明:

- 删除已上传文件

上传成功返回对象:

```json
{
  "filename": "uuid.jpg",
  "originalName": "origin.jpg",
  "mimetype": "image/jpeg",
  "size": 102400,
  "url": "http://127.0.0.1:3001/uploads/uuid.jpg"
}
```

## 12. 后台接口

### `GET /api/v1/admin/dashboard`

说明:

- 获取后台概览指标

### `GET /api/v1/admin/users`

说明:

- 获取用户列表

### `GET /api/v1/admin/reviews`

说明:

- 获取身份认证与人脸认证审核记录

### `GET /api/v1/admin/banners`

说明:

- 获取 Banner 管理列表

### `GET /api/v1/admin/logs`

说明:

- 获取审计日志

## 13. WebSocket 文档

连接方式:

```text
ws://127.0.0.1:3001/ws/chat?token=<JWT>
```

说明:

- token 通过 query 参数传入
- 鉴权成功后服务端会先返回 `connected`

当前事件:

| kind | 说明 |
| --- | --- |
| `connected` | WebSocket 已连通 |
| `conversation-created` | 创建会话 |
| `conversation-updated` | 置顶等会话变更 |
| `conversation-read` | 单会话已读 |
| `conversation-read-all` | 全部已读 |
| `conversation-deleted` | 删除会话 |
| `message-created` | 有新消息 |

## 14. 当前前端实际接入状态

已经被 Flutter 主流程真实接入的 API:

1. `/api/v1/auth/login`
2. `/api/v1/auth/register`
3. `/api/v1/auth/sms/send`
4. `/api/v1/auth/phone/confirm`
5. `/api/v1/auth/password-reset/*`
6. `/api/v1/auth/me`
7. `/api/v1/auth/logout`
8. `/api/v1/users/me/profile`
9. `/api/v1/reviews/identity`
10. `/api/v1/reviews/face`
11. `/api/v1/chat/*`
12. `/ws/chat`

后端已提供但 Flutter 页面暂未接通的 API:

1. `/api/v1/square/*`
2. `/api/v1/circle/*`
3. `/api/v1/notifications/*`
4. `/api/v1/users/me/settings`
5. `/api/v1/users/me/devices`
6. `/api/v1/users/me/blacklist`
7. `/api/v1/users/me/works`
8. `/api/v1/users/me/cancel`
9. `/api/v1/search/*`
10. `/api/v1/upload/*`
11. `/api/v1/admin/*`

## 16. 2026-04-09 圈子接口接入说明

当前 Flutter 移动端已完成以下圈子接口接入：

1. `GET /api/v1/circle/posts`
2. `GET /api/v1/circle/posts/:postId`
3. `POST /api/v1/circle/posts`
4. `POST /api/v1/circle/posts/:postId/comments`
5. `POST /api/v1/circle/posts/:postId/reports`

当前移动端对这些接口的使用方式如下：

1. 圈子列表页加载动态流时调用 `GET /api/v1/circle/posts`
2. 动态详情页打开时调用 `GET /api/v1/circle/posts/:postId`
3. 发表评论或回复评论时调用 `POST /api/v1/circle/posts/:postId/comments`
4. 举报动态时调用 `POST /api/v1/circle/posts/:postId/reports`
5. 评论提交成功后，移动端会重新拉取一次详情，保证评论数量与评论列表同步刷新
