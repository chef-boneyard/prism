import * as Router from 'koa-router';

export async function postToRabbit(body, exchange, connection) {
  const key = 'data-collector';
  const channel = await connection.createChannel();
  const exchangeOk = await channel.assertExchange(exchange, 'topic');
  return channel.publish(exchange, key, new Buffer(JSON.stringify(body)));
}

export async function postExchange(ctx, next) {
  const body = ctx.request.body;
  const exchange = ctx.params.exchange;
  const connection = ctx.rabbit;

  try {
    if (await this.postToRabbit(body, exchange, connection)) {
      ctx.status = 204;
    } else {
      throw new Error('Failed to publish to Rabbit');
    }
  } catch (err) {
    ctx.status = 500;
    ctx.body = {message: err.message};
  }

  return next();
}

export const router = new Router();

router.post('/:exchange', postExchange.bind(this));
