module "aws-prod" {
  source = "../../infra"
  instancia = "t2.micro"
  regiao_aws = "us-east-2"
  chave = "iac-prod"
  sg_env = "prod"
  minimo = 1
  maximo = 10
  nomeGrupo = "prod"
}

/* output "IP" {
  value = module.aws-prod.IP_publico
} */
