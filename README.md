# secrets

A small demo application written in Crystal. This application will be used to introduce the
Crystal language to internal developers at an upcomping event.

The program uses a text file to store the secrets in an excrypted CSV file. By default, this file
is named _secrets_, but this can be overridden with the `-o` flag.

## Installation

No dependencies apart from the standard lib, so no shard installations neccessary.

## Usage

`shards run -- -p password get-all-secrets` - returns a list of all secrets \
`shards run -- -p password get-keys` - returns a list of all keys \
`shards run -- -p password get-secrets [key1] [key2] [keyN]` - returns secrets for the specified keys. \
`shards run -- -p password remove-secrets [key1] [key2] [keyN]` - removes secrets for the specified keys. \
`shards run -- -p password set-secrets [key1=val1] [key2=val2] [keyN=valN]` - sets secrets for the specified keys.

`crystal spec` will run the test suite.

## Development

This application is only made for educational purposes and I don't expect to develop it (much) further. It is licenced under the MIT licence though, so feel free to fork it if you find it usable. I will not accept PRs against this project.

## Contributing

See [Development](#development).

## Contributors

- [Lars Olsson](https://github.com/lasso) - creator and maintainer
