# Go Module Migration Tests

This repository contains [Behave](https://behave.readthedocs.io/) tests to verify Go module migration from GitHub Enterprise Server to GitHub Enterprise Cloud using a mock proxy.

## Folder Structure

- `features/` - Contains feature files and step implementations.
- `features/modules/` - Contains example Go modules used in tests.
- `features/steps/` - Contains step definition Python files.

## Prerequisites

- [Python 3.x](https://www.python.org/downloads/)
- [Behave](https://behave.readthedocs.io/en/latest/): Install with
  ```bash
  pip install behave



## Run
Start your mock proxy server on localhost to intercept module fetch requests.

From the repository root, run Behave to execute the test scenarios:

behave features/go_module_migration.feature
