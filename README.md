Sogishort
=========

This is a simple url shortener in which each link is
stored in a git repository!

Init
----

Clone the project and install dependencies

```bash
bundle install
```

Heroku ping
-----------

A rake task is available to ping every hour the app.

```bash
heroku config:add PING_URL=http://my-app.herokuapp.com
heroku addons:add scheduler:standard
heroku addons:open scheduler
```

Add `rake dyno_ping` to be run once an hour.

Run
---

``` bash
$ bundle exec guard # only for dev
$ bundle exec rackup
```

And visit <http://localhost:9292>
