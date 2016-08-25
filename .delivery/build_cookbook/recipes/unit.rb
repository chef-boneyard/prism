#
# Cookbook Name:: build_cookbook
# Recipe:: unit
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
execute 'bundle exec rspec' do
  cwd File.join(delivery_workspace_repo, 'app')
end
