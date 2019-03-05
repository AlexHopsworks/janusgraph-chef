include_attribute "kagent"

default['janusgraph']['version']                  = "0.3.1"
default['janusgraph']['user']                     = node['install']['user'].empty? ? "janusgraph" : node['install']['user']
default['janusgraph']['group']                    = node['install']['user'].empty? ? "janusgraph" : node['install']['user']
default['janusgraph']['base_url']                 = "#{node['download_url']}/janusgraph"
default['janusgraph']['url']                      = "#{node['janusgraph']['base_url']}/janusgraph-#{node['janusgraph']['version']}-haddop2.tar.gz"
default['janusgraph']['systemd']                  = "true"
default['janusgraph']['dir']                      = node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['janusgraph']['base_dir']                 = node['janusgraph']['dir'] + "/janusgraph"
default['janusgraph']['home']                     = node['janusgraph']['dir'] + "/janusgraph-" + node['janusgraph']['version']
default['janusgraph']['pid_file']                 = "/tmp/janusgraph.pid"
default['janusgraph']['gremlin_log']              = node['janusgraph']['base_dir'] + "/log/gremlin-server.log"
default['janusgraph']['port']                     = 8182
