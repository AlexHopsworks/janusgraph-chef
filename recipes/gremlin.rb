case node['platform']
when "ubuntu"
 if node['platform_version'].to_f <= 14.04
   node.override['janusgraph']['systemd'] = "false"
 end
end

service_name="janusgraph-gremlin"

if node['janusgraph']['systemd'] == "true"

  service service_name do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  case node['platform_family']
  when "rhel"
    systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
  when "debian"
    systemd_script = "/lib/systemd/system/#{service_name}.service"
  end

  template systemd_script do
    source "#{service_name}.service.erb"
    owner "root"
    group "root"
    mode 0754
if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
end
    notifies :restart, resources(:service => service_name)
  end

  kagent_config "#{service_name}" do
    action :systemd_reload
  end

else #sysv

  service service_name do
    provider Chef::Provider::Service::Init::Debian
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  template "/etc/init.d/#{service_name}" do
    source "#{service_name}.erb"
    owner node['janusgraph']['user']
    group node['janusgraph']['group']
    mode 0754
if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
end
    notifies :restart, resources(:service => service_name), :immediately
  end

end

provenance_schema_configured = "#{node['janusgraph']['home']}/.janusgraph.#{node['janusgraph']['version']}.provenance_schema_configured"
bash 'config_provenance_schema' do
  user node['janusgraph']['user']
  code <<-EOH
    set -e
    #{node['janusgraph']['base_dir']}/bin/gremlin.sh -e #{node['janusgraph']['base_dir']}/scripts/provenance_schema.groovy
    touch #{provenance_schema_configured}
    chown -R #{node['janusgraph']['user']}:#{node['janusgraph']['group']} #{provenance_schema_configured}
  EOH
  not_if { ::File.exists?( provenance_schema_configured) }
end

if node['kagent']['enabled'] == "true"
   kagent_config service_name do
     service service_name
     log_file node['janusgraph']['gremlin_log']
   end
end
