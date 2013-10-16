## EC2 Metadata Mock Service

This provides a mock [AWS EC2 instance metadata/user data service](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html).


## Usage
***NOTE: only tested on erlang R16B02***

Download, install, compile, and create a release

```shell
git clone https://github.com/thbishop/ec2_metadata_mock-erlang.git

cd ec2_metadata_mock-erlang

./rebar get-deps compile generate
```

You can then start it with:

```shell
rel/ec2_metadata_mock/bin/ec2_metadata_mock stop
```

And stop it with:

```shell
rel/ec2_metadata_mock/bin/ec2_metadata_mock start
```

### Address/Port Binding
By default, the service will bind to all addresses on port 8080.

You can override the bind address and port using environment variables.

To bind to a different port, you can do:

```shell
env EC2_METADATA_PORT=9000 rel/ec2_metadata_mock/bin/ec2_metadata_mock start
```

And to a different address:

```shell
env EC2_METADATA_ADDRESS=192.168.1.10 rel/ec2_metadata_mock/bin/ec2_metadata_mock start
```

If you want to truly mimic the EC2 metadata service, you'll want to listen on 169.254.169.254.

To do so on OSX, you can add another address with:

```shell
sudo ifconfig lo0 alias 169.254.169.254
```

If you want to remove the address, you can do so with:

```shell
ifconfig lo0 -alias 172.16.123.1
```

On linux, you can do:

```shell
ifconfig eth0:1 169.254.169.254
```

And to remove it:

```shell
ifconfig eth0:1 down
```

And then start and bind to the new address:

```shell
sudo env EC2_METADATA_PORT=80 EC2_METADATA_IP_ADDRESS=169.254.169.254 \
  rel/ec2_metadata_mock/bin/ec2_metadata_mock start
```

## License
See LICENSE file for details
