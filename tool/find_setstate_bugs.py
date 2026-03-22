import os

results = []
for root, dirs, files in os.walk('lib'):
    for f in files:
        if not f.endswith('.dart'):
            continue
        path = os.path.join(root, f)
        with open(path) as fh:
            content = fh.read()
        lines = content.split('\n')
        in_async = False
        last_await = -1
        last_mounted = -1
        for i, line in enumerate(lines):
            stripped = line.strip()
            if 'async' in stripped and ('{' in stripped or '=>' in stripped):
                in_async = True
                last_await = -1
                last_mounted = -1
            if in_async:
                if 'await ' in stripped:
                    last_await = i
                if 'mounted' in stripped:
                    last_mounted = i
                if 'setState(' in stripped:
                    if last_await >= 0 and last_mounted < last_await:
                        results.append(f'{path}:{i+1}: {stripped[:80]}')
                if stripped == '}' or stripped == '});':
                    pass  # don't break async tracking on nested braces

for r in results:
    print(r)
print(f'\nTotal: {len(results)}')
