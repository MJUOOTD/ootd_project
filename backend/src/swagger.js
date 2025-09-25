// 간단한 OpenAPI 스펙 (Swagger UI 용)
const openApiSpec = {
  openapi: '3.0.0',
  info: {
    title: 'Project2 API',
    version: '1.0.0',
    description: '프로젝트 백엔드 API 문서'
  },
  servers: [
    { url: 'http://localhost:4000', description: 'Local server' }
  ],
  paths: {
    '/api/weather/current': {
      get: {
        summary: '현재 기상 정보 조회 (기상청)',
        description: 'lat, lon을 기준으로 기상청 초단기 실황을 조회합니다.',
        parameters: [
          { name: 'lat', in: 'query', required: true, schema: { type: 'number' }, description: '위도' },
          { name: 'lon', in: 'query', required: true, schema: { type: 'number' }, description: '경도' }
        ],
        responses: {
          '200': {
            description: '정상 응답',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    temperature: { type: 'number' },
                    humidity: { type: 'number' },
                    windSpeed: { type: 'number' },
                    feelsLike: { type: 'number' },
                    timestamp: { type: 'string', format: 'date-time' },
                    source: { type: 'string' },
                    cached: { type: 'boolean' }
                  }
                }
              }
            }
          },
          '400': { description: '잘못된 요청' },
          '500': { description: '서버 오류' }
        }
      }
    }
  }
};

export default openApiSpec;


