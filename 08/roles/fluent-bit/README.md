# wpnops.fluent-bit

[![Build Status](https://github.com/wpnops/ansible-role-fluent-bit/workflows/CI/badge.svg)](https://github.com/wpnops/ansible-role-fluent-bit/actions)
[![Ansible Galaxy](https://img.shields.io/badge/wpninfra.fluent__bit-role-blue.svg)](https://galaxy.ansible.com/wpninfra/fluent_bit/)

An [ansible role](https://galaxy.ansible.com/wpninfra/fluent-bit) to install and configure fluent-bit.

Please refer to [fluentbit's documentation](https://docs.fluentbit.io/manual/) for tool specific configuration.

## Role Variables

| Name                              | Description                                                                                                           | Required | Default |
|-----------------------------------|-----------------------------------------------------------------------------------------------------------------------|----------|---------|
| fluentbit_svc.flush_seconds       | Fluentbit service flush time in seconds                                                                               | yes      | 5       |
| fluentbit_svc.daemon              | Boolean value to set if Fluent Bit should run as a Daemon (background) or not.                                        | yes      | false   |
| fluentbit_svc.log_level           | Set the logging verbosity level. Allowed values are: error, warn, info, debug and trace.                              | yes      | info    |
| fluentbit_svc.log_file            | Absolute path for an optional log file.  By default all logs are redirected to the standard error interface (stderr). | no       |         |
| fluentbit_svc.custom_parsers_file | Path for a parsers configuration file                                                                                 | no       |         |
| fluentbit_svc.custom_plugins_file | Path for a plugins configuration file                                                                                 | no       |         |
| fluentbit_svc.streams_file        | Path for the Stream Processor configuration file.                                                                     | no       |         |
| fluentbit_filters                 | Dictionary with fluentbit filters                                                                                     | no       |         |
| fluentbit_inputs                  | Dictionary with fluentbit inputs                                                                                      | no       |         |
| fluentbit_outputs                 | Dictionary with fluentbit outputs                                                                                     | no       |         |
| fluentbit_parsers                 | Dictionary with fluentbit custom written parsers                                                                      | no       |         |

**IF NO INPUTS OR OUTPUTS ARE DEFINED FLUENTBIT WILL INITIALIZE WITH THE FOLLOWING LOGGING STRUCTURE**
```
[INPUT]
  Name cpu
  Tag cpu_default

[OUTPUT]
  Name file
  Match cpu_default
  Path /dev/null
```
**EXAMPLE DICTIONARY BASED CONFIGURATION**
```
fluentbit_inputs:
  - name: cpu
    tag: cpu_default

fluentbit_outputs:
  - name: file
    match: cpu_default
    path: /dev/null
```
**IN CASE IT IS REQUIRED TO HAVE TOW KEYS WITH THE SAME NAME IN A CONFIGURATION DICTIONARY IT CAN BE SPECIFIED USING THE FOLLOWING FORMAT**
<br>
For example:
```
fluentbit_filters:
  - name: record_modifier
    match: '*'
    0__record: hostname ${HOSTNAME}
    1__record: product something
```
Will result in:
```
[FILTER]
  name record_modifier
  match *
  record hostname ${HOSTNAME}
  record product something
```
## Dependencies

By default this role does not depend on any external roles. If any such dependency is required please [add them](/meta/main.yml) according to [the documentation](http://docs.ansible.com/ansible/playbooks_roles.html#role-dependencies)

## Example Playbook

- hosts: servers
  roles:
     - role: wpninfra.fluent-bit

## Testing

Please make sure your environment has [docker](https://www.docker.com) installed in order to run role validation tests. Additional python dependencies are listed in the [requirements file](https://github.com/nephelaiio/ansible-role-requirements/blob/master/requirements.txt)

Role is tested against the following distributions (docker images):

  * Ubuntu Bionic
  * Ubuntu Focal
  * Centos 7
  * Centos 8
  * Rocky Linux 8

You can test the role directly from sources using command ` molecule test `

## License

This project is licensed under the terms of the [MIT License](/LICENSE)
