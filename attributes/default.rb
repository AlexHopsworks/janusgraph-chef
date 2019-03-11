include_attribute "kagent"

default['janusgraph']['version']                  = "0.3.1"
default['janusgraph']['user']                     = node['install']['user'].empty? ? "janusgraph" : node['install']['user']
default['janusgraph']['group']                    = node['install']['user'].empty? ? "janusgraph" : node['install']['user']
default['janusgraph']['url']                      = "#{node['download_url']}/janusgraph"
default['janusgraph']['binaries']['url']          = "#{node['janusgraph']['url']}/janusgraph-#{node['janusgraph']['version']}-hadoop2.tar.gz"
default['janusgraph']['systemd']                  = "true"
default['janusgraph']['dir']                      = node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['janusgraph']['base_dir']                 = node['janusgraph']['dir'] + "/janusgraph-hadoop2"
default['janusgraph']['home']                     = node['janusgraph']['dir'] + "/janusgraph-" + node['janusgraph']['version'] + "-hadoop2"
default['janusgraph']['gremlin']['pid_file']      = "/tmp/janusgraph-gremlin.pid"
default['janusgraph']['gremlin']['log']           = node['janusgraph']['base_dir'] + "/log/gremlin-server.log"
default['janusgraph']['gremlin']['port']          = 8182
default['janusgraph']['cassandra']['pid_file']    = "/tmp/janusgraph-cassandra.pid"
default['janusgraph']['cassandra']['log']         = node['janusgraph']['base_dir'] + "/log/cassandra.log"
default['janusgraph']['graphexp']['repo']         = "https://github.com/AlexHopsworks/graphexp.git"
default['janusgraph']['graphexp']['branch']       = "master"
default['janusgraph']['graphexp']['dir']          = node['janusgraph']['base_dir'] + "/graphexp"

