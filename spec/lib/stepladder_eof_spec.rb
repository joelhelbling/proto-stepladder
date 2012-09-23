require 'spec_helper'
require 'stepladder/eof'

describe Stepladder::EOF do
  subject { Stepladder::EOF }

  it { should be_eof }
end
