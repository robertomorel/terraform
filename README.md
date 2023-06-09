# Terraform

O Terraform Cloud permite automação de infraestrutura para provisionamento, conformidade e gerenciamento de qualquer nuvem, datacenter e serviço.

> Clique [aqui](https://www.terraform.io/) para documentação

- É uma ferramenta OpenSource
- Desenvolvido em Golang
- Através de um arquivo manifesto, podemos fazer configurações, provisionamento e instalações na nossa estrutura
- Provisionando a infraestrutura
  - Tomar todos os componentes (vpc, security groud, internet gateway...) na nossa arquitetura (infra) e fazer com que estes seram criados na cloud, por exemplo
- Providers: camada de abstração que podemos usar para nos comunicarmos com diversas clould platforms diferentes
  - AWS
  - Google
  - Cluster Kubernetes
- Utiliza a linguagem HCL
  - HashiCorp Configuration Language
- Instalação [aqui](https://developer.hashicorp.com/terraform/downloads)

## Idempotência

É um tipo de swich controlado para que não façamos a mesma tarefa mais de uma vez (duplicação de tarefas).

Exemplo:

1. Subimos um servidor na AWS
2. Queremos fazer uma alteração no servidor ou lançar um VPN.
3. Vamos rodar novamente o manifesto e o Terraform sabe aquilo que já foi executado e aquilo que é novo

### Imperatividade

Em todo processo, nós temos steps. O trabalho imperativo sempre irá refazer os passos a cada nova alteração.

### Declaratividade

Trabalhando de forma declarativa, eu explicito o que quero como resultado final. Desta forma, o sistema deve se organizar para gerar aquele resultado final. O terraform trabalha dessa forma.

### Gerenciamento de Estado

Quando queremos provisionar uma estrutura com o Terraform, ele faz um log do estado total (step by step), então sempre que queremos alterar um estado, ele compara o que tem e o que deve ser feito.
Nem tudo que queremos fazer é possível sem quebrar algum estado anterior. Algumas vezes o Terraform tem que se livrar de estados anteriores para refazer o plano de ação.

O arquivo de state do Terraform é um dos arquivos principais. É o log de tudo o que já foi feito.
Sem o state, sempre teríamos que começar todo o plano de ação do zero.

### Providers

O Terraform tem uma [lista de providers](https://registry.terraform.io/browse/providers) com o que trabalha.

- Oficiais
- Verificados
- Comunidade

## Terraform vs Ansible

Cada um de forma geral tem um propósito mais forte

- Terraform: provisionar estrutra
- Ansible: Automatiza instalações e configurações

Porém existe um overlap entre as ferramentas. Geralmente são usados ambos em conjunto.

## Steps

### Step 1: Inicializar o processo

- Rode: `terraform init`
- Instala o provider local hashicorp/local
- Cria todos os arquivos ocultos: state, lock, etc

### Step 2: Plano de ação

- Rode: `terraform plan`
- Terraform mostra tudo o que será feito
- Gera um ID interno para o plano

### Step 3: Executar o plano

- Rode: `terraform apply`
- O Terraform mostra o plano de ação e pergunta se queremos aplicar as mudanças
  - Criações, modificações, deleções
- Exemplo:
  > local_file.exemplo: Destroying... [id=bcf4a37395cfedf30540af9b3d41a6378da51f5c]
  > local_file.exemplo: Destruction complete after 0s
  > local_file.exemplo: Creating...
  > local_file.exemplo: Creation complete after 0s [id=8bf6807f693817de38671aec17e76f38c3dbe30d]

### Variáveis

Variáveis: https://developer.hashicorp.com/terraform/language/values/variables

- Para settar variáveis de linha de comando: `export TF_VAR_<nome_da_var>="veio de ambiente"`
- Nome da variável no apply: `terraform apply -var "conteudo=xpto"`

## Outputs

Usado quando queremos tomar um valor que pode ser necessário e solicitar que ele seja retornado como um output pós execução
Exemplo: caso queiramos o id de algum elemento/estado que será destruído.

- Before

```json
output "id-do-arquivo" {
  value = resource.local_file.exemplo.id
}

output "conteudo" {
  value = var.conteudo
}
```

- Output

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

conteudo = "Valor do output"
id-do-arquivo = "630d8851ec1f909e4e41e608fd0f54763a612791"
```

## Data Source

É utilizada para consultar a infra corrente já configurada.
Ler aquilo que já foi configurado

- Resources: o que nos ajuda a criar a infra
- Data Source: o que lê a infra

- Before

```json
data "local_file" "conteudo-exemplo" {
  filename = "Roberto - Fullcycle Course.txt"
}

output "data-source-result" {
  value = data.local_file.conteudo-exemplo.content
}

output "data-source-result-base64" {
  value = data.local_file.conteudo-exemplo.content_base64
}
```

- Output

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

conteudo = "Valor do output"
data-source-result = "Valor do output"
data-source-result-base64 = "VmFsb3IgZG8gb3V0cHV0"
id-do-arquivo = "630d8851ec1f909e4e41e608fd0f54763a612791"
```

## VPC

Virtual Private Cloud: rede com acesso limitado

- Exemplo: AWS
- Podemos configurar subredes (subnet) com zonas de disponibilidades diferentes

<p align="center">
  <a href="Virtual Private Cloud Model"><img height="301" src="./assets/img/vpc.png"></a>
</p>

### AWS

1. Criar conta na [AWS](https://aws.amazon.com/)
2. Criar um novo usuário para não utilizar o root

- Permissão: AdministratorAccess

3. Criar e configurar [AWS CLI](https://aws.amazon.com/cli/)

- Rode: 'aws configure'
- Informe a access key, secret e região

4. Criar VPC

- Criar arquivo "aws/providers.tf"
- Criar arquivo "aws/vpc.tf"
  - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
- Criar as subnets no "aws/vpc.tf"

### Módulos

O módulo é um conceito que pega um agrupamento de resources e unifica em um único arquivo.
O módulo pode ser todo executado de uma vez só.

#### Uso

Exemplo:

```
module "eks" {
    source = "./modules/eks"
    prefix = var.prefix
    vpc_id = module.new-vpc.vpc_id
    cluster_name = var.cluster_name
    retention_days = var.retention_days
    subnet_ids = module.new-vpc.subnet_ids
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
}
```
