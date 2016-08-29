#
# Cookbook Name:: build_cookbook
# Recipe:: publish
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#########################################################################
# Build our plan with Habitat!
#########################################################################
include_recipe 'habitat-build::publish'

#########################################################################
# Push Dockerized version of our Hab pkg to our EC2 Container Registry
#########################################################################

execute 'export-prism-container' do
  command(lazy { <<-EOH
# Install the package we just built into the host so `hab pkg export` doesn't
# try to pull it from the public depot (aka Willem).
sudo #{hab_binary} install ./results/chef-prism-#{prism_build_version}-*.hart
# Export the package as a Docker container
sudo #{hab_binary} pkg export docker chef/prism/#{prism_habitat_build_version}
  EOH
  })
  cwd node['delivery_builder']['repo']
  live_stream true
end

execute 'push-package-router-container' do
  command(lazy { <<-EOH
docker tag chef/prism:#{prism_build_version} chef/prism/#{prism_build_version}
docker push chef:#{prism_build_version}
  EOH
  })
  cwd node['delivery_builder']['repo']
  environment(
    'HOME' => node['delivery']['workspace_path']
  )
  live_stream true
end
