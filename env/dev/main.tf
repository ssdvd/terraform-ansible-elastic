module "aws-dev" {
  source = "../../infra"
  instancia = "t2.micro"
  regiao_aws = "us-east-2"
  chave = "iac-dev"
  env = "dev"
}

output "IP" {
  value = module.aws-dev.IP_publico
}