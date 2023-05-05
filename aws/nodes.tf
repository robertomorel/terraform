# Node Group:
## Grupo onde colocamos várias máquinas
#### Qual o mínimo de máquinas funcionando
#### Quantas eu desejo funcionando
#### Qual o máximo funcionando 
#### Qual a especificação destas máquinas

resource "aws_iam_role" "node" {
  name = "${var.prefix}-${var.cluster_name}-role-node"
  # ECS: máquina que vamos subir pra entrar no kubernetes (Elastic Cloud Compute)
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }    
        ]
    }
  POLICY
}

# Policies ####

# Acessar como um node - worker 
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

# Permite a comunicação entre nodes (CNI)
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# Se eu subir as imagens docker do conteinar Resgistry da Amazon, essa minha mãquina tem que ter permissão 
# para acessar o container, baixar a imagem e botar pra funcionar
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}


##### Criando o node (Elastic Kubernetes Cluster)
resource "aws_eks_node_group" "node-1" {
  # O cluster  
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-1"
  node_role_arn   = aws_iam_role.node.arn
  # Subnets
  subnet_ids     = var.subnet_ids
  instance_types = ["t3.micro"]
  # Configurações de escalabilidade
  scaling_config {
    desired_size = var.desired_size # tamanho desejado
    max_size     = var.max_size     # Max de máquinas
    min_size     = var.min_size     # Min de máquinas
  }

  # Policies
  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
