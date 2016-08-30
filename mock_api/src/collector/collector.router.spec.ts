import * as router from './collector.router';

describe('collector routes', () => {
  let next;

  beforeEach(() => {
    next = jasmine.createSpy('next');
  });

  describe('POST /:exchange', () => {

    it('posts request body to rabbit exchange', () => {
      let body = 'publish me';
      let exchange = 'exchange';
      let rabbit = 'rabbit';
      let ctx = {
        request: {body},
        params: {exchange},
        rabbit
      };

      spyOn(router, 'postToRabbit');

      router.postExchange(ctx, next);

      expect(router.postToRabbit).toHaveBeenCalledWith(body, exchange, rabbit);
    });

    describe('when post to rabbit succeeds', () => {

      it('responds with 204', async function (done) {
        let ctx = {
          request: {},
          params: {},
          status: 0
        };

        spyOn(router, 'postToRabbit').and.returnValue(Promise.resolve(true));

        await router.postExchange(ctx, next);

        expect(ctx.status).toBe(204);
        done();
      });
    });

    describe('when post to rabbit fails', () => {

      it('responds with 500', async function (done) {
        let ctx = {
          request: {},
          params: {},
          status: 0
        };

        spyOn(router, 'postToRabbit').and.returnValue(Promise.resolve(false));

        await router.postExchange(ctx, next);

        expect(ctx.status).toBe(500);
        done();
      });
    });
  });
});
