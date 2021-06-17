import { createServer } from 'http';
import express from 'express';

import * as sync from './sync.js';
import config from '../config.json';

const app = express();
const server = createServer(app);

app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

app.post('/init', (req, res) => {
  sync.init(req.body, req.headers['instance-id']);
  
  res.send(`Successfuly connected to local project at localhost:${config.port}`);
});

app.post('/update', (req, res) => {
  if (sync.instance.instanceId === req.headers['instance-id']) {
    sync.update(req.body);

    res.send(sync.instance.changes);
    
    sync.instance.changes.length = 0;
  } else {
    res.send();
  }
});

app.post('/open', (req, res) => {
  sync.open(req.body);
  res.send();
});

server.listen(config.port, () => {
  console.info(`Listening at localhost:${config.port}`);
});
