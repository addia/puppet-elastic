require 'spec_helper'
describe 'filebeat' do

  context 'with defaults for all parameters' do
    it { should contain_class('filebeat') }
  end
end
