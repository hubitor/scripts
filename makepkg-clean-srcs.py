import re
import os
import shutil

def clean(dirc):
    d = dict()
    r = re.compile(r'((beta|[vpuar]|[_\.-])?\d+)+')
    files = os.listdir(dirc)

    for f in files:
        f1 = r.sub('X', f)
        try:
            d[f1].append(f)
        except:
            d[f1] = [f]
    for el in d:
        d[el].sort(reverse=True)

    for el in d:
        if len(d[el]) > 1:
            print("FILE:", d[el][0])
            print("RM:", d[el][1:])
            c = input("Y/N [Y] ? ")
            if not c or c in "yYoO":
                for f in d[el][1:]:
                    f = dirc + "/" + f
                    if os.path.isdir(f):
                        shutil.rmtree(f)
                    else:
                        os.remove(f)

# FIXME {,linux}{64,32} || x64 x86_32 i368
# FIXME 12.5 > 12
# v2 != 2
# python-3.5 != python 2.7

clean("/home/cache/makepkg-sources")
clean("/home/cache/makepkg-srcpackages")
