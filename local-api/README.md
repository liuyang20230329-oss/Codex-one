# 37° 本地API服务器

## 🚀 快速开始

### 1. 安装依赖
```bash
cd local-api
npm install
```

### 2. 启动服务器
```bash
npm start
# 或使用开发模式（自动重启）
npm run dev
```

### 3. 访问服务
- **本地地址**: http://localhost:3000
- **健康检查**: http://localhost:3000/health
- **API状态**: http://localhost:3000/api/v1/status

## 📊 数据库配置

### SQLite（默认）
使用SQLite数据库，无需额外安装，数据存储在 `data/37degrees.db`

### MySQL（可选）
修改 `.env` 文件中的配置：
```bash
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your-password
DB_NAME=37degrees_db
```

## 🔑 API端点

### 认证相关
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/logout` - 用户登出
- `GET /api/v1/auth/me` - 获取当前用户信息
- `PUT /api/v1/auth/me` - 更新用户资料
- `POST /api/v1/auth/phone-verify` - 手机号认证
- `POST /api/v1/auth/identity-verify` - 身份证实名
- `POST /api/v1/auth/face-verify` - 人脸认证

### 用户相关
- `GET /api/v1/users/:userId` - 获取用户资料（公开）
- `GET /api/v1/users/me/complete` - 获取当前用户完整资料
- `PUT /api/v1/users/me` - 更新用户资料
- `POST /api/v1/users/me/works` - 添加用户作品
- `DELETE /api/v1/users/me/works/:workId` - 删除用户作品

### 聊天相关
- `GET /api/v1/chat/conversations` - 获取会话列表
- `GET /api/v1/chat/messages/:conversationId` - 获取消息
- `POST /api/v1/chat/messages` - 发送消息
- `POST /api/v1/chat/conversations` - 创建会话
- `DELETE /api/v1/chat/conversations/:conversationId` - 删除会话

### 文件上传
- `POST /api/v1/upload/single` - 单文件上传
- `POST /api/v1/upload/multiple` - 多文件上传
- `POST /api/v1/upload/avatar` - 头像上传
- `POST /api/v1/upload/video` - 视频上传
- `POST /api/v1/upload/audio` - 语音上传
- `DELETE /api/v1/upload/:filename` - 删除文件

## 📝 API使用示例

### 用户注册
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试用户",
    "email": "test@example.com",
    "password": "123456"
  }'
```

### 用户登录
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }'
```

### 获取当前用户信息
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 发送消息
```bash
curl -X POST http://localhost:3000/api/v1/chat/messages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversationId": "concierge",
    "text": "你好！"
  }'
```

## 🔧 配置说明

### 环境变量
创建 `.env` 文件：
```bash
NODE_ENV=development
API_PORT=3000
API_URL=http://localhost:3000

# 数据库配置
DB_TYPE=sqlite
DB_PATH=./data/37degrees.db

# JWT配置
JWT_SECRET=your-secret-key
JWT_EXPIRE=7d

# 文件上传
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760

# CORS配置
CORS_ORIGIN=*
```

### 开发模式
使用nodemon自动重启：
```bash
npm run dev
```

## 🧪 测试API

### 使用curl测试
```bash
# 健康检查
curl http://localhost:3000/health

# API状态
curl http://localhost:3000/api/v1/status

# 测试注册
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试用户",
    "email": "test@example.com",
    "password": "123456"
  }'
```

### 使用Postman测试
1. 导入API端点到Postman
2. 设置环境变量：`base_url = http://localhost:3000`
3. 测试各个API接口

## 📱 连接Flutter应用

### 1. 创建API客户端
在Flutter项目中创建 `lib/config/api_config.dart`：

```dart
class ApiConfig {
  // 本地开发环境
  static const String baseUrl = 'http://localhost:3000';
  
  // 如使用内网穿透
  // static const String baseUrl = 'https://your-ngrok-url.ngrok-free.app';
  
  static const String apiVersion = '/api/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
```

