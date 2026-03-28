// 简单的API测试脚本
const http = require('http');

const API_URL = 'http://localhost:3000';

function testEndpoint(endpoint, description) {
  return new Promise((resolve, reject) => {
    const url = `${API_URL}${endpoint}`;
    console.log(`\n🧪 测试: ${description}`);
    console.log(`📡 请求: ${url}`);

    http.get(url, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          console.log(`✅ 成功: ${res.statusCode}`);
          console.log(`📄 响应:`, jsonData);
          resolve({ success: true, status: res.statusCode, data: jsonData });
        } catch (e) {
          console.log(`⚠️  非JSON响应: ${data}`);
          resolve({ success: true, status: res.statusCode, data: data });
        }
      });
    }).on('error', (error) => {
      console.error(`❌ 失败:`, error.message);
      reject(error);
    });
  });
}

async function runTests() {
  console.log('='.repeat(50));
  console.log('🚀 开始测试37°本地API服务器');
  console.log('='.repeat(50));

  try {
    // 测试健康检查
    await testEndpoint('/health', '健康检查端点');

    // 测试API状态
    await testEndpoint('/api/v1/status', 'API状态端点');

    // 测试用户注册
    console.log(`\n🧪 测试: 用户注册`);
    console.log(`📡 请求: POST ${API_URL}/api/v1/auth/register`);

    const registerData = JSON.stringify({
      name: '测试用户',
      email: 'test@example.com',
      password: '123456'
    });

    const registerReq = http.request(
      `${API_URL}/api/v1/auth/register`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(registerData)
        }
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => {
          try {
            const jsonData = JSON.parse(data);
            console.log(`✅ 注册成功: ${res.statusCode}`);
            console.log(`📄 响应:`, jsonData);

            if (jsonData.success) {
              const token = jsonData.token;
              console.log(`🔑 Token: ${token.substring(0, 20)}...`);

              // 测试获取用户信息
              console.log(`\n🧪 测试: 获取当前用户信息`);
              console.log(`📡 请求: GET ${API_URL}/api/v1/auth/me`);

              const userReq = http.request(
                `${API_URL}/api/v1/auth/me`,
                {
                  method: 'GET',
                  headers: {
                    'Authorization': `Bearer ${token}`
                  }
                },
                (userRes) => {
                  let userData = '';
                  userRes.on('data', (chunk) => { userData += chunk; });
                  userRes.on('end', () => {
                    try {
                      const userJson = JSON.parse(userData);
                      console.log(`✅ 获取用户成功: ${userRes.statusCode}`);
                      console.log(`📄 用户信息:`, userJson);

                      console.log('\n' + '='.repeat(50));
                      console.log('🎉 所有测试通过！');
                      console.log('='.repeat(50));
                    } catch (e) {
                      console.log(`⚠️  用户数据解析失败`);
                    }
                  });
                }
              );

              userReq.on('error', (error) => {
                console.error(`❌ 获取用户失败:`, error.message);
              });

              userReq.end();
            }
          } else {
            console.log(`⚠️  注册失败:`, jsonData.error);
          }
        } catch (e) {
          console.log(`⚠️  注册响应解析失败`);
        }
      });
    });

    registerReq.on('error', (error) => {
      console.error(`❌ 注册请求失败:`, error.message);
    });

    registerReq.write(registerData);
    registerReq.end();

  } catch (error) {
    console.error('❌ 测试失败:', error);
  }
}

// 等待服务器启动后运行测试
console.log('⏳ 等待服务器启动...');
setTimeout(() => {
  runTests();
}, 2000);