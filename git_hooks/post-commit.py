#!/usr/bin/env python
"""
This post-commit script is designed to call ``terraform fmt``, stage any
changed files, and create a new commit with a "STY: terraform fmt" message.

Care is taken to only add files that are modified by the format command,
so any other modified files that were not staged for the commit will
not be included.
"""

from os import environ
from subprocess import Popen, PIPE
from sys import exit
from textwrap import dedent


def cmd_out(cmd, exit_on_err=True, **kwargs):
    """ Get the output from a subprocess call."""
    kwargs.setdefault('env', environ)
    proc = Popen(cmd, stdout=PIPE, stderr=PIPE, **kwargs)
    out, err = proc.communicate()
    if proc.returncode and exit_on_err:
        print(err)
        exit(proc.returncode)
    return out.decode()


def run(cmd, exit_on_err=True, **kwargs):
    """ Just run a command, sending in/out to the shell."""
    kwargs.setdefault('env', environ)
    proc = Popen(cmd, **kwargs)
    proc.communicate()
    if proc.returncode and exit_on_err:
        exit(proc.returncode)


def modified_from_status(status_out):
    """ Return a generator of modified files from git status output.

    The output is expected to be in the format returned by
    ``git status --porcelain``
    """
    stripped = (ln.strip() for ln in status_out.split('\n'))
    modded = (ln for ln in stripped if ln.startswith('M'))
    return (ln.split()[1] for ln in modded)


def files_modified():
    """ Return a generator of modified files in the current repo."""
    return modified_from_status(cmd_out('git status --porcelain'.split()))


def main():
    start_modified = set(files_modified())
    run('terraform fmt'.split())
    newly_modified = set(files_modified()) - start_modified
    if newly_modified:
        run('git add'.split() + list(newly_modified))
        print(dedent('''

            `terraform fmt` has been run against the repo and updated files.
            Updated files will now be committed with the commit message
            "STY: terraform fmt"

        '''))
        run(('git', 'commit', '-m', '"STY: terraform fmt"'))


if __name__ == '__main__':
    main()
