const cloud = require('wx-server-sdk');

cloud.init({
  env: cloud.DYNAMIC_CURRENT_ENV
});

exports.main = async function () {
  return {
    ok: true,
    message: 'cloud function is ready',
    timestamp: Date.now()
  };
};
