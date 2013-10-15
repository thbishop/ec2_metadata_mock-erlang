-module(ec2_metadata_mock_data_loader).

-export([data_from_path/1]).

data_from_path(Path) ->
    RelativePath = relative_path(Path),
    AllData = all_data(),

    case (string:tokens(RelativePath, "/")) of
        [] -> list_of_keys(AllData);
        _ ->
            KeyData = key_data(AllData, RelativePath),
            case has_children(KeyData) of
                true ->
                    list_of_keys(KeyData);
                false ->
                    KeyData
            end
    end.

%% internal
all_data() ->
    {ok, Json} = file:read_file(metadata_file()),
    jiffy:decode(Json).

format_key(KeyData) ->
    case KeyData of
        {Key, true} -> [Key, <<"\/\n">>];
        {Key, false} -> [Key, <<"\n">>]
    end.

has_children(Key) ->
    is_tuple(Key).

key_data(Data, Path) ->
    ej:get(list_to_tuple(string:tokens(Path, "/")), Data).

list_of_keys(Data) ->
    Keys = [{element(1, X), has_children(element(2, X))} || X <- element(1, Data)],
    list_to_binary(lists:map(fun(X) -> format_key(X) end, Keys)).

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
