Feature: Go module migration from GitHub Enterprise Server to GitHub Enterprise Cloud

  Background:
    Given GOPRIVATE is set to "<new_repo_url>"
    And GONOPROXY is set to "localhost"
    And GOINSECURE is set to "github.old.com"
    And git is configured to use HTTPS for "<new_repo_url>"
    And the mock proxy is running on localhost

  Scenario Outline: Source repo tries to download a migrated repo
    Given I cleaned the module cache
    When I run "go mod tidy"
    Then the dependency should be fetched from "<new_repo_url>/<module>"
    And the fetch should succeed even though the go.mod declares "<old_repo_url>/<module>"
    And running "go run main.go" should succeed

  Scenario Outline: Source repo adds a replace directive to source from the migrated URL
    Given I cleaned the module cache
    And the go.mod file contains a replace from "<old_repo_url>/<module>" to "<new_repo_url>/<module>"
    And the go.mod of the migrated module still declares "<old_repo_url>/<module>"
    When I run "go mod tidy"
    Then the dependency should be fetched from "<new_repo_url>/<module>"
    And the fetch should succeed

  Scenario Outline: Replace directive used and migrated module has new module path
    Given I cleaned the module cache
    And the go.mod file contains a replace from "<old_repo_url>/<module>" to "<new_repo_url>/<module>"
    And the go.mod of the migrated module declares "<new_repo_url>/<module>"
    When I run "go mod tidy"
    Then the dependency should be fetched from "<new_repo_url>/<module>"
    And the fetch should succeed

  Scenario Outline: Module import path updated in consumer, but module name is still old
    Given I cleaned the module cache
    And the consumer imports "<new_repo_url>/<module>"
    And the go.mod of the migrated module still declares "<old_repo_url>/<module>"
    When I run "go mod tidy"
    Then the dependency should be fetched from "<new_repo_url>/<module>"
    And the fetch should fail due to mismatched module path

  Scenario Outline: Module import path updated in consumer and module path is also updated
    Given I cleaned the module cache
    And the consumer imports "<new_repo_url>/<module>"
    And the go.mod of the migrated module declares "<new_repo_url>/<module>"
    When I run "go mod tidy"
    Then the dependency should be fetched from "<new_repo_url>/<module>"
    And the fetch should succeed

  Scenario Outline: Consumer has vendored internal dependencies
    Given the consumer has a vendor directory containing "<old_repo_url>/<module>"
    When I run "go build"
    Then the build should succeed without contacting the mock proxy

  Scenario Outline: Consumer upgrades vendored internal dependencies
    Given the vendor directory is removed
    And the go.mod requires a newer version from "<new_repo_url>/<module>"
    When I run "go mod vendor"
    Then the vendor directory should be recreated
    And the mock proxy should be hit
    And the fetch should succeed

  Scenario Outline: Consumer downgrades vendored internal dependencies
    Given the vendor directory is removed
    And the go.mod requires an older version from "<new_repo_url>/<module>"
    When I run "go mod vendor"
    Then the vendor directory should be recreated
    And the mock proxy should be hit
    And the fetch should succeed

  Examples:
    | old_repo_url              | new_repo_url              | module         |
    | github.old.com/org/pkg   | github.new.com/org/pkg   | internalpkg    |
    | github.old.com/team/lib  | github.new.com/team/lib  | helperlib      |
    | github.old.com/dev/util  | github.new.com/dev/util  | utiltools      |
