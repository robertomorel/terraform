
# Resource = Bloco
# Local = Provider
# File = Tipo
# "exemplo" é o nome do recurso

# https://registry.terraform.io/providers/hashicorp/local/latest/docs

# Local file consegue criar um arquivo no computador
resource "local_file" "exemplo" {
  content  = var.conteudo
  filename = "Roberto - Fullcycle Course"
}

# Variáveis
variable "conteudo" {
  type    = string
  default = "Hello World"
}

# Step 1: Inicializar o processo
#    -> "terraform init"
#    -> Instala o provider local hashicorp/local
#    -> Cria todos os arquivos ocultos: state, lock, ...
# Step 2: Plano de ação
#    -> "terraform plan"
#    -> Terraform mostra tudo o que será feito 
#    -> Gera um ID interno para o plano
# Step 3: Executar o plano
#    -> "terraform apply"
#    -> O Terraform mostra o plano de ação e pergunta se queremos aplicar as mudanças (criações, modificações, deleções)

output "id-do-arquivo" {
  value = resource.local_file.exemplo.id
}

output "conteudo" {
  value = var.conteudo
}
