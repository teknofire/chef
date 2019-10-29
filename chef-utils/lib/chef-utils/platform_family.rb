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

require_relative "internal"

module ChefUtils
  module PlatformFamily
    include Internal

    # Determine if the current node is arch linux.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def arch?(node = __getnode)
      node["platform_family"] == "arch"
    end
    # chef-sugar backcompat methods
    alias_method :arch_linux?, :arch?

    # Determine if the current node is aix
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def aix?(node = __getnode)
      node["platform_family"] == "aix"
    end

    # Determine if the current node is a member of the debian family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def debian?(node = __getnode)
      node["platform_family"] == "debian"
    end

    # Determine if the current node is a member of the fedora family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def fedora?(node = __getnode)
      node["platform_family"] == "fedora"
    end

    # Determine if the current node is a member of the OSX family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def mac_os_x?(node = __getnode)
      node["platform_family"] == "mac_os_x"
    end
    alias_method :osx?, :mac_os_x?
    alias_method :mac?, :mac_os_x?
    alias_method :macos?, :mac_os_x?

    # Determine if the current node is a member of the redhat family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def rhel?(node = __getnode)
      node["platform_family"] == "rhel"
    end
    alias_method :el?, :rhel?

    # Determine if the current node is a member of the amazon family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def amazon?(node = __getnode)
      node["platform_family"] == "amazon"
    end
    alias_method :amazon_linux?, :amazon?

    # Determine if the current node is solaris2
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def solaris2?(node = __getnode)
      node["platform_family"] == "solaris2"
    end
    # chef-sugar backcompat methods
    alias_method :solaris?, :solaris2?

    # Determine if the current node is smartos
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def smartos?(node = __getnode)
      node["platform_family"] == "smartos"
    end

    # Determine if the current node is a member of the suse family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def suse?(node = __getnode)
      node["platform_family"] == "suse"
    end

    # Determine if the current node is a member of the gentoo family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def gentoo?(node = __getnode)
      node["platform_family"] == "gentoo"
    end

    # Determine if the current node is freebsd
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def freebsd?(node = __getnode)
      node["platform_family"] == "freebsd"
    end

    # Determine if the current node is openbsd
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def openbsd?(node = __getnode)
      node["platform_family"] == "openbsd"
    end

    # Determine if the current node is netbsd
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def netbsd?(node = __getnode)
      node["platform_family"] == "netbsd"
    end

    # Determine if the current node is dragonflybsd
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def dragonflybsd?(node = __getnode)
      node["platform_family"] == "dragonflybsd"
    end

    # Determine if the current node is a member of the windows family.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def windows?(node = __getnode(true))
      # This is all somewhat complicated.  We prefer to get the node object so that chefspec can
      # stub the node object.  But we also have to deal with class-parsing time where there is
      # no node object, so we have to fall back to RUBY_PLATFORM based detection.  We cannot pull
      # the node object out of the Chef.run_context.node global object here (which is what the
      # false flag to __getnode is about) because some run-time code also cannot run under chefspec
      # on non-windows where the node is stubbed to windows.
      #
      # As a result of this the `windows?` helper and the `ChefUtils.windows?` helper do not behave
      # the same way in that the latter is not stubbable by chefspec.
      #
      node ? node["platform_family"] == "windows" : windows_ruby_platform?
    end

    # Determine if the ruby VM is currently running on a windows node (chefspec can never stub
    # this behavior, so this is useful for code which can never be parsed on a non-windows box).
    #
    # @return [Boolean]
    #
    def windows_ruby_platform?
      !!(RUBY_PLATFORM =~ /mswin|mingw32|windows/)
    end

    #
    # Platform-Family-like Helpers
    #
    # These are meta-helpers which address the issue that platform_family is single valued and cannot
    # be an array while a tree-like Taxonomy is what is called for in some cases.
    #

    # If it uses RPM, it goes in here (rhel, fedora, amazon, suse platform_families).  Deliberately does not
    # include AIX because bff is AIX's primary package manager and adding it here would make this substantially
    # less useful since in no way can AIX trace its lineage back to old redhat distros.  This is most useful for
    # "smells like redhat, including SuSE".
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def rpm_based?(node = __getnode)
      fedora_derived?(node) || node["platform_family"] == "suse"
    end

    # RPM-based distros which are not SuSE and are very loosely similar to fedora, using yum or dnf.  The historical
    # lineage of the distro should have forked off from old redhat fedora distros at some point.  Currently rhel,
    # fedora and amazon.  This is most useful for "smells like redhat, but isn't SuSE".
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def fedora_derived?(node = __getnode)
      redhat_based?(node) || node["platform_family"] == "amazon"
    end

    # RedHat distros -- fedora and rhel platform_families, nothing else.  This is most likely not as useful as the
    # "fedora_dervied?" helper.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def redhat_based?(node = __getnode)
      %w{rhel fedora}.include?(node["platform_family"])
    end

    # All of the Solaris-lineage.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def solaris_based?(node = __getnode)
      %w{solaris2 smartos omnios openindiana opensolaris nexentacore}.include?(node["platform"])
    end

    # All of the BSD-lineage.
    #
    # Note that MacOSX is not included since Mac deviates so significantly from BSD that including it would not be useful.
    #
    # @param [Chef::Node] node
    #
    # @return [Boolean]
    #
    def bsd_based?(node = __getnode)
      # we could use os, platform_family or platform here equally
      %w{netbsd freebsd openbsd dragonflybsd}.include?(node["platform"])
    end

    extend self
  end
end
