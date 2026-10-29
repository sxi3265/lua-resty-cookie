use Test::Nginx::Socket;
use Cwd qw(cwd);

repeat_each(2);
plan tests => repeat_each() * blocks() * 3;
our $HttpConfig = 'lua_package_path "' . cwd() . '/lib/?.lua;;";';
no_long_string();
run_tests();

__DATA__

=== TEST 1: bare values do not consume named cookies
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local cookie = require("resty.cookie"):new()
            ngx.say(cookie:get("a"))
            ngx.say(cookie:get(""))
            ngx.say(table.concat(cookie:get_all_for(""), ","))
            ngx.say(cookie:get_all().b)
        }
    }
--- request
GET /t
--- more_headers
Cookie: a; a=1; b=2; tail
--- response_body
1
tail
a,tail
2
--- no_error_log
[error]

=== TEST 2: get_all_for before other getters
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local cookie = require("resty.cookie"):new()
            ngx.say(table.concat(cookie:get_all_for("a"), ","))
            ngx.say(cookie:get("a"))
            ngx.say(cookie:get_all()[""])
        }
    }
--- request
GET /t
--- more_headers
Cookie: junk; a=1; a=2; tail
--- response_body
1,2
2
tail
--- no_error_log
[error]

=== TEST 3: named empty and nameless values remain distinct
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local cookie = require("resty.cookie"):new()
            ngx.say("[", cookie:get("a"), "]")
            ngx.say("[", cookie:get(""), "]")
            ngx.say(table.concat(cookie:get_all_for(""), ","))
        }
    }
--- request
GET /t
--- more_headers
Cookie: =explicit; a=; =
--- response_body
[]
[]
explicit,
--- no_error_log
[error]

=== TEST 4: whitespace empty segments and equals inside values
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local cookie = require("resty.cookie"):new()
            ngx.say(cookie:get("a"))
            ngx.say(cookie:get(""))
            ngx.say(cookie:get("b"))
            ngx.say(#cookie:get_all_for(""))
        }
    }
--- request
GET /t
--- more_headers eval: "Cookie: ;; \t bare \t; a \t= \tx=y\t; ; b=2;"
--- response_body
x=y
bare
2
1
--- no_error_log
[error]

=== TEST 5: nameless serialization and named empty serialization
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local cookie = require("resty.cookie"):new()
            assert(cookie:set({ key = "", value = "token", path = "/" }))
            ngx.say(cookie.get_cookie_string({ key = "", value = "token" }))
            ngx.say(cookie.get_cookie_string({ key = "token", value = "" }))
            ngx.say(cookie.get_cookie_string({ key = "", value = "" }))
        }
    }
--- request
GET /t
--- response_body
token
token=
=
--- response_headers
Set-Cookie: token; Path=/

=== TEST 6: a header with only a bare value
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local cookie = require("resty.cookie"):new()
            ngx.say(cookie:get(""))
            ngx.say(cookie:get("token") == nil)
        }
    }
--- request
GET /t
--- more_headers
Cookie: token
--- response_body
token
true
--- no_error_log
[error]
