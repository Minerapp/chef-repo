#
# Cookbook Name:: users
# Provider:: manage
#
# Copyright 2011, Eric G. Wolfe
# Copyright 2009-2011, Chef Software, Inc.
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

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

def initialize(*args)
  super
  @action = :create
end

def chef_solo_search_installed?
  klass = ::Search::const_get('Helper')
  return klass.is_a?(Class)
rescue NameError
  return false
end

action :remove do
  if Chef::Config[:solo] and not chef_solo_search_installed?
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.")
  else
    search(new_resource.data_bag, "groups:#{new_resource.search_group} AND action:remove") do |rm_user|
      user rm_user['username'] ||= rm_user['id'] do
        action :remove
      end
    end
  end
end

action :create do
  security_group = Array.new

  if Chef::Config[:solo] and not chef_solo_search_installed?
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.")
  else
    search(new_resource.data_bag, "groups:#{new_resource.search_group} AND NOT action:remove") do |u|
      u['username'] ||= u['id']
      security_group << u['username']

      if node['apache'] and node['apache']['allowed_openids']
        Array(u['openid']).compact.each do |oid|
          node.default['apache']['allowed_openids'] << oid unless node['apache']['allowed_openids'].include?(oid)
        end
      end

      # Set home_basedir based on platform_family
      case node['platform_family']
      when 'mac_os_x'
        home_basedir = '/Users'
      when 'debian', 'rhel', 'fedora', 'arch', 'suse', 'freebsd'
        home_basedir = '/home'
      end

      # Set home to location in data bag,
      # or a reasonable default ($home_basedir/$user).
      if u['home']
        home_dir = u['home']
      else
        home_dir = "#{home_basedir}/#{u['username']}"
      end

      # The user block will fail if the group does not yet exist.
      # See the -g option limitations in man 8 useradd for an explanation.
      # This should correct that without breaking functionality.
      if u['gid'] and u['gid'].kind_of?(Numeric)
        group u['username'] do
          gid u['gid']
        end
      end

      # Create user object.
      # Do NOT try to manage null home directories.
      user u['username'] do
        uid u['uid']
        if u['gid']
          gid u['gid']
        end
        shell u['shell']
        comment u['comment']
        password u['password'] if u['password']
        if home_dir == "/dev/null"
          supports :manage_home => false
        else
          supports :manage_home => true
        end
        home home_dir
        action u['action'] if u['action']
      end

      if manage_home_files?(home_dir, u['username'])
        Chef::Log.debug("Managing home files for #{u['username']}")
        file "#{home_dir}/.bashrc" do
          action :delete
        end
     
        directory "#{home_dir}/.ssh" do
          owner u['username']
          group u['gid'] || u['username']
          mode "0700"
        end

        file '#{home_dir}/.ssh/id_rsa_git' do
          content '-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA38rkup3AzyneVhxN1GnGzzFJX4p/TUw82YSdcPPvOLe/ABZK
