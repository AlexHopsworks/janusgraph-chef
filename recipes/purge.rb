  bash 'kill_running_service' do
    user "root"
    ignore_failure true
    code <<-EOF
      service stop janusgraph-gremlin
      systemctl stop janusgraph-gremlin
      service stop janusgraph-cassandra
      systemctl stop janusgraph-cassandra
    EOF
  end

  file "/etc/init.d/janusgraph-gremlin" do
    action :delete
    ignore_failure true
  end

  file "/etc/init.d/janusgraph-cassandra" do
    action :delete
    ignore_failure true
  end

  file "/usr/lib/systemd/system/janusgraph-gremlin.service" do
    action :delete
    ignore_failure true
  end
  file "/lib/systemd/system/janusgraph-gremlin.service" do
    action :delete
    ignore_failure true
  end

  file "/usr/lib/systemd/system/janusgraph-cassandra.service" do
    action :delete
    ignore_failure true
  end
  file "/lib/systemd/system/janusgraph-cassandra.service" do
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

