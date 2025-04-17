# Shush 🥷

A powerful utility for suppressing and managing output from commands and scripts in Linux and macOS systems.

## Features

- **Output Control**: Selectively suppress stdout, stderr, or both
- **Logging**: Redirect suppressed output to log files
- **Progress Indication**: Show a spinner while long-running commands execute
- **Notifications**: Get desktop notifications when commands complete or fail
- **Timeout Control**: Automatically terminate commands that run too long
- **Exit Code Management**: Preserve or override exit codes from commands
- **Execution Summary**: Get timing and result information for commands

## Installation

### Using Homebrew (macOS)

The easiest way to install on macOS is via Homebrew:

```bash
brew install 00msjr/tap/shush
```

### Manual Installation

1. Clone this repository or download the script:

   ```bash
   git clone https://github.com/yourusername/shush.git
   cd shush
   ```

2. Make the script executable:

   ```bash
   chmod +x shush
   ```

3. Optionally, move it to your PATH for system-wide access:

   ```bash
   sudo cp shush /usr/local/bin/
   ```

## Usage

```
Usage: shush [options] -- command [args...]

Options:
  -o, --stdout-only     Suppress only stdout
  -e, --stderr-only     Suppress only stderr
  -l, --log FILE        Log suppressed output to FILE
  -v, --verbose         Show progress indicator while command runs
  -n, --notify          Desktop notification when command completes
  -N, --notify-error    Desktop notification only on error
  -t, --timeout SECS    Terminate command after SECS seconds
  -r, --return-only     Print only the return code of the command
  -q, --quiet           No output from shush itself (implies -r)
  -i, --ignore-exit     Always exit with 0 regardless of command exit code
  -s, --summary         Show summary of execution time and exit code
  -h, --help            Display this help message

Note: The -- separator is required to distinguish shush options from the command to run
```

## Examples

Run a command with no output:

```bash
shush -- npm install
```

Run a command and log output to a file:

```bash
shush -l log.txt -- make
```

Run with progress indicator and timeout:

```bash
shush -v -t 30 -- curl example.com
```

Run a command and get a notification when it completes:

```bash
shush -n -- rsync -a /source /destination
```

Run a command and only show its exit code:

```bash
shush -r -- grep "pattern" file.txt
```

Run a command in complete silence, ignoring its exit code:

```bash
shush -q -i -- ./noisy_script.sh
```

Get a summary of execution time and result:

```bash
shush -s -- python long_running_script.py
```

## Use Cases

- Running noisy commands in scripts without cluttering output
- Executing commands that produce excessive debugging information
- Running commands in the background with notification on completion
- Timing command execution with clean output
- Creating cleaner build processes and deployment scripts

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
