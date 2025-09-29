import app from './app.js';

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
const HOST = process.env.HOST || '0.0.0.0'; // 모든 네트워크 인터페이스에서 접근 가능

app.listen(PORT, HOST, () => {
  console.log(`API server running on ${HOST}:${PORT}`);
  console.log(`Local access: http://localhost:${PORT}`);
  console.log(`Network access: http://${HOST}:${PORT}`);
});
