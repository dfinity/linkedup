--[[
-- File       : index.lua
-- Copyright  : 2019 Enzo Haussecker
-- License    : Apache 2.0 with LLVM Exception
-- Maintainer : Enzo Haussecker <enzo@dfinity.org>
-- Stability  : Experimental
]]

local bignum = require 'openssl.bignum'
local cbor = require 'org.conman.cbor'
local hex = require 'hex'
local http = require 'socket.http'
local ltn12 = require 'ltn12'
local rand = require 'openssl.rand'

local function bignum_to_cbor(n)	
  local ref = ''
  if n >= bignum.new('0')
  then
    ref = string.char(0x1B)
  else
    ref = string.char(0x3B)
    n = bignum.new('-1') - n
  end
  local bin = n:tobin()
  local len = string.len(bin)
  local pad = string.rep(string.char(0x00), 8 - len)
  return ref .. pad .. bin
end

bignum.interpose('__tocbor', bignum_to_cbor)

local ic_message = {
  arg = hex.decode('4449444C0000'),
  canister_id = bignum.new(ngx.var.canister_id),
  method_name = ngx.var.method_name,
  nonce = rand.bytes(32),
  request_type = 'query'
}

local request_body = cbor.encode(ic_message)

local response_body = ''

local function collect(chunk)
  if chunk ~= nil
  then
    response_body = response_body .. chunk
  end
  return true
end

http.TIMEOUT = 30

local ok, status_code = http.request {
  headers = {
    ['Content-Length'] = string.len(request_body),
    ['Content-Type'] = 'application/cbor'
  },
  method = 'POST',
  sink = collect,
  source = ltn12.source.string(request_body),
  url = string.format('http://%s/api/v1/read', ngx.var.http_host)
}

local function decode_uleb128(budget, input0)
  if budget <= 0
  then error('invalid bit budget')
  elseif input0 == nil or input0 == ''
  then error('not enough input')
  end
  local byte = string.byte(input0)
  local input1 = string.sub(input0, 2)
  if budget < 7 and bit.lshift(1, budget) < bit.band(byte, 127)
  then error('integer overflow')
  elseif bit.band(bit.rshift(byte, 7), 1) ~= 1
  then return byte, input1
  end
  local value, input2 = decode_uleb128(budget - 7, input1)
  return bit.bor(bit.lshift(value, 7), bit.band(byte, 127)), input2
end

local function get_content_type()
  local method_name = ngx.var.method_name
  if method_name == 'html'
  then return 'text/html'
  elseif method_name == 'css'
  then return 'text/css'
  elseif method_name == 'js'
  then return 'text/javascript'
  else return 'application/cbor'
  end
end

if ok and status_code == 200
then
  local iface = cbor.decode(response_body, 4)['reply']['arg']
  local n, content = decode_uleb128(64, string.sub(iface, 8))
  assert(string.len(content) == n, 'inconsistent length')
  ngx.header['Content-Length'] = n
  ngx.header['Content-Type'] = get_content_type()
  ngx.say(content)
end
ngx.exit(status_code)
