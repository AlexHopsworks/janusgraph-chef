case node['platform']
when "ubuntu"
 if node['platform_version'].to_f <= 14.04
   node.override['janusgraph']['systemd'] = "false"
 end
end

service_name="gremlin"

case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/#{service_name}.service"
else
  systemd_script = "/lib/systemd/system/#{service_name}.service"
end

service service_name do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template systemd_script do
  source "#{service_name}.service.erb"
  owner "root"
  group "root"
  mode 0754
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
  end
end

kagent_config service_name do
  action :systemd_reload
end

if node['kagent']['enabled'] == "true"
  kagent_config service_name do
    service service_name
    log_file node['janusgraph']['gremlin']['log']
  end
end

if node['install']['upgrade'] == "true"
  kagent_config "#{service_name}" do
    action :systemd_reload
  end
end

provenance_schema_configured = "#{node['janusgraph']['home']}/.janusgraph.#{node['janusgraph']['version']}.provenance_schema_configured"
bash 'config_provenance_schema' do
  user node['janusgraph']['user']
  code <<-EOH
    set -e
    #{node['janusgraph']['base_dir']}/bin/gremlin.sh -e #{node['janusgraph']['base_dir']}/scripts/provenance_schema.groovy
    touch #{provenance_schema_configured}
  EOH
  not_if { ::File.exists?( provenance_schema_configured ) }
end
