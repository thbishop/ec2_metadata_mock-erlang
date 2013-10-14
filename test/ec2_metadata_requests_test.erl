-module(ec2_metadata_requests_test).
-compile(export_all).

-include_lib("etest/include/etest.hrl").
-include_lib ("etest_http/include/etest_http.hrl").

test_returns_latest() ->
    Response = ?perform_get("http://localhost:8080/"),
    ?assert_status(200, Response),
    ?assert_body("latest/", Response).

test_handles_invalid_root_path() ->
    Response = ?perform_get("http://localhost:8080/bad"),
    ?assert_status(404, Response).
