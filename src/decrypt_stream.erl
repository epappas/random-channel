%%% -*- erlang -*-
%%%-------------------------------------------------------------------
%%% @author Evangelos Pappas <epappas@evalonlabs.com>
%%% @copyright (C) 2015, evalonlabs
%%% The MIT License (MIT)
%%%
%%% Copyright (c) 2015 Evangelos Pappas
%%%
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%%
%%% The above copyright notice and this permission notice shall be included in all
%%% copies or substantial portions of the Software.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%%% SOFTWARE.
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------

-module(decrypt_stream).
-author("epappas").

-behaviour(gen_stream).

%% API

%% gen_stream callbacks
-export([init/1, on_data/3, on_offer/3, on_state/3]).

-define(SERVER, ?MODULE).

-define(OPEN, open).
-define(DROPPING, dropping).
-define(PAUSED, paused).
-define(STOPPED, stopped).
-define(CLOSED, closed).

-record(state, {crypto}).

%%%===================================================================
%%% API
%%%===================================================================

init([]) -> throw("Bad arguments, empty");

init(Args) ->
  AESKey = proplists:get_value(aesKey, Args),
  AESIV = proplists:get_value(iv, Args),

  CryptoState = crypto:stream_init(aes_ctr, AESKey, AESIV),

  {ok, #state{crypto = CryptoState}}.


on_offer(Resource, Stream, #state{crypto = CryptoState} = State) when is_list(Resource) ->
  {NewCryptoState, UnsafeVal} = crypto:stream_decrypt(CryptoState, Resource),

  {UnsafeVal, Stream, State#state{crypto = NewCryptoState}};

on_offer(Resource, Stream, State) when is_list(Resource) ->
  {undefined, Stream, State}.

on_data(_Resource, Stream, State) ->
  {ok, Stream, State}.

on_state(_State, _Stream, StateData) ->
%%   TODO maybe notify client here
  {ok, StateData}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
