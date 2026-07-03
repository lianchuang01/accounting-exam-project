# 会计等级考试智能刷题APP 🐉

基于 Flutter 开发的跨平台会计考试刷题应用。

## 快速开始

### GitHub Actions（一键编译APK）

1. Fork/推送代码到 GitHub 仓库
2. 进入 Actions → **Build Flutter APK** → **Run workflow**
3. 选择 `debug` 或 `release` 模式
4. 等待几分钟，下载 Artifacts 里的 APK 直接安装到手机

### 本地编译

```bash
# 前提：安装 Flutter 3.29+ 和 Android Studio
flutter pub get
flutter build apk --debug
```

APK 位置：`build/app/outputs/flutter-apk/app-debug.apk`

## 技术栈

- **前端**: Flutter 3.29 / Dart 3.7
- **状态管理**: Provider
- **网络请求**: Dio + JWT 认证
- **图表**: fl_chart（雷达图、柱状图、曲线图）
- **语音**: flutter_tts（错题朗读）

## 功能清单

| 模块 | 功能 |
|------|------|
| 学员端 | 注册/登录、仿真考试、答题计时、自动交卷、答案对照、错题本、语音朗读、能力报告（雷达图/柱状图/曲线图）、自适应专项练习 |
| 管理端 | 题库管理、Excel批量导入、知识点标签、试卷配置、权重配置、学员数据查看与导出 |
| 核心算法 | 考点权重计算、仿真试卷生成、自适应70/30配比出题、判分引擎、知识点等级划分 |

## 后端

后端项目：`accounting-exam-backend/`（Java 17 + Spring Boot 3.2.5）

## 项目结构

```
lib/
├── main.dart                    # 入口 + Provider + 路由
├── config/                      # 主题、API配置、路由
├── models/                      # 数据模型
├── services/                    # API 服务层
├── providers/                   # 状态管理
├── screens/                     # 所有页面
│   ├── auth/                    # 登录/注册
│   ├── home/                    # 首页仪表盘
│   ├── exam/                    # 考试/答题/结果
│   ├── wrong_book/              # 错题本
│   ├── report/                  # 能力分析报告
│   ├── adaptive/                # 自适应练习
│   └── admin/                   # 管理后台
└── widgets/                     # 可复用组件
```

## License

MIT
