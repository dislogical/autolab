args = []
if k8s_context() != '':
  args += ['--kube-context', k8s_context()]

local_resource(
    name='helmfile',
    cmd='helmfile {} sync'.format(' '.join(args)),
    deps=['helmfile.yaml', 'charts/'],
)
