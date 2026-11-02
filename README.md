# Edspc Extended

## How do I install these formulae?

`brew install edspc/extended/<formula>`

Installing by the full name trusts only that formula.

Or `brew tap edspc/extended`, trust the formula with `brew trust --formula edspc/extended/<formula>` and then `brew install <formula>`.
To trust every current and future formula from this tap instead, run `brew trust edspc/extended`.

Since Homebrew 6.0.0, formulae from non-official taps load only after you trust them: see [Tap Trust](https://docs.brew.sh/Tap-Trust).

## Bitbucket Cloud MCP

[bitbucket-cloud-mcp](https://github.com/edspc/bitbucket-cloud-mcp) installs the
upstream GoReleaser binary for macOS or Linux, on ARM64 or x86-64. Go is not
required to install it.

```sh
brew install edspc/extended/bitbucket-cloud-mcp
bitbucket-cloud-mcp --version
```

For an existing `bitbucket-custom-mcp` installation:

```sh
brew update
brew migrate bitbucket-custom-mcp
brew upgrade edspc/extended/bitbucket-cloud-mcp
```

Update the executable path in your MCP client configuration to
`bitbucket-cloud-mcp`. See the
[upstream setup guide](https://github.com/edspc/bitbucket-cloud-mcp/blob/main/docs/claude-code.md)
for configuration.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
