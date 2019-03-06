maintainer       "Alexandru Ormenisan"
maintainer_email "aaor@kth.se"
name             "janusgraph"
license          "Apache v2.0"
description      "Installs/Configures Janusgraph"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.10.0"
source_url       "https://github.com/AlexHopsworks/janusgraph-chef"

%w{ ubuntu debian centos }.each do |os|
  supports os
end

depends 'java'
depends 'kagent'
depends 'elastic'
depends 'nodejs'

recipe "janusgraph::install", "Installs Janusgraph"
recipe "janusgraph::cassandra", "Setup Janusgraph Cassandra"
recipe "janusgraph::gremlin", "Setup Janusgraph Gremlin with schema and init scripts for provenance"
recipe "janusgraph::purge", "Deletes Janusgraph"
recipe "janusgraph::dev", "Installs npm - http-server and graphexp to visualize provenance info"

attribute "janusgraph/user",
          :description => "User to run Janusgraph services as",
          :type => "string"

attribute "janusgraph/group",
          :description => "Group to run Janusgraph services as",
          :type => "string"

attribute "janusgraph/url",
          :description => "Url to Janusgraph artifacts(directory). We use janusgraph-0.3.1-hadoop2.tar.gz binaries",
          :type => "string"

attribute "janusgraph/dir",
          :description => "Parent directory to install janusgraph in (/srv is default)",
          :type => "string"

attribute "janusgraph/port",
          :description => "Port that janusgraph(gremlin-server) is listening to",
          :type => "string"