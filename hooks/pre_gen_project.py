#!/usr/bin/env python3
"""Checks that execute before the python project is created.

This script ensures that python module name is valid.

Note that this runs during ``temple setup`` and ``temple update``
"""
import re
import sys


MODULE_REGEX = r'^[a-zA-Z][_a-zA-Z0-9]+$'

module_name = '{{ cookiecutter.module_name }}'

if not re.match(MODULE_REGEX, module_name):
    print('ERROR: %s is not a valid Python module name!' % module_name)
    sys.exit(1)
