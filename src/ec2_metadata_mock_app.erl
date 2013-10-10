-module(ec2_metadata_mock_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ec2_metadata_mock_sup:start_link().

stop(_State) ->
    ok.
