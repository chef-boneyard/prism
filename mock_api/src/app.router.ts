import * as Router from 'koa-router';
import {tokenAuth} from './token_auth';
import {router as collector} from './collector';

export const router = new Router();

router
  .use(tokenAuth)
  .use('/data-collector/v0', collector.routes(), collector.allowedMethods());
