#
# Cookbook Name:: build_cookbook
# Recipe:: unit
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

gem_cache = File.join(node['delivery']['workspace']['root'], '../../../project_gem_cache')

ruby_execute 'bundle install' do
  version node['build_cookbook']['ruby_version']
  cwd File.join(delivery_workspace_repo, 'app')
  environment('BUNDLE_PATH' => gem_cache)
end

ruby_execute 'bundle exec rspec' do
  version node['build_cookbook']['ruby_version']
  cwd File.join(delivery_workspace_repo, 'app')
  environment('BUNDLE_PATH' => gem_cache)
end
