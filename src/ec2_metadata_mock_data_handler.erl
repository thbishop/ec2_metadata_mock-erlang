-module(ec2_metadata_mock_data_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {Path, Req2} = cowboy_req:path(Req),

    case (string:str(binary:bin_to_list(Path), "/latest/")) of
        0 ->
            return_404(Req2, State);
        _ ->
            Body = get_data_from_path(Path),
            {ok, Req3} = cowboy_req:reply(200,
                                          [{<<"content-type">>, <<"text/plain">>}],
                                          Body,
                                          Req2),
            {ok, Req3, State}
      end.

terminate(_Reason, _Req, _State) ->
    ok.

%% internal
format_key(KeyData) ->
  {Key, _} = KeyData,
  case KeyData of
      {_, true} ->
          [Key, <<"\/\n">>];
      {_, false} ->
          [Key, <<"\n">>]
  end.

get_data_from_path(Path) ->
    RelativePath = relative_path(Path),
    AllData = load_metadata_content(),

    case (string:tokens(RelativePath, "/")) of
        [] ->
            Keys = [{element(1, X), is_tuple(element(2, X))} || X <- element(1, AllData)],
            list_to_binary(lists:map(fun(X) -> format_key(X) end, Keys));
        _ ->
            KeyData = ej:get(list_to_tuple(string:tokens(RelativePath, "/")), AllData),
            case (is_tuple(KeyData)) of
                true ->
                    Keys = [{element(1, X), is_tuple(element(2, X))} || X <- element(1, KeyData)],
                    list_to_binary(lists:map(fun(X) ->format_key(X) end, Keys));
                false ->
                    KeyData
            end
    end.

load_metadata_content() ->
    {ok, Json} = file:read_file("metadata.json"),
    jiffy:decode(Json).

relative_path(Path) ->
    binary_to_list(Path) -- "/latest".

return_404(Req, State) ->
    {ok, Req2} = cowboy_req:reply(404, [], <<"Not Found">>, Req),
    {ok, Req2, State}.
