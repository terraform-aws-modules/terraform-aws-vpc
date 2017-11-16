require 'awspec'
require 'rhcl'
require 'aws-sdk'

# should strive to randomize the region for better testing
example_main = Rhcl.parse(File.open('examples/test_fixture/main.tf'))

vpc_name = example_main['module']['vpc']['name']
user_tag = example_main['module']['vpc']['tags']['Owner']
environment_tag = example_main['module']['vpc']['tags']['Environment']

# outputs can potentially be useful for tests
tf_state = JSON.parse(File.open('.kitchen/kitchen-terraform/default-aws/terraform.tfstate').read)

region = tf_state['modules'][0]['outputs']['region']['value']
ENV['AWS_REGION'] = region

ec2 = Aws::EC2::Client.new(region: region)
azs = ec2.describe_availability_zones()
zone_names = azs.to_h[:availability_zones].first(2).map { |az| az[:zone_name] }

describe vpc("#{vpc_name}") do
  it { should exist }
  it { should be_available }
  it { should have_tag('Name').value("#{vpc_name}") }
  it { should have_tag('Owner').value("#{user_tag}") }
  it { should have_tag('Environment').value("#{environment_tag}") }
  it { should have_route_table("#{vpc_name}-public") }
  zone_names.each do |az|
    it { should have_route_table("#{vpc_name}-private-#{az}") } 
  end
end

zone_names.each do |az|
  describe subnet("#{vpc_name}-public-#{az}") do
    it { should exist }
    it { should be_available }
    it { should belong_to_vpc("#{vpc_name}") }
    it { should have_tag('Name').value("#{vpc_name}-public-#{az}") }
    it { should have_tag('Owner').value("#{user_tag}") }
    it { should have_tag('Environment').value("#{environment_tag}") }
  end
end
