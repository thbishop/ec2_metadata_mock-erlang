-module(ec2_metadata_mock_data_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {Path, Req2} = cowboy_req:path(Req),

  case (string:str(binary:bin_to_list(Path), "/latest/")) of
        0 -> return_404(Req2, State);
        _ ->
            Metadata = load_metadata_content(),
            {ok, Req3} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/plain">>}], Metadata, Req),
            {ok, Req3, State}
      end.

terminate(_Reason, _Req, _State) ->
    ok.

%% internal
return_404(Req, State) ->
    {ok, Req2} = cowboy_req:reply(404, [], <<"Not Found">>, Req),
    {ok, Req2, State}.

load_metadata_content() ->
    {ok, Data} = file:read_file("metadata.json"),
    jiffy:decode(Data).
