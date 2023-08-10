module "aws-dev" {
  source = "../../infra"
  instancia = "t2.micro"
  regiao_aws = "us-east-2"
  chave = "iac-dev"
  sg_env = "dev"
  minimo = 0
  maximo = 1
  nomeGrupo = "dev"
}

/* output "IP" {
  value = module.aws-dev.IP_publico
} */