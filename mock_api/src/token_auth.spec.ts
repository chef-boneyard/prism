import {tokenAuth} from './token_auth';

describe('tokenAuth', () => {
  let next;

  beforeEach(() => {
    next = jasmine.createSpy('next');
  });

  describe('when provided token matches token', () => {

    it('returns next', () => {
      let apiToken = 'match-me';
      let reqToken = 'match-me';
      let ctx = {
        apiToken,
        request: {
          header: {
            'x-data-collector-token': reqToken
          }
        }
      };

      tokenAuth(ctx, next);

      expect(next).toHaveBeenCalled();
    });
  });

  describe('when provided token does not match token', () => {

    it('throws 401', () => {
      let apiToken = 'match-me';
      let reqToken = 'no';
      let ctx = {
        apiToken,
        request: {
          header: {
            'x-data-collector-token': reqToken
          }
        },
        throw: jasmine.createSpy('throw')
      };

      tokenAuth(ctx, next);

      expect(ctx.throw).toHaveBeenCalledWith(401);
    });
  });
});
