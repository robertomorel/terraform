# O cluster precisa de uma determinada proteção
# Precisa:
### Acessar internet
### Acessar alguma cosia
### Instalar algo
# Por conta disso, precisamos criar um security group para reguardar o cluster

resource "aws_security_group" "new_sg" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-sg"
  }
  # Regra de egress: permitir que o cluster tenha acesso à internet
  egress = {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"          # todos os protocolos liberados
    cidr_block      = ["0.0.0.0/0"] # todos os ips liberados
    prefix_list_ids = []
  }
}

# Também precisamos criar regras para controlar os cluster --> Policies & Roles
resource "aws_iam_role" "cluster" {
  name               = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }    
        ]
    }
  POLICY
}

# Anexar uma policy a uma role
# Nosso cluster vai ter essa role, e a role vai ter essa policy para que possamos executar as operações necessárias 
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPClusterPolicy"
}

# Configurando o cloud watch para capturar os logs dos clusters
resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/eks/${var.prefix}-${var.cluster_name}-log/cluster"
  retention_in_days = var.retention_in_days
}



##### Criando o cluster (Elastic Kubernetes Cluster)
resource "aws_eks_cluster" "cluster" {
  name = "${var.prefix}-${ver.cluster_name}"
  # Roles & Policies
  role_arn = aws_iam_role.cluster.arn
  # Tipos de logs
  enabled_cluster_log_types = ["api", "audit"]

  # Associando o cluster à VPC  
  vpc_config {
    # Subnets
    subnet_ids = aws_subnet.subnets[*].id
    # Security group
    security_group_ids = [aws_security_group.sg.id]
  }

  # Dependências   
  depends_on = [
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
  ]
}
