# terraform-ansible-elastic

Infraestrutura elástica na AWS como código: um launch template, um Auto Scaling Group e um Load Balancer criados com Terraform, com as máquinas se configurando sozinhas via Ansible na inicialização.

Projeto do curso **Infraestrutura como código: montando uma infraestrutura elástica na AWS**, da Alura. Continuação de [terraform-ansible](https://github.com/ssdvd/terraform-ansible).

## Arquitetura

```
              ┌──────────────────┐
usuários ───► │  Load Balancer   │ :8000
              └────────┬─────────┘
                       │
              ┌────────▼─────────┐
              │ Auto Scaling     │  1 a 10 instâncias
              │ Group (2 AZs)    │  (launch template)
              └──────────────────┘
```

- **Launch template**: define a AMI Ubuntu, o tipo da instância, a chave e o security group.
- **Auto Scaling Group**: distribui as instâncias em duas zonas de disponibilidade e escala para manter o uso médio de CPU em 50% (target tracking).
- **Load Balancer**: recebe o tráfego na porta `8000` e repassa para as instâncias do grupo.
- **Ansible no boot**: em produção, o `user_data` executa o [`ansible.sh`](env/prod/ansible.sh), que instala o Ansible na própria máquina e roda o playbook que sobe a API Django.

## Ambientes

O módulo [`infra/`](infra) é o mesmo para os dois ambientes; a variável `producao` liga ou desliga o Load Balancer e o `user_data`.

| Variável | dev | prod |
| --- | --- | --- |
| `instancia` | `t2.micro` | `t2.micro` |
| `regiao_aws` | `us-east-2` | `us-east-2` |
| `chave` | `iac-dev` | `iac-prod` |
| `minimo` / `maximo` | 0 / 1 | 1 / 10 |
| `producao` | `false` | `true` |

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) 0.14.9 ou superior
- AWS CLI com credenciais no perfil `default`
- [Locust](https://locust.io/), só para o teste de carga

## Como usar

```bash
cd env/prod            # ou env/dev

# o módulo lê a chave pública deste diretório
ssh-keygen -f iac-prod # ou iac-dev

terraform init
terraform apply
```

Em produção, a API fica disponível na porta `8000` do DNS do Load Balancer (veja no console da EC2). Para remover o ambiente, rode `terraform destroy`.

## Teste de carga

O [`carga.py`](carga.py) simula usuários acessando a raiz da API, para ver o Auto Scaling em ação:

```bash
pip install locust
locust -f carga.py
```

Abra <http://localhost:8089>, informe o endereço do Load Balancer com a porta `8000` e inicie o teste.

## Estrutura

```
infra/      # módulo: launch template, ASG, load balancer, security group
env/dev/    # ambiente de desenvolvimento
env/prod/   # ambiente de produção + ansible.sh
carga.py    # teste de carga com Locust
notes/      # anotações das aulas
```

> O security group deste projeto libera todas as portas para qualquer origem, o que serve para estudo e não deve ser usado em produção.
