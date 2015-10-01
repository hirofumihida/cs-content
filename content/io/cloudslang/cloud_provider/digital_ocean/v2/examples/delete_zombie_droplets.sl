# (c) Copyright 2015 Liran Tal
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
# The Apache License is available at
# http://www.apache.org/licenses/LICENSE-2.0
#
########################################################################################################
# This flow deletes all droplets considered zombie.
# A droplet is considered zombie if its name matches a given pattern and its lifetime exceeds a given value.
#
# Inputs:
#   - time_to_live - optional - threshold to compare the droplet's lifetime to (in minutes)
#                  - Default: 150 minutes (2.5 hours)
#   - name_pattern - optional - regex pattern for zombie droplet names
#                  - Default: ci-([0-9]+)-coreos-([0-9]+)
#   - token - personal access token for DigitalOcean API
#   - proxy_host - optional - proxy server used to access the web site
#   - proxy_port - optional - proxy server port
#   - proxy_username - optional - user name used when connecting to the proxy
#   - proxy_password - optional - proxy server password associated with the <proxyUsername> input value
#   - connect_timeout - optional - time to wait for a connection to be established, in seconds (0 represents infinite value)
#   - socket_timeout - optional - time to wait for data to be retrieved, in seconds (0 represents infinite value)
########################################################################################################
namespace: io.cloudslang.cloud_provider.digital_ocean.v2.examples

imports:
  droplets: io.cloudslang.cloud_provider.digital_ocean.v2.droplets

flow:
  name: delete_zombie_droplets

  inputs:
    - time_to_live: 150
    - name_pattern: "'ci-([0-9]+)-coreos-([0-9]+)'"
    - token
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
    - connect_timeout:
        required: false
    - socket_timeout:
        required: false

  workflow:
    - retrieve_droplets_information:
        do:
          droplets.list_all_droplets:
            - token
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - connect_timeout
            - socket_timeout
        publish:
          - droplets

    - process_droplets_information:
        loop:
          for: droplet in droplets
          do:
            delete_droplet_if_zombie:
              - droplet_id: str(droplet['id'])
              - droplet_name: droplet['name']
              - creation_time_as_string: str(droplet['created_at'])
              - time_to_live
              - name_pattern
              - token
              - proxy_host
              - proxy_port
              - proxy_username
              - proxy_password
              - connect_timeout
              - socket_timeout
          navigate:
            DELETED: SUCCESS
            NOT_DELETED: SUCCESS
            FAILURE: FAILURE
