flowtime_sources = [
  'main.vala',
  'Window.vala',
  'Application.vala',
]

flowtime_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk4', version: '>= 4.2.5'),
  dependency('libadwaita-1'),
]

gnome = import('gnome')

flowtime_resources_file = files('ui/flowtime.gresource.xml')
flowtime_sources += gnome.compile_resources('io.github.diegoivanme.flowtime',
  flowtime_resources_file,
  c_name: 'flowtime',
  source_dir: 'ui',
)

executable('flowtime', flowtime_sources,
  vala_args: [
    '--target-glib=2.50',
    '--gresources', flowtime_resources_file,
  ],
  dependencies: flowtime_deps,
  install: true,
)
