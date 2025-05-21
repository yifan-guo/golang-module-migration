def before_scenario(context, scenario):
    class MockProxyLog:
        def contains(self, url):
            # Custom logic to check mock proxy log for a URL
            with open('/tmp/mock_proxy.log') as f:
                return url in f.read()

        def was_accessed(self):
            with open('/tmp/mock_proxy.log') as f:
                return len(f.read().strip()) > 0

    context.mock_proxy_log = MockProxyLog()
