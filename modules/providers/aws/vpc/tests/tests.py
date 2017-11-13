import unittest
import os
import sys
import terraform_validate

class TestTerraform(unittest.TestCase):
    """ Unit tests for Terraform using terraform_validate... """

    def setUp(self):
        """Tell the module where to find your terraform configuration folder"""
        self.path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../")
        self.v = terraform_validate.Validator(self.path)

    def test_tags_exist(self):
        """ Test resources have required tags"""

        tagged_resources = [
            "vpc"]

        required_tags = [
            "Type",
            "Env",
            "Name",
            "Terraform"]

        self.v.resources(tagged_resources).property('tags').should_have_properties(required_tags)

    def test_variables_have_defaults(self):
        """ Test optional variables have defaults set """
        self.v.error_if_property_missing()
        self.v.variable("name").default_value_equals("")
        self.v.variable("cidr").default_value_equals("")
        self.v.variable("dhcp_options_domain_name").default_value_equals("")
        self.v.variable("dhcp_options_netbios_node_type").default_value_equals("")

    def test_module_required_variables(self):
        """ Test required variables have no defaults set"""
        self.v.error_if_property_missing()
        self.v.variable("instance_tenancy").default_value_equals('default')
        self.v.variable("public_subnets").default_value_equals([])
        self.v.variable("database_subnets").default_value_equals([])
        self.v.variable("elasticache_subnets").default_value_equals([])
        self.v.variable("create_database_subnet_group").default_value_equals(True)
        self.v.variable("azs").default_value_equals([])
        self.v.variable("enable_dns_hostnames").default_value_equals(False)
        self.v.variable("enable_dns_support").default_value_equals(False)
        self.v.variable("enable_nat_gateway").default_value_equals(False)
        self.v.variable("single_nat_gateway").default_value_equals(False)
        self.v.variable("enable_dynamodb_endpoint").default_value_equals(False)
        self.v.variable("enable_s3_endpoint").default_value_equals(False)
        self.v.variable("map_public_ip_on_launch").default_value_equals(True)
        self.v.variable("enable_vpn_gateway").default_value_equals(False)
        self.v.variable("private_propagating_vgws").default_value_equals([])
        self.v.variable("public_propagating_vgws").default_value_equals([])
        self.v.variable("tags").default_value_equals({})
        self.v.variable("public_subnet_tags").default_value_equals({})
        self.v.variable("private_subnet_tags").default_value_equals({})
        self.v.variable("public_route_table_tags").default_value_equals({})
        self.v.variable("private_route_table_tags").default_value_equals({})
        self.v.variable("elasticache_subnet_tags").default_value_equals({})
        self.v.variable("enable_dhcp_options").default_value_equals(False)
        self.v.variable("dhcp_options_domain_name_servers").default_value_equals(["AmazonProvidedDNS"])
        self.v.variable("dhcp_options_ntp_servers").default_value_equals([])
        self.v.variable("dhcp_options_netbios_name_servers").default_value_equals([])

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(TestTerraform)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    sys.exit(not result.wasSuccessful())


