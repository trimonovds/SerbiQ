# Swift Pre-Commit Hook Setup

This repository uses a **Git pre-commit hook** to run [`swift-format`](https://github.com/apple/swift-format) on staged Swift files before committing.

## 📋 Prerequisites

- Ensure [`swift-format`](https://github.com/apple/swift-format) is installed:
  
  ```bash
  brew install swift-format

- Install pre-commit hook
  
  ```sh
  ./bootstrap.sh