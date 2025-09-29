import express from 'express';

const app = express();
app.use(express.json());

app.get('/api/weather/forecast', (req, res) => {
  const now = new Date();
  const koreaTime = new Date(now.getTime() + (9 * 60 * 60 * 1000));
  const currentHour = koreaTime.getHours();
  
  const forecast = [
    {
      timestamp: new Date(koreaTime.getTime() + (0 * 60 * 60 * 1000)).toISOString(),
      temperature: 20,
      condition: 'Clear',
      icon: '01n',
      isCurrent: true
    },
    {
      timestamp: new Date(koreaTime.getTime() + (3 * 60 * 60 * 1000)).toISOString(),
      temperature: 18,
      condition: 'Clouds',
      icon: '02n',
      isCurrent: false
    },
    {
      timestamp: new Date(koreaTime.getTime() + (6 * 60 * 60 * 1000)).toISOString(),
      temperature: 22,
      condition: 'Clear',
      icon: '01d',
      isCurrent: false
    }
  ];
  
  res.json(forecast);
});

app.listen(4000, () => {
  console.log('Test server running on port 4000');
});
