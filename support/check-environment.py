# (intentionally no hashbang line)
# Copyright (c) 2017, Peter K. G. Williams.
#
# This file is part of Dedalus, which is free software distributed
# under the terms of the GPLv3 license.  A copy of the license should
# have been included in the file 'LICENSE.txt', and is also available
# online at <http://www.gnu.org/licenses/gpl-3.0.html>.

"""Check and save the user's build environment. Note that this script runs in
Python *2* since that is what our outer build environment requires, since
Mercurial is Python-2-only.

"""
from __future__ import absolute_import, division, print_function

import os.path
import pickle
import signal
import sys
import time


ignore_env_vars = '''
DBUS_SESSION_BUS_ADDRESS
DESKTOP_AUTOSTART_ID
DESKTOP_SESSION
DISPLAY
OLDPWD
PWD
SESSION_MANAGER
SHLVL
_
'''.split()

conda_build_overridden_vars = '''
CONDA_PREFIX
LD_RUN_PATH
PERL
PKG_CONFIG_PATH
'''.split()

def main(env_path):
    # Propagate SIGINT so the parent shell quits if we get control-C'ed. See
    # https://github.com/pkgw/pwkit/blob/master/pwkit/cli/__init__.py#L74

    inner_excepthook = sys.excepthook

    def excepthook(etype, evalue, etb):
        inner_excepthook(etype, evalue, etb)
        if issubclass(etype, KeyboardInterrupt):
            signal.signal(signal.SIGINT, signal.SIG_DFL)
            os.kill(os.getpid(), signal.SIGINT)

    sys.excepthook = excepthook

    # On with the show.

    try:
        with open(env_path, 'rb') as f:
            prev_env = pickle.load(f)
    except IOError as e:
        if e.errno == 2:
            prev_env = None
        else:
            raise

    cur_env = dict(os.environ)
    for var in ignore_env_vars:
        cur_env.pop(var, None)

    any_warnings = False

    for var in conda_build_overridden_vars:
        if var in cur_env:
            print('WARNING: the variable %s will be overridden in the build process' % var)
            any_warnings = True

    if prev_env is not None:
        changed = []

        for key, val in cur_env.items():
            prev_val = prev_env.get(key)
            if prev_val is None:
                changed.append('new variable %s = "%s"' % (key, val))
            elif val != prev_val:
                changed.append('variable %s changed to "%s"' % (key, val))

        for key, val in prev_env.items():
            if key not in cur_env:
                changed.append('variable %s was removed' % key)

        if len(changed):
            print('WARNING: the build environment changed from the previous run:', file=sys.stderr)
            for desc in changed:
                print('   ', desc, file=sys.stderr)
            any_warnings = True

    if any_warnings:
        print('I will pause to let you hit control-C if you want to cancel the build.', file=sys.stderr)
        time.sleep(10)

    with open(env_path, 'wb') as f:
        pickle.dump(cur_env, f)


if __name__ == '__main__':
    main(sys.argv[1])
