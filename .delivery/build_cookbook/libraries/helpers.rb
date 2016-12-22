#
# Cookbook Name:: build-cookbook
# Library:: _helper
#
# Copyright 2016, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

module BuildCookbook
  module Helper

    # 0.1.0-20160625155928
    def prism_build_version
      @prism_build_version ||= begin
        with_server_config do

          environment = if %w(verify build).include?(node['delivery']['change']['stage'])
            get_acceptance_environment
          else
            delivery_environment
          end

          # Load the Chef environment that maps to the current stage
          stage_chef_env = ::DeliveryTruck::Helpers::Provision.fetch_or_create_environment(get_acceptance_environment)
          build_version = stage_chef_env.override_attributes['applications']['prism']

          stage_chef_env.override_attributes['applications']['prism']
        end
      end
    end

    # 0.1.0/20160625155928
    def prism_habitat_build_version
      # Converts 0.1.0-20160625155928 into 0.1.0/20160625155928
      prism_build_version.gsub('-', '/')
    end
  end
end

Chef::Recipe.send(:include, BuildCookbook::Helper)
Chef::Resource.send(:include, BuildCookbook::Helper)
Chef::Provider.send(:include, BuildCookbook::Helper)
