-module(ec2_metadata_mock_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-define(C_ACCEPTORS, 100).
%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Routes    = routes(),
    Dispatch  = cowboy_router:compile(Routes),
    Port      = port(),
    TransOpts = [{port, Port}],
    ProtoOpts = [{env, [{dispatch, Dispatch}]}],
    {ok, _}   = cowboy:start_http(http, ?C_ACCEPTORS, TransOpts, ProtoOpts),
    ec2_metadata_mock_sup:start_link().

stop(_State) ->
    ok.

%% ============================
%% Internal functions
%%
routes() ->
    [
      {'_', [
              {"/", ec2_metadata_mock_root_handler, []},
              {"/latest/[...]", ec2_metadata_mock_data_handler, []}
            ]}
    ].

port() ->
    case os:getenv("PORT") of
      false ->
        {ok, Port} = application:get_env(http_port),
        Port;
      Other ->
        Other
    end.
