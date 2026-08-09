![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![watchOS](https://img.shields.io/badge/watchOS-10+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

# WatchJM

Apple Watch 客户端，配合 [JMComic_Server_API](https://github.com/qwasd7680/JMComic_Server_API) 使用。

## 功能

- 查看排行榜（每日 / 每周 / 每月）
- 搜索本子（支持中文关键词、分页）
- 查看本子详情（标签、浏览数、点赞数、页数）
- 下载本子到本地（WebSocket 异步流程）
- 离线阅读已下载的本子（双指缩放、逐页浏览）
- 服务器延迟检测

## 架构

采用 **MVVM + @Observable** 架构（watchOS 10+）：

```
WatchJM Watch App/
├── App/                 # 入口
├── Entity/              # 数据模型 (Album)
├── Foundation/          # 网络层 (Net)、本地存储 (File)
├── ViewModels/          # @Observable 视图模型
│   ├── RankingsViewModel
│   ├── SearchViewModel
│   ├── DetailViewModel
│   ├── DownloadedViewModel
│   └── SettingsViewModel
├── View/                # SwiftUI 视图
│   ├── ContentView      # 主 TabView
│   ├── SearchView       # 搜索
│   ├── DetailView       # 详情 + 下载
│   ├── DownloadedView   # 已下载列表
│   ├── SettingView      # 设置（API URL）
│   ├── ComicReaderView  # 阅读器
│   └── ZoomableImageView # 缩放图片
└── Assets.xcassets
```

## 构建

1. 克隆仓库
2. 用 Xcode 打开 `WatchJM.xcodeproj`
3. 选择 Apple Watch 模拟器或真机
4. ⌘R 运行

**要求：**
- Xcode 16+
- watchOS 10+

## 依赖

| 包 | 用途 |
|---|---|
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | JSON 解析 |
| [Cepheus](https://github.com/Qastor-Studio/Cepheus) | UI 组件 |
| [Zip](https://github.com/marmelroy/Zip) | ZIP 解压 |
| [SDWebImageWebPCoder](https://github.com/SDWebImage/SDWebImageWebPCoder) | WebP 解码 |
| [SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI) | 异步图片加载 |

## 测试

在 Xcode 中添加 Unit Testing Bundle target 后，运行 ⌘U：

- `AlbumTests` — 数据模型 Codable 测试（无需网络）
- `FileManagerTests` — 本地存储测试（无需网络）
- `NetworkTests` — API 集成测试（需要网络）

## 配置

默认 API 地址：`https://qwasd12w-jmcomic-api.hf.space/v1`

可在 Settings 页面修改。支持任何部署方式的 JMComic_Server_API 实例（本地、Docker、HuggingFace Space）。

## 许可证

MIT License
