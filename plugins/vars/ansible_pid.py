# Copyright 2019 Apis Networks, INC
#
# MIT License
#
#############################################
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
    vars: ansible_pid
    short_description: Get ansible-playbook PID
    description:
        - Gets PID of ansible-playbook master PID
'''

import os
from ansible.plugins.vars import BaseVarsPlugin
from ansible.utils.vars import combine_vars

class VarsModule(BaseVarsPlugin):

    def get_vars(self, loader, path, entities, cache=True):
        ''' parses the inventory file '''

        if not isinstance(entities, list):
            entities = [entities]

        super(VarsModule, self).get_vars(loader, path, entities)

        return {'ansible_pid': os.getpid()}
