# Flutter Coverage Updater

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A Flutter coverage updater that generates coverage reports, HTML files, and SVG badges with cross-platform support.

## Features

- 🧪 Runs Flutter tests with coverage
- 📊 Generates HTML coverage reports (optional)
- 🏷️ Creates/updates SVG coverage badges
- 🎨 Color-coded badges based on coverage percentage
- 🔧 Cross-platform support (macOS, Linux, Windows)
- 📦 Automatic dependency installation (lcov)
- 🔍 Handles projects with no tests gracefully

## Usage

```bash
mason make flutter_coverage_updater
```

### Options

- `generate_html_report`: Generate HTML coverage report (default: true)

### Coverage Badge Colors

- 🟢 Green: ≥90% coverage
- 🟡 Yellow: 80-89% coverage  
- 🟠 Orange: 70-79% coverage
- 🔴 Red: <70% coverage

## Output Files

- `coverage_badge.svg` - SVG badge with coverage percentage
- `coverage/html/index.html` - HTML coverage report (if enabled)
- `coverage/lcov.info` - LCOV coverage data

## Requirements

- Flutter project with tests
- lcov (automatically installed if missing)

## Cross-Platform Support

The script automatically detects your OS and installs lcov using the appropriate package manager:

- **macOS**: Homebrew
- **Linux**: apt-get, yum, or dnf
- **Windows**: Chocolatey, Scoop, or winget

## Example

```bash
# Generate with HTML report
mason make flutter_coverage_updater --generate_html_report true

# Generate without HTML report
mason make flutter_coverage_updater --generate_html_report false
```

## Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `generate_html_report` | Generate HTML coverage report | `true` | `boolean` |

[1]: https://github.com/felangel/mason
[2]: https://docs.brickhub.dev
[3]: https://verygood.ventures/blog/code-generation-with-mason
[4]: https://youtu.be/G4PTjA6tpTU
[5]: https://youtu.be/qjA0JFiPMnQ
[6]: https://youtu.be/o8B1EfcUisw
[7]: https://youtu.be/LXhgiF5HiQg
