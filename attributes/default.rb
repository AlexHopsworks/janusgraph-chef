include_attribute "kagent"

default['janusgraph']['version']                  = "0.3.1"
default['janusgraph']['user']                     = node['install']['user'].empty? ? "janusgraph" : node['install']['user']
default['janusgraph']['group']                    = node['install']['user'].empty? ? "janusgraph" : node['install']['user']
default['janusgraph']['url']                      = "#{node['download_url']}/janusgraph/janusgraph-#{node['janusgraph']['version']}-haddop2.zip"
default['janusgraph']['systemd']                  = "true"
default['janusgraph']['dir']                      = node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['janusgraph']['base_dir']                 = node['janusgraph']['dir'] + "/janusgraph"
default['janusgraph']['home']                     = node['janusgraph']['dir'] + "/janusgraph-" + node['janusgraph']['version']
default['janusgraph']['pid_file']                 = "/tmp/janusgraph.pid"
default['janusgraph']['gremlin_log']              = node['janusgraph']['base_dir'] + "/log/gremlin-server.log"
default['janusgraph']['port']                     = 8182
