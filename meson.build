project('flowtime', ['c', 'vala'],
          version: '1.0.0',
    meson_version: '>= 0.56.0',
  default_options: [ 'warning_level=2',
                   ],
)

app_id = 'io.github.diegoivanme.flowtime'
i18n = import('i18n')



subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
