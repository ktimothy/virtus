require 'spec_helper'

describe Virtus::ClassMethods, '#attributes' do
  subject { object.attributes }

  before do
    @original_stderr, $stderr = $stderr, StringIO.new
  end

  after do
    $stderr = @original_stderr
  end

  let(:object) { Class.new { extend Virtus::ClassMethods } }

  it { should be_instance_of(Virtus::AttributeSet) }

  it 'returns a deprecation warning' do
    lambda { subject }.should change { $stderr.string.dup }.from('').to(
      "#{object}.attributes is deprecated. Use #{object}.attribute_set instead: #{__FILE__}:4\n"
    )
  end
end
