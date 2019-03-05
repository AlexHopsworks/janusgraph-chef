include_recipe "java"

group node["janusgraph"]["group"] do
  action :create
  not_if "getent group #{node["janusgraph"]["group"]}"
end

user node["janusgraph"]["user"] do
  gid node["janusgraph"]["group"]
  manage_home true
  home "/home/#{node["janusgraph"]["user"]}"
  action :create
  shell "/bin/bash"
  not_if "getent passwd #{node["janusgraph"]["user"]}"
end

group node["janusgraph"]["group"] do
  action :modify
  members ["#{node["janusgraph"]["user"]}"]
  append true
end

directory node["janusgraph"]["dir"]  do
  owner node["janusgraph"]["user"]
  group node["janusgraph"]["group"]
  mode "755"
  action :create
  not_if { File.directory?("#{node["janusgraph"]["dir"]}") }
end

directory node["janusgraph"]["home"] do
  owner node["janusgraph"]["user"]
  group node["janusgraph"]["group"]
  mode "750"
  action :create
end

link node["janusgraph"]["base_dir"] do
  owner node["janusgraph"]["user"]
  group node["janusgraph"]["group"]
  to node["janusgraph"]["home"]
end

package_url = "#{node['janusgraph']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "#{node['janusgraph']['user']}"
  mode "0644"
  action :create_if_missing
end

janusgraph_downloaded = "#{node['janusgraph']['home']}/.janusgraph.extracted_#{node['janusgraph']['version']}"
# Extract janusgraph
bash 'extract_janusgraph' do
  user "root"
  code <<-EOH
    set -e
    tar zxf #{cached_package_filename} -C /tmp
    mv /tmp/janusgraph-#{node['janusgraph']['version']}-hadoop2 #{node['janusgraph']['dir']}
    # remove old symbolic link, if any
    rm -f #{node['janusgraph']['base_dir']}
    ln -s #{node['janusgraph']['home']} #{node['janusgraph']['base_dir']}
    chown -R #{node['janusgraph']['user']}:#{node['janusgraph']['group']} #{node['janusgraph']['home']}
    chmod 770 #{node['janusgraph']['home']}
    chown -R #{node['janusgraph']['user']}:#{node['janusgraph']['group']} #{node['janusgraph']['base_dir']}
    touch #{janusgraph_downloaded}
    chown -R #{node['janusgraph']['user']}:#{node['janusgraph']['group']} #{janusgraph_downloaded}
  EOH
  not_if { ::File.exists?( janusgraph_downloaded ) }
end

template "#{node['janusgraph']['base_dir']}/scripts/provenance_schema.groovy" do
  source "provenance_schema.groovy.erb" 
  owner node['janusgraph']['user']
  group node['janusgraph']['group']
  mode 0750
end

template "#{node['janusgraph']['base_dir']}/scripts/provenance_procedures.groovy" do
  source "provenance_procedures.groovy.erb" 
  owner node['janusgraph']['user']
  group node['janusgraph']['group']
  mode 0750
end

template "#{node['janusgraph']['base_dir']}/conf/gremlin-server/gremlin-server.yaml" do
  source "gremlin-server.yaml.erb" 
  owner node['janusgraph']['user']
  group node['janusgraph']['group']
  mode 0750
end

template "#{node['janusgraph']['base_dir']}/conf/gremlin-server/janusgraph.sh" do
  source "janusgraph.sh.erb" 
  owner node['janusgraph']['user']
  group node['janusgraph']['group']
  mode 0750
end
