export function tokenAuth(ctx, next) {
  const apiToken: string = ctx.apiToken;
  const reqToken: string = ctx.request.header['x-data-collector-token'];

  if (reqToken !== apiToken) {
    ctx.throw(401);
  }

  return next();
}
