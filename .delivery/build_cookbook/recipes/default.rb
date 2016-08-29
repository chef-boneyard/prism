#
# Cookbook Name:: build_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#########################################################################
# Habitat
#########################################################################
include_recipe 'habitat-build::default'

#########################################################################
# Docker
#########################################################################
include_recipe 'chef-apt-docker::default'

package "docker-engine"

# Ensure the `dbuild` user is part of the `docker` group so they can
# connect to the Docker daemon
execute "usermod -aG docker #{node['delivery_builder']['build_user']}"

#########################################################################
# Ruby
#########################################################################

ruby_install node['build_cookbook']['ruby_version']

# get to the project root and use it as a cache
# as it is persistent between build jobs
gem_cache = File.join(node['delivery']['workspace']['root'], '../../../project_gem_cache')

directory gem_cache do
  # set the owner to the dbuild so that the other recipes can write to here
  owner node['delivery_builder']['build_user']
  mode '0755'
  recursive true
  action :create
end
