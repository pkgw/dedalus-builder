# (intentionally no hashbang line)
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

"""This program is called from within our conda-build build scripts. It merges
the user's environment variables and those provided by conda-build. This is
needed because system compiler configurations often require funky
environments, but conda-build filters things in an effort to make things
controlled and reproducible. That's a generally laudable goal, but our goal
here is to build system-specific packages.

The merged environment information is printed to stdout in bash syntax so that
it can easily be imported into the build script's environment.

"""
import os
import pickle
import shlex
import sys


suppressed_vars = frozenset('''
SSH_CLIENT
SSH_CONNECTION
SSH_TTY
TERM
TERMCAP
'''.split())

def main(env_path, config_path):
    with open(env_path, 'rb') as f:
        user_env = pickle.load(f)

    with open(config_path, 'rt') as f:
        for line in f:
            if line.startswith('#'):
                continue
            var, value = line.strip().split('=', 1)
            user_env[var] = value

    cur_env = dict(os.environ)

    for var, value in user_env.items():
        if var in cur_env:
            # If conda-build has set the var already, go with its value. We could
            # conceivably merge in settings for variables like $PKG_CONFIG_PATH.
            continue

        if var in suppressed_vars:
            continue

        if var.startswith('BASH_'):
            continue # notably, skip bash function inheritance: BASH_FUNC_*. That's a bridge too far.

        if var.startswith('_ModuleTable'):
            continue # big state for lmod module system

        print('export %s=%s;' % (shlex.quote(var), shlex.quote(value)))


if __name__ == '__main__':
    main(*sys.argv[1:])
