# Codex One 数据库表清单

- 文档版本: `2026.03.28-r1`
- App 版本: `0.2.0-dev.1+20260327`
- 日期: `2026-03-28`
- 状态: `Draft`
- 建议数据库: `PostgreSQL`

## 1. 当前说明

当前项目尚未接入自建业务数据库，认证身份建议继续由 `Firebase Authentication` 承担。

也就是说：

- 不在业务数据库保存明文密码
- 不在业务数据库保存密码哈希
- 用户登录主身份可使用 `firebase_uid` 进行绑定

下面这份表清单属于业务数据库 `Schema V1` 设计草稿。

## 2. P0 核心表

### `user_profiles`

- 用途: 用户基础资料主表
- 关键字段:
  - `id uuid pk`
  - `firebase_uid varchar(128) unique not null`
  - `email varchar(255) unique not null`
  - `nickname varchar(50) not null`
  - `avatar_url text null`
  - `bio varchar(160) null`
  - `status smallint not null default 1`
  - `created_at timestamptz not null`
  - `updated_at timestamptz not null`

### `user_settings`

- 用途: 用户隐私与通知设置
- 关键字段:
  - `user_id uuid pk`
  - `allow_stranger_message boolean not null default true`
  - `allow_voice_invite boolean not null default true`
  - `allow_video_invite boolean not null default true`
  - `push_enabled boolean not null default true`
  - `language_code varchar(16) not null default 'zh-CN'`
  - `updated_at timestamptz not null`

### `user_devices`

- 用途: 记录用户登录设备与推送令牌
- 关键字段:
  - `id uuid pk`
  - `user_id uuid not null`
  - `platform varchar(16) not null`
  - `device_model varchar(100) null`
  - `push_token text null`
  - `last_active_at timestamptz not null`
  - `created_at timestamptz not null`

## 3. P1 文字社交表

### `friendships`

- 用途: 好友关系与申请状态
- 关键字段:
  - `id uuid pk`
  - `user_id uuid not null`
  - `friend_user_id uuid not null`
  - `status varchar(20) not null`
  - `created_at timestamptz not null`
  - `updated_at timestamptz not null`

### `conversations`

- 用途: 会话主表
- 关键字段:
  - `id uuid pk`
  - `type varchar(20) not null`
  - `title varchar(100) null`
  - `created_by uuid not null`
  - `last_message_id uuid null`
  - `created_at timestamptz not null`
  - `updated_at timestamptz not null`

### `conversation_members`

- 用途: 会话成员表
- 关键字段:
  - `id uuid pk`
  - `conversation_id uuid not null`
  - `user_id uuid not null`
  - `member_role varchar(20) not null default 'member'`
  - `mute_until timestamptz null`
  - `joined_at timestamptz not null`

### `messages`

- 用途: 消息主表
- 关键字段:
  - `id uuid pk`
  - `conversation_id uuid not null`
  - `sender_user_id uuid not null`
  - `message_type varchar(20) not null`
  - `text_content text null`
  - `media_url text null`
  - `duration_ms integer null`
  - `delivery_status varchar(20) not null default 'sent'`
  - `created_at timestamptz not null`

## 4. P2 语音社交表

### `voice_rooms`

- 用途: 语音房主表
- 关键字段:
  - `id uuid pk`
  - `owner_user_id uuid not null`
  - `room_name varchar(100) not null`
  - `rtc_channel varchar(100) not null`
  - `room_status varchar(20) not null`
  - `started_at timestamptz null`
  - `ended_at timestamptz null`
  - `created_at timestamptz not null`

### `voice_room_members`

- 用途: 语音房成员与麦位状态
- 关键字段:
  - `id uuid pk`
  - `room_id uuid not null`
  - `user_id uuid not null`
  - `seat_no integer null`
  - `member_role varchar(20) not null`
  - `mic_status varchar(20) not null`
  - `joined_at timestamptz not null`
  - `left_at timestamptz null`

## 5. P2 视频社交表

### `video_calls`

- 用途: 视频通话主表
- 关键字段:
  - `id uuid pk`
  - `initiator_user_id uuid not null`
  - `target_user_id uuid null`
  - `call_type varchar(20) not null`
  - `rtc_channel varchar(100) not null`
  - `call_status varchar(20) not null`
  - `started_at timestamptz null`
  - `ended_at timestamptz null`
  - `created_at timestamptz not null`

### `video_call_members`

- 用途: 多人视频通话参与人记录
- 关键字段:
  - `id uuid pk`
  - `call_id uuid not null`
  - `user_id uuid not null`
  - `joined_at timestamptz not null`
  - `left_at timestamptz null`

## 6. 推荐索引

- `user_profiles(firebase_uid)`
- `user_profiles(email)`
- `friendships(user_id, status)`
- `conversations(updated_at)`
- `conversation_members(conversation_id, user_id)`
- `messages(conversation_id, created_at desc)`
- `voice_room_members(room_id, joined_at)`
- `video_call_members(call_id, user_id)`

## 7. 今天的数据库结论

今天这版最小可用数据库范围建议先只落这三张表：

1. `user_profiles`
2. `user_settings`
3. `user_devices`

如果下一步开始做聊天，再继续增加：

1. `conversations`
2. `conversation_members`
3. `messages`
