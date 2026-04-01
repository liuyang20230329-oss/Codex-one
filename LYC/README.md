# LYC 小宇宙学堂

`LYC` 是一个面向儿童启蒙学习的微信小程序演示项目，首版聚焦 4 类内容：

- 英语跟读
- 儿歌乐园
- 诗词花园
- 探索故事馆

当前版本已经完成一套可直接在微信开发者工具中预览的前端演示骨架，适合继续接入正式内容、音频资源和云开发能力。

## 已实现内容

- 首页：探索型学习入口、继续学习、今日推荐、睡前轻听
- 分类页：四大内容分类切换与列表展示
- 详情页：播放/跟读/收藏交互占位、分段学习展示
- 成长页：星星激励、周进度、任务、徽章
- 家长页：本周观察、使用建议、家长提醒、待办清单
- 演示数据：英语、儿歌、唐诗、科技/历史故事样例内容

## 项目结构

```text
LYC/
├─ app.js
├─ app.json
├─ app.wxss
├─ components/
│  ├─ lesson-card/
│  └─ portal-card/
├─ docs/
│  └─ architecture.md
├─ pages/
│  ├─ about/      # 家长页
│  ├─ discover/   # 分类页
│  ├─ history/    # 成长页
│  ├─ home/       # 首页
│  └─ tool/       # 内容详情页
└─ utils/
   └─ content-data.js
```

## 当前状态

- 已配置 `AppID`
- 已安装微信开发者工具
- 还未接入正式云环境 ID
- 页面内容为演示数据，适合先确认产品方向和视觉风格
- 已补充本地媒体预处理方案和本地媒体服务，方便开发阶段播放音频素材

## 下一步建议

详细待办见 [NEXT-STEPS.md](/D:/Codex/LYC/NEXT-STEPS.md)。

## 本地音频开发

- 预处理脚本：[prepare-local-media.ps1](/D:/Codex/LYC/scripts/prepare-local-media.ps1)
- 本地媒体服务启动脚本：[start-local-media-server.ps1](/D:/Codex/LYC/scripts/start-local-media-server.ps1)
- 媒体服务脚本：[local-media-server.js](/D:/Codex/LYC/scripts/local-media-server.js)

当前这套方案适合开发者工具本地调试：

- `MP3` 直接整理成标准英文文件名
- `M4B` 已转换为 `M4A`
- 小程序详情页读取本地媒体服务地址进行播放

后续如果要真机预览和上线，建议把 `media/processed` 里的文件上传到云存储或 CDN，再把 `audioUrl` 换成正式 HTTPS 地址。
