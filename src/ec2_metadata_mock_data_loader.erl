-module(ec2_metadata_mock_data_loader).

-export([data_from_path/1]).

data_from_path(Path) ->
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

format_key(KeyData) ->
  {Key, _} = KeyData,
  case KeyData of
      {_, true} ->
          [Key, <<"\/\n">>];
      {_, false} ->
          [Key, <<"\n">>]
  end.

load_metadata_content() ->
    {ok, Json} = file:read_file(metadata_file()),
    jiffy:decode(Json).

metadata_file() ->
  case os:getenv("EC2_METADATA_FILE") of
      false ->
          {ok, Dir} = file:get_cwd(),
          filename:join([Dir, "metadata.json"]);
      Other ->
          Other
  end.

relative_path(Path) ->
    binary_to_list(Path) -- "/latest".
