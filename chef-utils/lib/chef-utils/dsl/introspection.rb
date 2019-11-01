#
# Copyright:: Copyright 2018-2019, Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative "train_helpers"

module ChefUtils
  module DSL
    # This is for "introspection" helpers in the sense that we are inspecting the
    # actual server or image under management to determine running state (duck-typing the system).
    # The helpers here may use the node object state from ohai, but typically not the big 5:  platform,
    # platform_family, platform_version, arch, os.  The helpers here should infer somewhat
    # higher level facts about the system.
    #
    module Introspection
      include TrainHelpers

      # Returns whether the node is a docker container.
      #
      # @param [Chef::Node] node
      #
      # @return [Boolean]
      #
      def docker?(node = __getnode)
        # Using "File.exist?('/.dockerinit') || File.exist?('/.dockerenv')" makes Travis sad,
        # and that makes us sad too.
        !!(node && node.read("virtualization", "systems", "docker") == "guest")
      end

      # @param [Chef::Node] node
      #
      # @return [Boolean]
      #
      def systemd?(node = __getnode)
        file_exist?("/proc/1/comm") && file_open("/proc/1/comm").gets.chomp == "systemd"
      end

      # @param [Chef::Node] node
      #
      # @return [Boolean]
      #
      def kitchen?(node = __getnode)
        ENV.key?("TEST_KITCHEN")
      end

      # @param [Chef::Node] node
      #
      # @return [Boolean]
      #
      def ci?(node = __getnode)
        ENV.key?("CI")
      end

      def has_systemd_service_unit?(svc_name)
        %w{ /etc /usr/lib /lib /run }.any? do |load_path|
          file_exist?(
            "#{load_path}/systemd/system/#{svc_name.gsub(/@.*$/, "@")}.service"
          )
        end
      end

      def has_systemd_unit?(svc_name)
        # TODO: stop supporting non-service units with service resource
        %w{ /etc /usr/lib /lib /run }.any? do |load_path|
          file_exist?("#{load_path}/systemd/system/#{svc_name}")
        end
      end

      extend self
    end
  end
end
