-module(ec2_metadata_requests_test).
-compile(export_all).

-include_lib("etest/include/etest.hrl").
-include_lib ("etest_http/include/etest_http.hrl").

test_handles_invalid_root_path() ->
    Response = ?perform_get("http://localhost:8080/bad"),
    ?assert_status(404, Response).

test_returns_latest() ->
    Response = ?perform_get("http://localhost:8080/"),
    ?assert_status(200, Response),
    ?assert_body("latest/", Response).

test_latest_top_level_items() ->
    Response = ?perform_get("http://localhost:8080/latest/"),
    ?assert_status(200, Response),
    ?assert_body("meta-data/\nuser-data\n", Response).

test_metadata_returns_top_level_items() ->
    Response = ?perform_get("http://localhost:8080/latest/meta-data/"),
    Items = ["ami-id", "ami-launch-index", "ami-manifest-path", "block-device-mapping/", "hostname", "instance-action", "instance-id", "instance-type", "kernel-id", "local-hostname", "local-ipv4", "mac", "network/", "placement", "profile", "public-keys/", "reservation-id", "security-groups" ],
    ?assert_status(200, Response),
    [ ?assert_body_contains(X, Response) || X <- Items].

test_ami_id() ->
    Response = ?perform_get("http://localhost:8080/latest/meta-data/ami-id"),
    ?assert_status(200, Response),
    ?assert_body("ami-ab12d590", Response).

test_block_device_mapping() ->
    Response = ?perform_get("http://localhost:8080/latest/meta-data/block-device-mapping/"),
    ?assert_status(200, Response),
    ?assert_body("ami\nephemeral0\nephemeral1\nroot\n", Response).

test_network_interfaces_macs() ->
    Response = ?perform_get("http://localhost:8080/latest/meta-data/network/interfaces/macs/"),
    ?assert_status(200, Response),
    ?assert_body("02:e8:42:bd:f5:9d/\n", Response).

test_user_data() ->
    Response = ?perform_get("http://localhost:8080/latest/user-data/"),
    ?assert_status(200, Response),
    ?assert_body("foo\n", Response).
