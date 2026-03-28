# 37° 发布记录

- 文档版本: `2026.03.29-r2`
- 对应版本: `0.6.0-dev.1+2026032902`
- 打包时间: `2026-03-29 03:41:58`

## 1. 校验结果

- `flutter analyze` 通过
- `flutter test` 通过
- `npm run smoke`（`local-api`）通过
- `powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-android-release.ps1` 通过

## 2. 产物

- `arm64-v8a`
  - 文件: `codex-one-v0.6.0-dev.1+2026032902-ts20260329-034158-arm64-v8a-release.apk`
  - 大小: `18.53 MB`
- `armeabi-v7a`
  - 文件: `codex-one-v0.6.0-dev.1+2026032902-ts20260329-034158-armeabi-v7a-release.apk`
  - 大小: `16.19 MB`
- `x86_64`
  - 文件: `codex-one-v0.6.0-dev.1+2026032902-ts20260329-034158-x86_64-release.apk`
  - 大小: `19.90 MB`

## 3. 推荐安装包

- 大多数安卓手机建议优先安装 `arm64-v8a` 版本

## 4. 本次版本重点

- 本地 API 默认接管认证与聊天主链
- `local-api` 已支持广场 / 圈子 / 审核 / 后台 API 基础联调
- 消息页新增会话创建、置顶、删除、全部已读
- 聊天页新增表情 / 图片 / 语音 / 视频占位消息快捷发送
