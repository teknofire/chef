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
  module Which
    include Internal

    def which(*cmds, extra_path: nil, &block)
      where(*cmds, extra_path: extra_path, &block).first || false
    end

    def where(*cmds, extra_path: nil, &block)
      extra_path ||= __extra_path
      paths = __env_path.split(File::PATH_SEPARATOR) + Array(extra_path)
      paths.uniq!
      cmds.map do |cmd|
        paths.map do |path|
          filename = File.join(path, cmd)
          filename if __valid_executable?(filename, &block)
        end.compact
      end.flatten
    end

    private

    # @api private
    def __extra_path
      nil
    end

    # @api private
    def __valid_executable?(filename, &block)
      is_executable =
        if __transport_connection
          __transport_connection.file(filename).stat[:mode] & 1 && !__transport_connection.file(filename).directory?
        else
          File.executable?(filename) && !File.directory?(filename)
        end
      return false unless is_executable

      block ? yield(filename) : true
    end

    extend self
  end
end
