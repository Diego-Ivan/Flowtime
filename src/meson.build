flowtime_sources = [
  'main.vala',
  'Application.vala',
  'Widgets/Window.vala',
  'Widgets/PreferencesWindow.vala',
  'Widgets/QuoteLabel.vala',
  'Widgets/SoundRow.vala',
  'Widgets/TimerPage.vala',
  'Services/WorkTimer.vala',
  'Services/BreakTimer.vala',
  'Interfaces/Timer.vala',
]

flowtime_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk4', version: '>= 4.2.5'),
  dependency ('gstreamer-1.0'),
  dependency('gstreamer-player-1.0'),
  dependency('libadwaita-1'),
]

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('G_LOG_DOMAIN', 'Flowtime')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)

add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

gnome = import('gnome')

flowtime_resources_file = files('ui/flowtime.gresource.xml')
flowtime_sources += gnome.compile_resources(app_id,
  flowtime_resources_file,
  c_name: 'flowtime',
  source_dir: 'ui',
)

executable('flowtime', flowtime_sources,
  vala_args: [
    meson.project_source_root() + '/src/vapi/config.vapi',
    '--target-glib=2.50',
    '--gresources', flowtime_resources_file,
    '--vapidir', meson.project_source_root() / 'vapi',
  ],
  dependencies: flowtime_deps,
  install: true,
)
