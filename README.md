# Projeto Wordpress - AWS e Docker - PB Compass UOL 🖥️

### 1. instalação e configuração do DOCKER no host EC2.
### 2. Efetuar Deploy de uma aplicação Wordpress com: container de aplicação RDS database Mysql.
### 3. configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress.
### 4. configuração do serviço de Load Balancer AWS para a aplicação Wordpress.

![](/img/projetoAWS.png)

## Criação da VPC 🖥️

Faça o login na sua conta aws na barra de pesquisa e escreva VPC. Clique em ```criar``` VPC.

![](/img/vpc-criacao.png)

Agora selecione a opção ```VPC e muito mais```, coloque o nome desejado da VPC e crie subnets publicas e privadas duas cada. selecione duas AZs e coloque o gateways Nat ```1 por AZ``` no Endpoints da VPC coloque em ```Nenhuma``` e em seguida pode ```Criar VPC```.

Previsualização Esperada:
![](/img/previsu-vpc.png)

## Criação dos Security Groups 🔒

Na barra de pesquisa escreva ```Security groups``` Crie um security para o EFS, EC2, RDS e para o Load Balancer.

Configuração do SG EC2. Nas regras de entrada coloque:

    | Type  | Protocol | Port Range |    Source Type     |  Source   |
    | ----- | -------- | ---------- | ------------------ | --------- |
    | NFS   |   TCP    |    2049    |   personalizado    |   SG-EFS  |
    | HTTP  |   TCP    |    80      |   personalizado    |   SG-LB   |

Configuração do SG RDS:

    |     Type      | Protocol | Port Range |    Source Type    |   Source   |
    | ------------- | -------- | ---------- | ----------------- | ---------- |
    | MySQL/Aurora  |   TCP    |    3306    |   personalizado   |   SG-EC2   |

Configuração do SG Load Balance:

    |  Type   | Protocol | Port Range |    Source Type    |    Source     |
    | ------- | -------- | ---------- | ----------------- | ------------- |
    |  http   |   TCP    |     80     |   personalizado   |   0.0.0.0/0   |

Configuração do SG EFS:

    | Type  | Protocol | Port Range |    Source Type     |  Source   |
    | ----- | -------- | ---------- | ------------------ | --------- |
    | NFS   |   TCP    |    2049    |   personalizado    |   SG-EC2  |

## Criação do RDS MySQL

Pesquise RDS e clique assim que abrir vá em Criar um banco de dados. Na pagina que abrir selecione a opção ```Criação Padrão``` em seguinda procure o MySQL e selecione

![](/img/rds1.png)

Agora na parte de modelos coloque em ````Nivel gratuito``` agora em "Configurações" coloque o nome desejado do banco e nas credenciais pode manter o admin se desejar e crie uma senha forte.

![](/img/rds2.png)

Na Configuração da instância selecione ```db.t3.micro``` e no amazenamento coloque para ```gp3``` e em adicional limte ```22```.

![](/img/rds3.png)

Em Conectividade selecione a sua VPC criada em grupo de sub-redes, acesso publico deixa em "Não". Em grupos de seguranção selecione o criado anteriormente e em "Zona de disponibilidade" deixe ```Sem preferência```.

![](/img/rds4.png)

Por Último vá em Configurações adicional e na Opções de banco de dados crei um nome para ele e desmarque a opção backup automatizado para não ter custos adicionais. Após isso pode cria o Banco de dados.

## Criação do Modelo de execução

Em EC2 vá em modelo de execução e aperte criar. Dentro dele dê um nome a ele e selecione início rápido. Escolha uma iamgem linux e em tipo de instancias coloquei em ```t2.micro```.

![](/img/ME1.png)

Feito isso em ```Configurações de rede``` coloque a em uma Subnet privada e adicione o grupo de segurança criado para a mesma.

![](/img/ME2.png)

Agora em ```Detalhes avançados``` role ate o final e adicione o seu [USERDATA](/userdata.sh) após isso crie.

## Criação do EFS

Na barra de pesquisa coloque EFS, no local vá em criar. Na pagina de criação coloque um nome e escolha a vpc e depois aperte em personalizar.

[](/img/efs1.png)

em personalizar coloque tipo Regional e desabilite o bacukp para não ter cobrança adicional, no gerenciamento de ciclo coloquei todas as opções em ```Nenhum```:

![](/img/efs2.png)

em Configuração de performance coloque em ```Intermitente``` e ```uso geral``` e vá para o proximo:

![](/img/efs3.png)

Em redes coloquei a sua vpc e escolhas as subnets privadas e seu grupo de segurança e vá para proximo e criar:

![](/img/efs4.png)

Só lembre de pegar o fs ID para usar posteriormente.

## Criação do Grupo de Destino

Na EC2 procure Grupo de destino nas opções a esquerda, vá em criar,em configuração básica coloque um nome e selecione a VPC em verificação de integridade onde estiver o numero ```200``` adicione com virgula sem espaço ```302``` e vá para proximo selcione a instancia disponivel e inclua a porta 80.

## Criação do Load Balancer

Na EC2 procure o load balancer e clique para acessar e depois em criar, na tela de criação escolha ```Application Load Balancer``` em "Configuração básica" dê um nome e selecione "voltado para internet".

![](/img/lb1.png)

Em Mapeamento de rede Selecione a VPC criada e inclua a duas zonas de disponibilidade em subnet publicas ambas e selecione o grupo de seguranção logo abaixo.

![](/img/lb2.png)

Na parte Listeners e roteamento selecione o grupo de destino criado, role até o final em criar load balancer.

## Criação do auto scaling 

Na EC2 vá em criar auto scaling crie um nome e no modelo de execução escolha o seu criado e a versão e vá para o proximo.

![](/img/gas1.png)

em redes selecione a sua vpc e as subnets privadas e proximo.

![](/img/gas2.png)

No balanciador de carga coloque a opção ```anexar a um balanceador existente``` e em seguida escolha o seu drupo de destino criado disso role ate o final e ative as verificações.

![](/img/gas3.png)

![](/img/gas4.png)

No tamanho do grupo coloque em 2 em capacidade desejada e minima e na maxima coloque 4, role até o final e habilite coleta de metricas.

![](/img/gas5.png)

Depois dê proximo ate aparecer para criar e crie.






