from behave import given, when, then
import os
import subprocess
import requests

@given('I cleaned the module cache')
def step_clean_modcache(context):
    subprocess.run(['go', 'clean', '-modcache'], check=True)

@given('GOPRIVATE is set to "{repo_url}"')
def step_set_goprivate(context, repo_url):
    os.environ['GOPRIVATE'] = repo_url

@given('GONOPROXY is set to "localhost"')
def step_set_gonoproxy(context):
    os.environ['GONOPROXY'] = 'localhost'

@given('GOINSECURE is set to "localhost"')
def step_set_goinsecure(context):
    os.environ['GOINSECURE'] = 'localhost'

@given('git is configured to use HTTPS for "{repo_url}"')
def step_configure_git_https(context, repo_url):
    subprocess.run(['git', 'config', '--global', f'url.https://{repo_url}.insteadOf', f'ssh://git@{repo_url}'], check=True)

@given('the mock proxy is running on localhost')
def step_check_mock_proxy(context):
    try:
        response = requests.get('http://localhost:8080/healthz')
        assert response.status_code == 200
    except Exception as e:
        raise AssertionError("Mock proxy is not running or not reachable")

@when('I run "go mod tidy"')
def step_go_mod_tidy(context):
    subprocess.run(['go', 'mod', 'tidy'], check=True)

@then('the dependency should be fetched from "{full_url}"')
def step_check_fetched_from_url(context, full_url):
    assert context.mock_proxy_log.contains(full_url)

@then('the fetch should succeed even though the go.mod declares "{old_url}"')
def step_fetch_should_succeed(context, old_url):
    # Success is implied by go mod tidy not failing
    pass

@then('running "go run main.go" should succeed')
def step_go_run_main(context):
    subprocess.run(['go', 'run', 'main.go'], check=True)

@given('the go.mod file contains a replace from "{old}" to "{new}"')
def step_add_replace_directive(context, old, new):
    with open('go.mod', 'a') as f:
        f.write(f"\nreplace {old} => {new}\n")

@given('the go.mod of the migrated module still declares "{declared}"')
def step_migrated_module_declares(context, declared):
    with open(f'modules/{context.module}/go.mod') as f:
        contents = f.read()
        assert f'module {declared}' in contents

@given('the go.mod of the migrated module declares "{declared}"')
def step_migrated_module_declares_updated(context, declared):
    with open(f'modules/{context.module}/go.mod') as f:
        contents = f.read()
        assert f'module {declared}' in contents

@given('the consumer imports "{import_path}"')
def step_consumer_imports(context, import_path):
    with open('main.go', 'r') as f:
        assert import_path in f.read()

@then('the fetch should fail due to mismatched module path')
def step_fetch_should_fail(context):
    try:
        subprocess.run(['go', 'mod', 'tidy'], check=True)
    except subprocess.CalledProcessError:
        return
    raise AssertionError("Expected go mod tidy to fail, but it succeeded")

@given('the consumer has a vendor directory containing "{module_path}"')
def step_vendor_directory_present(context, module_path):
    assert os.path.isdir('vendor')
    assert any(module_path in root for root, _, _ in os.walk('vendor'))

@when('I run "go build"')
def step_go_build(context):
    subprocess.run(['go', 'build'], check=True)

@then('the build should succeed without contacting the mock proxy')
def step_build_no_proxy(context):
    assert not context.mock_proxy_log.was_accessed()

@given('the vendor directory is removed')
def step_remove_vendor(context):
    subprocess.run(['rm', '-rf', 'vendor'], check=True)

@given('the go.mod requires a newer version from "{module}"')
def step_add_newer_dependency(context, module):
    subprocess.run(['go', 'get', f'{module}@latest'], check=True)

@given('the go.mod requires an older version from "{module}"')
def step_add_older_dependency(context, module):
    subprocess.run(['go', 'get', f'{module}@v0.0.1'], check=True)

@when('I run "go mod vendor"')
def step_go_mod_vendor(context):
    subprocess.run(['go', 'mod', 'vendor'], check=True)

@then('the vendor directory should be recreated')
def step_check_vendor_dir(context):
    assert os.path.isdir('vendor')

@then('the mock proxy should be hit')
def step_mock_proxy_hit(context):
    assert context.mock_proxy_log.was_accessed()

@then('the fetch should succeed')
def step_fetch_succeed(context):
    pass  # go commands would have already raised exceptions if they failed
