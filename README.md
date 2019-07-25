# esy-libtools

[![Build Status](https://dev.azure.com/strid/OSS/_apis/build/status/ulrikstrid.esy-libtools?branchName=master)](https://dev.azure.com/strid/OSS/_build/latest?definitionId=33&branchName=master)

libtools packaged for [esy](https://esy.sh).

## Update verison

- Download latest release tar and copy the files.
- Make sure `am__api_version` in `./configure` is compatible with the `automake` dependency
- Update version in `package.json` and `./files/create-serial.sh`

## Original README

This is an alpha testing release of [GNU Libtool][libtool], a generic
library support script. [Libtool][] hides the complexity of using shared
libraries behind a consistent, portable interface.