### 2. 创建HTTP客户端
创建 `lib/core/network/http_client.dart`：

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class HttpClient {
  static final _client = http.Client();
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  static Future<dynamic> get(String path) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
    ).timeout(Duration(seconds: ApiConfig.connectTimeout ~/ 1000));
    
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(Duration(seconds: ApiConfig.connectTimeout ~/ 1000));
    
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(Duration(seconds: ApiConfig.connectTimeout ~/ 1000));
    
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
    ).timeout(Duration(seconds: ApiConfig.connectTimeout ~/ 1000));
    
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? '请求失败');
    }
  }
}
```

### 3. 创建认证API客户端
创建 `lib/core/network/auth_api.dart`：

```dart
import '../network/http_client.dart';

class AuthApi {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await HttpClient.post('/api/v1/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await HttpClient.post('/api/v1/auth/login', body: {
      'email': email,
      'password': password,
    });
    
    // 保存token
    if (result['token'] != null) {
      HttpClient.setToken(result['token']);
    }
    
    return result;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await HttpClient.get('/api/v1/auth/me');
  }
}
```

### 4. 更新Android网络权限
修改 `android/app/src/main/AndroidManifest.xml`：

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
        android:usesCleartextTraffic="true">
    </application>
</manifest>
```

## 🌐 内网穿透

### 使用ngrok
```bash
# 安装ngrok
# 下载: https://ngrok.com/download

# 启动ngrok
ngrok http 3000

# 会得到一个外网地址，如：https://abc123.ngrok-free.app
```

### 更新Flutter配置
```dart
// lib/config/api_config.dart
static const String baseUrl = 'https://abc123.ngrok-free.app';
```

## 🔍 调试

### 查看日志
服务器启动后会显示详细日志，包括：
- 数据库连接状态
- API端点列表
- 请求日志
- 错误信息

### 常见问题
1. **端口被占用**: 修改 `.env` 中的 `API_PORT`
2. **数据库错误**: 检查 `data/` 目录权限
3. **CORS错误**: 修改 `.env` 中的 `CORS_ORIGIN`

## 📦 部署到生产环境

### 1. 环境变量
修改 `.env`：
```bash
NODE_ENV=production
JWT_SECRET=使用强随机字符串
CORS_ORIGIN=https://yourdomain.com
```

### 2. 数据库
使用MySQL或其他生产数据库
### 3. 反向代理
使用Nginx等反向代理
### 4. HTTPS
配置SSL证书

## 📄 项目结构

```
local-api/
├── config/
│   └── database.js          # 数据库配置
├── routes/
│   ├── auth.js              # 认证路由
│   ├── user.js              # 用户路由
│   ├── chat.js              # 聊天路由
│   └── upload.js            # 文件上传路由
├── uploads/                # 上传文件目录
├── data/                   # 数据库文件目录
├── .env                    # 环境变量配置
├── package.json            # 项目配置
├── server.js               # 服务器入口
└── README.md              # 项目文档
```

## 🎯 开发计划

- [x] 基础API服务器
- [x] SQLite数据库
- [x] 用户认证
- [x] 用户资料管理
- [x] 聊天功能
- [x] 文件上传
- [ ] WebSocket实时消息
- [ ] 图片压缩
- [ ] 缓存机制
- [ ] 单元测试

## 🚨 注意事项

1. **开发环境**：使用SQLite，便于开发和测试
2. **生产环境**：建议使用MySQL等生产数据库
3. **安全性**：生产环境务必修改JWT_SECRET
4. **性能**：大量用户时考虑使用缓存和CDN
5. **监控**：添加日志监控和错误追踪

## 📞 支持

如有问题，请查看：
- 错误日志：终端输出
- 数据库文件：`data/37degrees.db`
- 上传文件：`uploads/` 目录

---

**祝你开发顺利！** 🚀