require 'spec_helper'

describe service('janusgraph') do  
  it { should be_enabled   }
  it { should be_running   }
end 