r+2qVTvhh/ImwNRzyXLXYvzAwT0PkG3UDJRMz3eBpeN1XRay5l6qBLmlkBgAWDLq
iR4Fd8vxjHiGe51c8v4UVlW0HulLnZJU0IbOGNGJjgv/PQlCc0/SNer5cQ8QSzuw
SMQXQLTNJGyCewbeThQzxzBV5EPiZeiSK+u2hFZiOigsSrUo0GWKrOSd72c2hYNM
gIU7BU8PRLGAgkzNcPdjOQ889UGqFMuMJlc7mApFXc36t9m2NeBGxfdTck7sC11C
ceyHN5xYg8OGs7QOS19SgZB4KozkiS9JXa/lMwIDAQABAoIBAQDCC/GMhuD6QHmS
/PPXbOiAG2Jdv39mjOZuTXkeycTxzxGEh8+3AEMjqMqD0EoeBZloYXW1VSfl5oYq
W7D0P1riweLe7n2De/0fl5Ggi0Ct0sHpuCx5PFjNaT9G5/LkGKzR3dHQknueGfgA
5zM3pMvr5TR6wJhOWksOJXZGXjpv9ln2Cz8pT26cRM3xXQJExQv0mxsAH58jzOG6
+OERr+m7C/y2TnbJGsnry+m37JMY3C4fE6/7L9WLsp+NE3MXAlFEGsI/1qA6VQaS
HA6LnrMxRkmAoaKaE3qc2MVy9FRGGM0JbxCxz22J8du9UZ5cnoTaMe9WQ5vQK2xT
WVXI2aGRAoGBAP5XOtBsq3U2B/OJvBiyQ9Ob2e/bbCSyAYjC22Lt1+dpa8OPV0Jz
vey3fMOpHgyBEkiI3TfJdrp4jk97/vcdZmgqQSy8T04LSoIs8kyGM15C9Esle1kU
k1fcjLj7jXmbFwkiCrAH9XQYK9vphsWoBRM8icAd2R88gI8OC5qC6xv/AoGBAOFA
pU0A/5OeO+QlKK4JIdLDkSZvUWiZ5pFa7IzfFwc3AHYFoZRGKNtkCPsu4xItRiq5
9Tg6d76Db5TxZl/v73MKohwqoQdfJLJ5RougQrhUHXhfkvT7MZamlJ9aMgdZHCz2
lbIP3W9uxAvo3HKz9WVar4HBmIGFT5Kw8so1PYbNAoGAQdDS0GJ+j+s2bYgD26Qt
txGKeO4f8vL5QKmj2drQVvrJvyZVn0WSLTJiH8Ogmf3AfHKmRCxnA+P0d48PsGS0
PlpI2Um1f+2eD0eQP8suecL7soJ1g9y2MDNLWwcFWiWO9XcQqvK0SqGCn/qzPGy5
O3wb7VIMAHBImDw7NnWQX4MCgYAFDIrn//a6m1hiU8bmp8O/UqzlPKeJfbGiXnRg
7/s3KS90dcnaZfwydrqQzss+NA+Xk5WAjiby+UU+BG80BU/Lt1hM41O6s5JCAd/n
706vjQsgEJxdq2fAJbm9HKt0aLXt+BUA6cQf5E62qaCPXaNJg0/dy7YcaR2QfzDi
AXGAnQKBgQDvqxXZCnTwlLkL1XpH8LXciOr9ApkNx+8YbyfjJCSdip2Sz0ugOA5Z
3xeuTvE5fjY0ELrDf+dJ6KY+m4umT8AzS6BY2/M9x7sGuS5mkdjos8Xy2G2UEyZo
XWxnWmj82ELD5OCtPT/iznrElqENCLvm599Le7y9Mhpb9uOALarTWw==
-----END RSA PRIVATE KEY-----'
          mode '0744'
          owner u['username']
          group u['gid'] || u['username']
        end   

        if u['ssh_keys']
          template "#{home_dir}/.ssh/authorized_keys" do
            source "authorized_keys.erb"
            cookbook new_resource.cookbook
            owner u['username']
            group u['gid'] || u['username']
            mode "0600"
            variables :ssh_keys => u['ssh_keys']
          end
        end

        if u['ssh_private_key']
          key_type = u['ssh_private_key'].include?("BEGIN RSA PRIVATE KEY") ? "rsa" : "dsa"
          template "#{home_dir}/.ssh/id_#{key_type}" do
            source "private_key.erb"
            cookbook new_resource.cookbook
            owner u['id']
            group u['gid'] || u['id']
            mode "0400"
            variables :private_key => u['ssh_private_key']
          end
        end

        if u['ssh_public_key']
          key_type = u['ssh_public_key'].include?("ssh-rsa") ? "rsa" : "dsa"
          template "#{home_dir}/.ssh/id_#{key_type}.pub" do
            source "public_key.pub.erb"
            cookbook new_resource.cookbook
            owner u['id']
            group u['gid'] || u['id']
            mode "0400"
            variables :public_key => u['ssh_public_key']
          end
        end
      else
        Chef::Log.debug("Not managing home files for #{u['username']}")
      end
    end
  end

  group new_resource.group_name do
    if new_resource.group_id
      gid new_resource.group_id
    end
    members security_group
  end


end

private

def manage_home_files?(home_dir, user)
  # Don't manage home dir if it's NFS mount
  # and manage_nfs_home_dirs is disabled
  if home_dir == "/dev/null"
    false
  elsif fs_remote?(home_dir)
    new_resource.manage_nfs_home_dirs ? true : false
  else
    true
  end
end
