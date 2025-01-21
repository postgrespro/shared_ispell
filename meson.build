# Copyright (c) 2025, Postgres Professional

# Does not support the PGXS infrastructure at this time. Please, compile as part
# of the contrib source tree.

shared_ispell_sources = files(
  'src' / 'shared_ispell.c'
)

if host_system == 'windows'
  shared_ispell_sources += rc_lib_gen.process(win32ver_rc, extra_args: [
    '--NAME', 'shared_ispell',
    '--FILEDESC', 'shared_ispell - provides a shared ispell dictionary, i.e. a dictionary that\'s stored in shared segment.',])
endif

shared_ispell = shared_module('shared_ispell',
  shared_ispell_sources,
  kwargs: contrib_mod_args,
)
contrib_targets += shared_ispell

install_data(
  'shared_ispell.control',
  'shared_ispell--1.1.0.sql',
  kwargs: contrib_data_args,
)

tests += {
  'name': 'shared_ispell',
  'sd': meson.current_source_dir(),
  'bd': meson.current_build_dir(),
  'regress': {
    'sql': [
      'security',
      'shared_ispell',
    ],
    'regress_args': ['--temp-config', files('postgresql.conf')],
  },
}
