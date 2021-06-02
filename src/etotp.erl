%%-------------------------------------------------------------------------------------------
%% Copyright (c) 2020 Venkatakumar Srinivasan
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% @author Venkatakumar Srinivasan
%% @since February 14, 2020
%%
%%-------------------------------------------------------------------------------------------
-module(etotp).

%% API exports
-export([
         token/1,
         token/2
]).

%%====================================================================
%% API functions
%%====================================================================
token(Secret) ->
  token(Secret, []).

token(Secret, Options) ->
  Interval = interval(Options),
  htop(Secret, Interval, Options).

%%====================================================================
%% Internal functions
%%====================================================================
htop(Secret, Interval, Options) ->
  %% Get options
  Digest = proplists:get_value(digest, Options, sha),
  Length = proplists:get_value(length, Options, 6),

  %% base32 decode
  Key = ebase32:decode(Secret),

  %% convert Interval to 8-byte binary
  Message = <<Interval:8/big-unsigned-integer-unit:8>>,

  %% Hash
  Hash = crypto:mac(hmac, Digest, Key, Message),

  %% Generate Token
  <<_:19/binary, _:4, Offset:4, _Rest/binary>> = Hash,
  <<Header:32>> = binary:part(Hash, Offset, 4),
  TokenInt = (Header band 2147483647) rem trunc(math:pow(10, Length)),
  Token = pad_left_zero(integer_to_binary(TokenInt), Length),

  %% ensure token is of corrent length
  Length = byte_size(Token),

  %% return token
  Token.


interval(Options) ->
  %% get options
  {MegaSecs, Sec, _} = proplists:get_value(timestamp, Options, os:timestamp()),
  Period = proplists:get_value(period, Options, 30),

  %% Convert to unix epoch
  UnixEpoch = MegaSecs * 1000000 + Sec,

  %% return interval
  trunc( UnixEpoch / Period ).

pad_left_zero(Token, Max) ->
  N = Max - byte_size(Token),
  Zeros = binary:copy(<<$0>>, N),
  <<Zeros/binary, Token/binary>>.


%%=========================================================================
%% Unit Test Suite
%%=========================================================================
-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

suite_test_() ->
  [
   ?_assertEqual(6, size( etotp:token(<<"MFRGGZDFMZTWS2TL">>) )),
   ?_assertEqual(6, size( etotp:token(<<"MFRGGZDFMZTWS2TL">>, [{digest, sha256}]) )),
   ?_assertEqual(10, size( etotp:token(<<"MFRGGZDFMZTWS2TL">>, [{length, 10}]) ))
  ].

-endif.
