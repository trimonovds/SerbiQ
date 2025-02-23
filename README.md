# SerbiQ Project

Welcome to the SerbiQ project! This repository contains the source code for the SerbiQ application.

## 📋 Prerequisites

- Ensure [`swift-format`](https://github.com/apple/swift-format) is installed:
  
  ```bash
  brew install swift-format
  ```

## 🚀 Setup

1. Clone the repository:

   ```sh
   git clone https://github.com/trimonovds/SerbiQ
   cd SerbiQ
   ```

2. Setup project:

   ```sh
   ./bootstrap.sh
   ```

## 🛠️ Development

The pre-commit hook will automatically format your Swift files before each commit.

### Formatting Code

To manually format code before committing:

```sh
tools/scripts/format-staged.sh
```

### Building the Project

To build the project:

```sh
tools/scripts/build-all.sh
```

### Running Tests

To run tests:

```sh
tools/scripts/test-all.sh
```

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.