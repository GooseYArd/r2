#!/usr/bin/python
import tempfile
import os
import subprocess
import glob
import argparse
from os.path import basename
from glob import glob

def get_version_string(fn):
    tmp = tempfile.NamedTemporaryFile(delete=False)
    tmp.write('R2_VERSION')
    tmp.flush()

    cmd = "%s %s %s" % ('/usr/bin/m4', fn, tmp.name)
    p = subprocess.Popen(cmd,
                         shell=True,
                         stdout=subprocess.PIPE)
    
    l = None
    for l in p.stdout: 
        pass
    return l

def update_available(pkg, watchfile, curver):
    cmd = "/usr/bin/uscan --package %s --report --watchfile %s --upstream-version %s" % (pkg, watchfile, curver)
    p = subprocess.Popen(cmd,
                         shell=True,
                         stdout=subprocess.PIPE)
    p.wait()
    ret = p.returncode

    if not ret:
        return True

    return False

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--package", help="scan a specific package")
    args = parser.parse_args()

    sfx = ".mak.in"
    fmt = "{:<26} {:20}"
    pkgs = []

    submake_dir = "submakes"
    watch_dir = "watch"

    if args.package:
        if not args.package.endswith(sfx):
            p = args.package + sfx
            if os.path.exists(p):
                pkgs.append(p)
            else:
                print("Error: couldn't find %s" %p)
                sys.exit(1)
        else:
            pkgs.append(args.package)
    else:
        pkgs = glob(os.path.join(submake_dir, "*%s" % sfx))
 
    for fn in pkgs:
        pkg = basename(fn).replace(sfx, "")
        v = get_version_string(fn)
        watchfile = fn.replace(sfx, ".watch")
        watchfile = watchfile.replace(submake_dir, watch_dir)
        state = "missing watchfile"
        if os.path.exists(watchfile):
            state = "current"
            if update_available(pkg, watchfile, v):
                state = "update available"            

        print fmt.format(pkg, state)

