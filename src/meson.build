flowtime_sources = [
  'main.vala',
  'Application.vala',
  'XmlUtils.vala',

  # Models
  'Models/Day.vala',
  'Models/State.vala',
  'Models/StatObject.vala',
  'Models/InformationHolder.vala',

  # Services
  'Services/Timer.vala',
  'Services/ColorProvider.vala',
  'Services/Statistics.vala',
  'Services/Alarm.vala',
  'Services/Settings.vala',

  # Widgets
  'Widgets/PreferencesWindow.vala',
  'Widgets/SoundRow.vala',
  'Widgets/StatCircle.vala',
  'Widgets/StatGraph.vala',
  'Widgets/StatInfo.vala',
  'Widgets/StatList.vala',
  'Widgets/StatPage.vala',
  'Widgets/StatRow.vala',
  'Widgets/StatsWindow.vala',
  'Widgets/TimerPage.vala',
  'Widgets/Window.vala',
]

flowtime_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk4', version: '>= 4.4.6'),
  dependency ('gstreamer-1.0'),
  dependency('gstreamer-player-1.0'),
  dependency('libadwaita-1', version: '>= 1.2'),
  dependency('libxml-2.0'),
  dependency('libportal-gtk4'),
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
blueprint_compiler = find_program('blueprint-compiler')

blueprints = files (
  'ui/preferenceswindow.blp',
  'ui/statcircle.blp',
  'ui/statrow.blp',
  'ui/statwindow.blp',
  'ui/window.blp',
  'ui/statlist.blp',
  'ui/statinfo.blp',
  'ui/statpage.blp',
  'ui/timerpage.blp',
)

flowtime_resources_file = files('flowtime.gresource.xml')
flowtime_resources = gnome.compile_resources('flowtime-resources',
  flowtime_resources_file,
  c_name: 'flowtime',
  dependencies: custom_target(
    build_always_stale: true,
    command: [blueprint_compiler, 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
    input: blueprints,
    output: '.',
  ),
)

executable('flowtime', flowtime_resources, flowtime_sources,
  vala_args: [
    meson.project_source_root() + '/src/vapi/config.vapi',
    '--target-glib=2.50',
    '--enable-checking',
    '--gresourcesdir=src/',
    '--vapidir', meson.project_source_root() / 'vapi',
  ],
  dependencies: flowtime_deps,
  install: true,
)
