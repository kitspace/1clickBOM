'use strict';

const rateLimit = require('./function-rate-limit');

module.exports = (count, interval, fn) => {
  const rateLimited = rateLimit(count, interval, function(cb) {
    Promise
      .resolve(fn.apply(this, [].slice.call(arguments, 1)))
      .then(cb.bind(null, null))
      .catch(cb);
  });

  return function() {
    return new Promise((resolve, reject) => {
      const cb = (err, res) => err ? reject(err) : resolve(res);
      rateLimited.apply(this, [cb].concat([].slice.call(arguments)));
    });
  };
};
