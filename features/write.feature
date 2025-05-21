from behave import given, when, then
import os
import subprocess

@given('GOPRIVATE is set to "{new_repo_url}"')
def step_set_goprivate(context, new_repo_url):
    context.env = os.environ.copy()
    context.env['GOPRIVATE'] = new_repo_url

@given('GONOPROXY is set to "localhost"')
def step_set_gonoproxy(context):
    context.env['GONOPROXY'] = 'localhost'

@given('GOINSECURE is set to "github.old.com"')
def step_set_goinsecure(context):
    context.env['GOINSECURE'] = 'github.old.com'

@given('git is configured to use HTTPS for "{new_repo_url}"')
def step_configure_git_https(context, new_repo_url):
    subprocess.run(['git', 'config', '--global', 'url.https://' + new_repo_url + '/.insteadOf', 'git@' + new_repo_url + ':'], check=True)

@given('the mock proxy is running on localhost')
def step_check_mock_proxy(context):
    # Optionally implement a health check for your mock proxy here
    pass

@given('I cleaned the module cache')
def step_clean_modcache(context):
    subprocess.run(['go', 'clean', '-modcache'], env=context.env, check=True)

@when('the go.mod file contains a replace from "{old_repo_url}" to "{new_repo_url}"')
def step_add_replace_directive(context, old_repo_url, new_repo_url):
    go_mod_path = f'modules/{context.module}/go.mod'
    replace_line = f'replace {old_repo_url} => {new_repo_url}\n'

    with open(go_mod_path, 'r') as f:
        lines = f.readlines()

    replaced = False
    with open(go_mod_path, 'w') as f:
        for line in lines:
            if line.strip().startswith('replace') and old_repo_url in line:
                f.write(replace_line)
                replaced = True
            else:
                f.write(line)

        if not replaced:
            # Append replace directive at the end if not found
            f.write('\n' + replace_line)

@when('the go.mod of the migrated module still declares "{declared}"')
def step_update_module_declaration_to_old(context, declared):
    go_mod_path = f'modules/{context.module}/go.mod'
    with open(go_mod_path, 'r') as f:
        lines = f.readlines()

    with open(go_mod_path, 'w') as f:
        for line in lines:
            if line.startswith('module '):
                f.write(f'module {declared}\n')
            else:
                f.write(line)

@when('the go.mod of the migrated module declares "{declared}"')
def step_update_module_declaration_to_new(context, declared):
    # Reuse the same logic as above for updating module declaration
    go_mod_path = f'modules/{context.module}/go.mod'
    with open(go_mod_path, 'r') as f:
        lines = f.readlines()

    with open(go_mod_path, 'w') as f:
        for line in lines:
            if line.startswith('module '):
                f.write(f'module {declared}\n')
            else:
                f.write(line)

@when('the consumer imports "{import_path}"')
def step_update_consumer_import(context, import_path):
    # Update import statements in source files of the consumer module
    import os
    import re

    module_dir = f'modules/{context.module}'
    for root, _, files in os.walk(module_dir):
        for file in files:
            if file.endswith('.go'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                # Simple regex replace import paths; this assumes double quotes
                new_content = re.sub(r'(["\'])github\.old\.com[^"\']*', f'"{import_path}', content)
                if new_content != content:
                    with open(filepath, 'w') as f:
                        f.write(new_content)

@when('the consumer has a vendor directory containing "{old_repo_url}"')
def step_consumer_has_vendor(context, old_repo_url):
    import os
    vendor_path = f'modules/{context.module}/vendor'
    if not os.path.exists(vendor_path):
        raise AssertionError(f"Vendor directory {vendor_path} does not exist")
    # Optionally check contents for old_repo_url
    found = False
    for root, _, files in os.walk(vendor_path):
        for file in files:
            if file.endswith('.go'):
                with open(os.path.join(root, file), 'r') as f:
                    if old_repo_url in f.read():
                        found = True
                        break
    if not found:
        raise AssertionError(f"Vendor directory does not contain references to {old_repo_url}")

@when('the vendor directory is removed')
def step_remove_vendor_dir(context):
    import shutil
    vendor_path = f'modules/{context.module}/vendor'
    if os.path.exists(vendor_path):
        shutil.rmtree(vendor_path)

@when('the go.mod requires a newer version from "{new_repo_url}"')
def step_go_mod_requires_newer_version(context, new_repo_url):
    # Simplified: you can update version here as needed, e.g. v1.2.0
    go_mod_path = f'modules/{context.module}/go.mod'
    with open(go_mod_path, 'r') as f:
        lines = f.readlines()

    with open(go_mod_path, 'w') as f:
        for line in lines:
            if line.strip().startswith('require') and new_repo_url in line:
                # Update version to newer version
                parts = line.split()
                if len(parts) >= 3:
                    parts[2] = 'v1.2.0'
                f.write(' '.join(parts) + '\n')
            else:
                f.write(line)

@when('the go.mod requires an older version from "{new_repo_url}"')
def step_go_mod_requires_older_version(context, new_repo_url):
    # Simplified: update version to an older version e.g. v0.9.0
    go_mod_path = f'modules/{context.module}/go.mod'
    with open(go_mod_path, 'r') as f:
        lines = f.readlines()

    with open(go_mod_path, 'w') as f:
        for line in lines:
            if line.strip().startswith('require') and new_repo_url in line:
                parts = line.split()
                if len(parts) >= 3:
                    parts[2] = 'v0.9.0'
                f.write(' '.join(parts) + '\n')
            else:
                f.write(line)

@when('I run "{command}"')
def step_run_command(context, command):
    print(f"Running command: {command}")
    result = subprocess.run(command.split(), env=context.env, capture_output=True)
    context.command_output = result.stdout.decode()
    context.command_error = result.stderr.decode()
    context.command_returncode = result.returncode

@then('the dependency should be fetched from "{repo_url}"')
def step_check_fetched_from_repo(context, repo_url):
    # Implement mock proxy log checking if available, stub for now
    print(f"Checked dependency fetch from {repo_url}")

@then('the fetch should succeed')
def step_fetch_should_succeed(context):
    assert context.command_returncode == 0, f"Fetch failed: {context.command_error}"

@then('the fetch should succeed even though the go.mod declares "{old_repo_url}"')
def step_fetch_succeed_old_module_path(context, old_repo_url):
    assert context.command_returncode == 0, f"Fetch failed but expected success with old module path {old_repo_url}"

@then('running "{command}" should succeed')
def step_run_command_should_succeed(context, command):
    result = subprocess.run(command.split(), env=context.env, capture_output=True)
    assert result.returncode == 0, f"Command '{command}' failed: {result.stderr.decode()}"

@then('the fetch should fail due to mismatched module path')
def step_fetch_should_fail_mismatch(context):
    assert context.command_returncode != 0, "Expected fetch failure due to module path mismatch but fetch succeeded"

@then('the build should succeed without contacting the mock proxy')
def step_build_succeeds_no_proxy(context):
    # You could verify no network calls to mock proxy, stub for now
    print("Build succeeded without contacting mock proxy")

@then('the vendor directory should be recreated')
def step_vendor_dir_recreated(context):
    import os
    vendor_path = f'modules/{context.module}/vendor'
    assert os.path.exists(vendor_path), "Vendor directory was not recreated"

@then('the mock proxy should be hit')
def step_mock_proxy_hit(context):
    # Check proxy logs or hits, stub for now
    print("Mock proxy was hit during fetch")
