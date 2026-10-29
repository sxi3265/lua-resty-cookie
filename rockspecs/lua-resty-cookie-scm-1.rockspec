package = "lua-resty-cookie"
version = "scm-1"

source = {
  url = "git+https://git.hanada.info/hanada/lua-resty-cookie.git",
}

description = {
  summary = "Lua library for HTTP cookie manipulations for OpenResty/ngx_lua",
  homepage = "https://git.hanada.info/hanada/lua-resty-cookie",
  license = "BSD",
}

dependencies = {
  "lua >= 5.1",  -- lua-nginx-module needed
}

build = {
    type = "builtin",
    modules = {
        ["resty.cookie"] = "lib/resty/cookie.lua"
    }
}
