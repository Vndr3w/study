#!/usr/bin/python

# Copyright: (c) 2024 Your Name <your.email@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module

short_description: Creates a text file on remote host

version_added: "1.0.0"

description: This module creates a text file on the remote host with specified content.

options:
    path:
        description: Path to the file to be created on remote host.
        required: true
        type: str
    content:
        description: Content to write to the file.
        required: true
        type: str

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Create a file with content
- name: Create a test file
  my_own_module:
    path: /tmp/test_file.txt
    content: "Hello, this is test content"
'''

RETURN = r'''
path:
    description: Path to the file that was created/modified.
    type: str
    returned: always
    sample: '/tmp/test_file.txt'
content:
    description: Content that was written to the file.
    type: str
    returned: always
    sample: 'Hello, this is test content'
changed:
    description: Whether the file was changed.
    type: bool
    returned: always
'''

from ansible.module_utils.basic import AnsibleModule
import os

def run_module():
    # Define arguments
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    result = dict(
        changed=False,
        path='',
        content=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']
    result['path'] = path
    result['content'] = content

    # Check if file exists and content matches
    file_changed = False
    if os.path.exists(path):
        with open(path, 'r') as f:
            existing_content = f.read()
            if existing_content != content:
                file_changed = True
    else:
        file_changed = True

    # In check mode, just report what would change
    if module.check_mode:
        if file_changed:
            result['changed'] = True
            result['message'] = f'File {path} would be created/modified'
        else:
            result['message'] = f'File {path} already exists with correct content'
        module.exit_json(**result)

    # Actually perform the change
    if file_changed:
        try:
            # Create directory if it doesn't exist
            dirname = os.path.dirname(path)
            if dirname and not os.path.exists(dirname):
                os.makedirs(dirname, mode=0o755, exist_ok=True)
            
            # Write content to file
            with open(path, 'w') as f:
                f.write(content)
            result['changed'] = True
            result['message'] = f'Successfully created/modified file {path}'
        except Exception as e:
            module.fail_json(msg=f'Failed to write to file: {str(e)}', **result)
    else:
        result['message'] = f'File {path} already exists with correct content'

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
