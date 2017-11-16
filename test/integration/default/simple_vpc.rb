require 'awspec'
require 'rhcl'

# should strive to randomize the region for better testing
example_main = Rhcl.parse(File.open('examples/simple-vpc/main.tf'))
region = example_main['provider']['aws']['region']
ENV['AWS_REGION'] = region
vpc_name = example_main['module']['vpc']['name']
user_tag = example_main['module']['vpc']['tags']['Owner']
environment_tag = example_main['module']['vpc']['tags']['Environment']

# outputs can potentially be useful for tests
# tf_state = JSON.parse(File.open('.kitchen/kitchen-terraform/default-aws/terraform.tfstate').read)

describe vpc("#{vpc_name}") do
  it { should exist }
  it { should be_available }
  it { should have_tag('Name').value("#{vpc_name}") }
  it { should have_tag('Owner').value("#{user_tag}") }
  it { should have_tag('Environment').value("#{environment_tag}") }
  it { should have_route_table("#{vpc_name}-public") }
  ['a','b','c'].each do |az|
    it { should have_route_table("#{vpc_name}-private-#{region}#{az}") } 
  end

end

['a','b','c'].each do |az|
  describe subnet("#{vpc_name}-public-#{region}#{az}") do
    it { should exist }
    it { should be_available }
    it { should belong_to_vpc("#{vpc_name}") }
    it { should have_tag('Name').value("#{vpc_name}-public-#{region}#{az}") }
    it { should have_tag('Owner').value("#{user_tag}") }
    it { should have_tag('Environment').value("#{environment_tag}") }
  end
end
