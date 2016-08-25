#
# Cookbook Name:: build_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'habitat-build::default'

execute 'bundle install' do
  cwd File.join(delivery_workspace_repo, 'app')
end
