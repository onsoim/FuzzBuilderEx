# -*- coding: utf-8 -*-

import os
import yaml

pProject= "oss-fuzz/projects"

def getProjects():
    return [ p for p in os.listdir(pProject) if os.path.isdir(f'{pProject}/{p}') ]

def save(ignore = ['labels']):
    infos   = {}
    keys    = {}

    for project in getProjects():
        with open(f'{pProject}/{project}/project.yaml', 'r') as f:
            infos[project] = yaml.safe_load(f)

            # keys += list(infos[project].keys())
            for k in infos[project].keys():
                if k not in ignore:
                    keys[k] = '-' # [] if type(v) == list else ""

    with open("list.csv", "w+") as fd:
        print(", ".join(["idx", "name"] + list(keys.keys())), file = fd)##

        idx = 0
        for name, info in infos.items():
            idx += 1
            i = dict(keys)
            for k, v in info.items():
                i[k] = v

            builder = [idx, name]
            for k, v in i.items():
                if k not in ignore:
                    builder += [ " | ".join([ _.strip() for _ in v if isinstance(_, str)]) if type(v) == list else v ]

            print(", ".join([ _.strip() if type(_) == str else str(_) for _ in builder ]), file = fd)##


if __name__ == "__main__":
    save()
