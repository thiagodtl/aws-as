# Configuração de VPC para WordPress com AWS

Esta documentação descreve como criar uma VPC na AWS com duas sub-redes públicas e duas privadas, incluindo tabelas de rotas e conexões de rede, para hospedar um site WordPress.

## 1. Criando a VPC

1. No Console da AWS, vá para **VPC** e clique em **Criar VPC**.
2. Defina os seguintes parâmetros:
   - **Nome da VPC**: `vpc-wp`
   - **Bloco CIDR IPv4**: `10.0.0.0/16`
   - **Tenancy**: **Default**
3. Clique em **Criar VPC**.

## 2. Criando Sub-redes

### 2.1. Sub-redes Públicas

1. No Console da AWS, navegue até **Sub-redes** e clique em **Criar sub-rede**.
2. Para a primeira sub-rede pública:
   - **Nome da Sub-rede**: `wp-publica-01`
   - **VPC**: `vpc-wp`
   - **Zona de Disponibilidade**: `us-east-1a` 
   - **Bloco CIDR**: `10.0.1.0/24`
3. Clique em **Criar Sub-rede**.
4. Repita o processo para criar a segunda sub-rede pública:
   - **Nome da Sub-rede**: `wp-publica-02`
   - **Zona de Disponibilidade**: `us-east-1b`
   - **Bloco CIDR**: `10.0.2.0/24`

### 2.2. Sub-redes Privadas

1. Repita o processo acima para criar duas sub-redes privadas:
   - **Nome da Sub-rede**: `wp-privada-01` (us-east-1a, CIDR: `10.0.3.0/24`)
   - **Nome da Sub-rede**: `wp-privada-02` (us-east-1b, CIDR: `10.0.4.0/24`)

## 3. Criando Tabelas de Rotas

### 3.1. Tabela de Rotas Pública

1. Vá para **Tabelas de Rotas** e clique em **Criar Tabela de Rotas**.
2. Nomeie a tabela como `wp-public-route` e associe-a à VPC `vpc-wp`.
3. Clique em **Criar Tabela de Rotas**.
4. Após criada, vá até a seção de **Rotas** e adicione a seguinte rota:
   - **Destino**: `0.0.0.0/0`
   - **Destino do Alvo**: `Internet Gateway`
   - **Internet Gateway**: selecione o criado (wp-igw).
5. Vá para a aba de **Associações de Sub-rede** e associe as sub-redes públicas `wp-publica-01` e `wp-publica-02`.

### 3.2. Tabela de Rotas Privada

1. Repita o processo para criar a tabela de rotas privada:
   - Nome: `wp-route-private`
   - Não adicione rota para Internet.
2. Associe as sub-redes privadas `wp-privada-01` e `wp-privada-02` a essa tabela de rotas.

## 4. Criando Conexões de Rede

### 4.1. Internet Gateway (IGW)

1. Navegue até **Internet Gateway** e clique em **Criar Internet Gateway**.
2. Nomeie o gateway como `wp-igw` e clique em **Criar**.
3. Após criado, vá para a seção de **Ações** e selecione **Vincular à VPC**. Selecione a VPC `vpc-wp`.

### 4.2. NAT Gateway (NATG)

1. Vá para **NAT Gateway** e clique em **Criar NAT Gateway**.
2. Defina o nome como `wp-natg`.
3. Selecione a sub-rede pública `wp-publica-01` e crie um IP elástico.
4. Clique em **Criar NAT Gateway**.
5. Depois de criado, vá até a **Tabela de Rotas Privada** e adicione uma rota:
   - **Destino**: `0.0.0.0/0`
   - **Alvo**: `NAT Gateway`
   - Selecione `wp-natg`.

## 5. Verificação Final

1. Verifique se todas as sub-redes estão associadas às tabelas de rotas corretas.
2. Confirme que o Internet Gateway está vinculado à VPC.
3. Confirme que o NAT Gateway está associado à tabela de rotas privada.
4. Ao final o diagrama da VPC deve ficar como a imagem abaixo:
   ![image](https://github.com/user-attachments/assets/88c85eac-afad-499f-80d3-79b64334ba33)

   # CONFIGURANDO OS GRUPOS DE SEGURANÇA

   # Configuração do Grupo de Segurança para Load Balancer

Este documento descreve como configurar o grupo de segurança para um Load Balancer na AWS, baseado nas regras de entrada e saída apresentadas.

## 1. Criando o Grupo de Segurança

1. No Console da AWS, vá para **EC2** e depois para **Grupos de Segurança**.
2. Clique em **Criar grupo de segurança**.
3. Preencha os seguintes campos:
   - **Nome do Grupo de Segurança**: `load-balancer-sg`
   - **Descrição**: `Grupo de segurança para o Load Balancer`
   - **VPC**: Selecione a VPC associada (`vpc-wp` ou equivalente).

4. Clique em **Criar Grupo de Segurança**.

## 2. Configurando Regras de Entrada (Inbound Rules)

1. Após criar o grupo de segurança, vá para a aba de **Regras de Entrada** e clique em **Editar regras de entrada**.
2. Adicione a seguinte regra:

| Tipo   | Protocolo | Intervalo de Portas | Origem     | Descrição |
|--------|-----------|---------------------|------------|-----------|
| HTTP   | TCP       | 80                  | 0.0.0.0/0  | -         |

3. Esta regra permite o tráfego HTTP (porta 80) de qualquer origem (0.0.0.0/0), permitindo que o Load Balancer aceite conexões públicas.

4. Clique em **Salvar Regras**.

## 3. Configurando Regras de Saída (Outbound Rules)

1. Vá para a aba **Regras de Saída** e clique em **Editar regras de saída**.
2. Adicione a seguinte regra:

| Tipo             | Protocolo | Intervalo de Portas | Destino    | Descrição |
|------------------|-----------|---------------------|------------|-----------|
| Todo o tráfego   | Tudo      | Tudo                | 0.0.0.0/0  | -         |

3. Essa regra permite que o Load Balancer envie tráfego para qualquer destino, o que é importante para responder às solicitações recebidas.

4. Clique em **Salvar Regras**.

## 4. Associação ao Load Balancer

1. Navegue até o seu **Load Balancer** na seção **EC2 > Load Balancers**.
2. Edite as configurações de segurança do Load Balancer para associar o grupo de segurança recém-criado (`load-balancer-sg`).

## Conclusão

Com essas configurações, o grupo de segurança do Load Balancer estará configurado para permitir tráfego HTTP (porta 80) de qualquer origem e enviar tráfego de saída para qualquer destino, garantindo que o Load Balancer funcione corretamente para aplicações públicas.



