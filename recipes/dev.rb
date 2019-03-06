# Install NPM
include_recipe "nodejs"

package ['git', 'maven']

# Clone Graphexp
git node['janusgraph']['base_dir']  do
  repository node['janusgraph']['graphexp']['repo']
  revision node['janusgraph']['graphexp']['branch']
  user node['janusgraph']['user']
  group node['janusgraph']['group']
  action :sync
end

case node['platform_family']
when "debian"
  npm_package 'http-server' do
    user 'root'
  end
when 'redhat'
  # It's a bit of a pain to install npm packages on Centos.
  bash 'fail' do
    user 'root'
    group 'root'
    code <<-EOF
      exit 1
    EOF
  end
end