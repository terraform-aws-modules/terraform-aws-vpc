module "vpc" {
  source = "../../"

  name = "my-eks-cluster"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19", "10.0.128.0/20", "10.0.144.0/20"]
  public_subnets  = ["10.0.160.0/19", "10.0.192.0/19", "10.0.224.0/20", "10.0.240.0/20"]

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = {
    global = { foo = "bar" }
    0 = { "kubernetes.io/cluster/my-eks-cluster-name" = "shared" }
    1 = { "kubernetes.io/cluster/my-eks-cluster-name" = "shared" }
    2 = { "kubernetes.io/cluster/my-eks-cluster-name" = "shared" }
    3 = { "kubernetes.io/role/internal-elb" = 1 }
    4 = { "component" = "some other component"}
  }

  public_subnet_tags = {
    global = { foo = "bar" }
    0 = { "kubernetes.io/cluster/my-eks-cluster-name" = "shared" }
    1 = { "kubernetes.io/cluster/my-eks-cluster-name" = "shared" }
    2 = { "kubernetes.io/cluster/my-eks-cluster-name" = "shared" }
    3 = { "component" = "some other component"}
  }
}
