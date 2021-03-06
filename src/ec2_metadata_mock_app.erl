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
    TransOpts = [{ip, ip_address()}, {port, port()}],
    ProtoOpts = [{env, [{dispatch, Dispatch}]}],
    {ok, _}   = cowboy:start_http(http, ?C_ACCEPTORS, TransOpts, ProtoOpts),
    ec2_metadata_mock_sup:start_link().

stop(_State) ->
    ok.

%% ============================
%% Internal functions
%%
ip_address() ->
    case os:getenv("EC2_METADATA_IP_ADDRESS") of
        false ->
            {ok, Address} = application:get_env(ip_address);
        Other ->
            {ok, Address} = inet_parse:address(Other)
    end,

    Address.

port() ->
    case os:getenv("EC2_METADATA_PORT") of
      false ->
        {ok, Port} = application:get_env(http_port),
        Port;
      Other ->
        list_to_integer(Other)
    end.
routes() ->
    [
      {'_', [
              {"/", ec2_metadata_mock_root_handler, []},
              {"/latest/[...]", ec2_metadata_mock_data_handler, []}
            ]}
    ].
