import * as Koa from 'koa';
import * as parser from 'koa-bodyparser';
import * as amqp from 'amqplib';
import {router} from './app.router';

const apiToken = process.env.API_TOKEN || '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506';

const rabbitUser: string = process.env.AMQP_USER || 'insights';
const rabbitPass: string = process.env.AMQP_PASS || 'chefrocks';
const rabbitHost: string = process.env.AMQP_HOST || 'localhost';
const rabbitVHost: string = process.env.AMQP_VHOST || 'insights';
const rabbitUrl: string = `amqp://${rabbitUser}:${rabbitPass}@${rabbitHost}//insights`;

const app = new Koa();
const port = 8585;

async function connectToRabbit() {
  return amqp.connect(rabbitUrl).catch((err) => {
    console.log('Attempting to connect to RabbitMQ');
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        return connectToRabbit().then(resolve, reject);
      }, 5000);
    });
  });
}

async function start(app) {
  app.context.apiToken = apiToken;
  app.context.rabbit = await connectToRabbit();

  app
    .use(parser())
    .use(router.routes())
    .use(router.allowedMethods());

  app.listen(port);
}

start(app).then(() => {
  console.log(`Mock API started on port ${port}`);
});
