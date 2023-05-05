# Precisamos conseguir acessar os clusters kubernetes 
# Para isso, precisamos do arquivo .kube/config, onde o kubernetes vai buscar o kube controll para conseguirmos acessar o cluster

# KUBECONFIG é um template do arquivo de configuração do kubernetes 

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: "${aws_eks_cluster.cluster.name}"
  name: "${aws_eks_cluster.cluster.name}"
current-context: "${aws_eks_cluster.cluster.name}"
kind: Config
preferences: {}
users:
- name: "${aws_eks_cluster.cluster.name}"
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.cluster.name}"
KUBECONFIG
}

# Deve gerar o arquivo do kubeconfig
resource "local_file" "kubeconfig" {
  filename = "kubeconfig"
  content  = local.kubeconfig
}


## Para rodar:

## https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
## A AWS tem uma camada a mais de segurança.

## Precisamos rodar "aws-iam-authenticator" no nosso terminal 

## Após isso:
## 1. Substituir o arquivo local para ter acesso ao kubernetes 
## "cp kubeconfig ~/.kube/config"
## 2. Listar todos os nodes
## "kubectl get nodes"
## 3. Pegar a instância do kubernetes 
## "kubectl get all"
## 4. Criando um deploy com a imagem do nginx
## "kubectl create deploy nginx --image=nginx" 
## 5. Buscando pods
## "kubectl get po"
## Exportando porta do pod do nginx
## "kubectl port-forward pod/nginx-<pod-id> 8181:80"
##### -> localhost:8181

## Destruir o terraform
## "terraform destroy"
