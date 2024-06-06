# upload-stuff.sh: Easily upload files to a SFTP server using scp(1)

## Installation

Run `make install`.

The default `PREFIX` is `/usr/local`, and the script will be installed in the `bin/` subdirectory as `upload-stuff`.

You can override `PREFIX` or set `BIN_DIR` directly to override, like this:

```bash
make BIN_DIR="$HOME/.local/bin" install
```

## Configuration

The script must be configured to the personal preferences and setup. For this,
you _must_ create a per-user configuration file (which actually is a shell
script fragment, so shell syntax applies!) in `$HOME/.config/upload-stuff.conf`
and set at least the following three variables:

- `DST_HOST`: The destination SFTP host name, for example
  `DST_HOST="host.example.net"`.
- `DST_PATH`: The relative (to the remote home directory) or absolute path name
  to the upload directory on the remote server. For example
  `DST_PATH="my/upload/directory/"`.
- `URL_PREFIX`: The URL prefix for the uploaded file, including protocol, host
  name and path prefix. For example
  `URL_PREFIX="https://example.net/my/uploaded/files/"`.

And two more options can be tweaked:

- `SHORT_RANDOM_LEN`: Default: `SHORT_RANDOM_LEN=4`.
- `ALL_RANDOM_LEN`: Default: `ALL_RANDOM_LEN=16`.

## Invocation

Usage: `upload-stuff [-C] [-o] [-R|-r] [-x] <file> [<file> [...]]`

- `-C`, `--no-copy`: Do not copy the URL into the clipboard.
- `-o`, `--open`: Open each URL after uploading the file.
- `-R`, `--all-random`: Generate an all-random file name but keep the extension.
- `-r`, `--random`: Add a random suffix to the file name, before the extension.
- `-x`, `--dry-run`: Do not upload the file(s), only show what would be done.
- `--help`: Show this usage information and exit.

## Dependencies

- For random file name generation the `pwgen`(1) tool is required.

- For opening URLs, either `xdg-open`(1) or `open`(1) is required.

- For copying the URL into the clipboard, the `pbcopy`(1) command is used, which
  is available on macOS.
