# Codex One 需求文档入口

- 文档版本: `2026.03.29-r1`
- 适用分支: `2026.3.27`
- 当前 App 版本: `0.4.0-dev.2+2026032823`
- 文档目标:
  - 帮你按模块整理需求
  - 帮你线下补充交互说明
  - 帮我后续按任务直接开发

## 建议使用顺序

1. 先看 [01-module-map.md](/D:/Codex/docs/requirements/01-module-map.md)
2. 再补 [02-global-rules.md](/D:/Codex/docs/requirements/02-global-rules.md)
3. 再补品牌和后台模板
4. 然后按模块分别补文档
5. 最后按 [99-task-handoff-template.md](/D:/Codex/docs/requirements/99-task-handoff-template.md) 给我拆任务

## 补充文档

- [03-brand-and-app-identity.md](/D:/Codex/docs/requirements/03-brand-and-app-identity.md)
- [04-admin-backend-template.md](/D:/Codex/docs/requirements/04-admin-backend-template.md)

## 模块文档

- [10-auth-and-identity.md](/D:/Codex/docs/requirements/modules/10-auth-and-identity.md)
- [20-square.md](/D:/Codex/docs/requirements/modules/20-square.md)
- [30-circle.md](/D:/Codex/docs/requirements/modules/30-circle.md)
- [40-messages-and-chat.md](/D:/Codex/docs/requirements/modules/40-messages-and-chat.md)
- [50-profile-and-settings.md](/D:/Codex/docs/requirements/modules/50-profile-and-settings.md)
- [60-common-capabilities.md](/D:/Codex/docs/requirements/modules/60-common-capabilities.md)

## 你补文档时的原则

- 一次只补一个模块，避免混写
- 优先补“必须有”的交互，不用一开始写太全
- 每个页面都写清楚入口、操作、状态、跳转、异常
- 如果你暂时没想好，直接写“待定”，不要空着
- 你可以写口语，我会帮你转成开发任务

## 我读任务时最看重的信息

- 这个页面解决什么问题
- 用户从哪里进入
- 页面上有哪些内容块
- 每个按钮点了以后发生什么
- 加载中、空状态、失败状态怎么显示
- 字段怎么校验
- 哪些是必须今天完成，哪些可以延后
