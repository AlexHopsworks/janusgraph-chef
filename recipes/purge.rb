  bash 'kill_running_service' do
    user "root"
    ignore_failure true
    code <<-EOF
      service stop janusgraph
      systemctl stop janusgraph
    EOF
  end

  file "/etc/init.d/janusgraph" do
    action :delete
    ignore_failure true
  end

  file "/usr/lib/systemd/system/janusgraph.service" do
    action :delete
    ignore_failure true
  end
  file "/lib/systemd/system/janusgraph.service" do
    action :delete
    ignore_failure true
  end

  directory node['janusgraph']['home'] do
    recursive true
    action :delete
    ignore_failure true
  end

  link node['janusgraph']['base_dir'] do
    action :delete
    ignore_failure true
  end


package_url = "#{node['janusgraph']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

file cached_package_filename do
  action :delete
  ignore_failure true
end

