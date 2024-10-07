# Configuração de VPC para WordPress com AWS

Com isso, fica criada VPC na AWS com duas sub-redes públicas e duas privadas, incluindo tabelas de rotas e conexões de rede, para hospedar um site WordPress.

## 1. Criando a VPC

1. No Console da AWS, vá para **VPC** e clique em **Criar VPC**.
2. Defina os seguintes parâmetros:
   - **Nome da VPC**: `vpc-wp`
   - **Bloco CIDR IPv4**: `10.0.0.0/16`
   - **Tenancy**: **Default**
3. Clique em **Criar VPC**.

   ![00 VPC](https://github.com/user-attachments/assets/d4fb285c-a73a-49fd-b76a-8217d58fe8e1)


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

Abaixo se explica configurar o grupo de segurança para um Load Balancer na AWS, baseado nas regras de entrada e saída apresentadas.

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

# Configuração do Grupo de Segurança para as EC2

## Security Group: ec2-sg

1. No Console da AWS, vá para **EC2** e depois para **Grupos de Segurança**.
2. Clique em **Criar grupo de segurança**.
3. Preencha os seguintes campos:
   - **Nome do Grupo de Segurança**: `ec2-sg`
   - **Descrição**: `Grupo de segurança para as EC2`
   - **VPC**: Selecione a VPC associada (`vpc-wp` ou equivalente).

### Regras de Entrada

| Nome | ID da Regra do Grupo | Versão do IP | Tipo           | Protocolo | Intervalo de Portas | Origem              | Descrição |
|------|----------------------|--------------|----------------|-----------|--------------------|--------------------|-----------|
| -    | sgr-08cc028f807cf0c95| -            | HTTP           | TCP       | 80                 | sg-046c18a8afe4bee... | -         |
| -    | sgr-05d4f35d581b6c561| IPv4         | NFS            | TCP       | 2049               | 0.0.0.0/0          | -         |
| -    | sgr-09758c3ac796a044b| IPv4         | MYSQL/Aurora   | TCP       | 3306               | 10.0.0.0/16        | -         |
| -    | sgr-0a8e9f9a508040be2| IPv4         | SSH            | TCP       | 22                 | 10.0.0.0/16        | -         |

## Obs.: Essa origem do grupo de segunrança é do grupo do Loud Balancer criado acima.

### Regras de Saída

| Nome | ID da Regra do Grupo | Versão do IP | Tipo         | Protocolo | Intervalo de Portas | Destino  | Descrição |
|------|----------------------|--------------|--------------|-----------|--------------------|----------|-----------|
| -    | sgr-053535c4ad9fc9f63| IPv4         | Todo o tráfego | Tudo     | Tudo               | 0.0.0.0/0 | -         |

## Descrição das Regras

### Regras de Entrada

1. **HTTP (Porta 80):**
   - Permite o tráfego HTTP na porta 80 de um grupo de segurança específico (`sg-046c18a8afe4bee...`).

2. **NFS (Porta 2049):**
   - Permite o tráfego NFS na porta 2049 de qualquer origem (`0.0.0.0/0`).

3. **MYSQL/Aurora (Porta 3306):**
   - Permite o tráfego MYSQL/Aurora na porta 3306 apenas da rede interna (`10.0.0.0/16`).

4. **SSH (Porta 22):**
   - Permite o acesso SSH na porta 22 apenas da rede interna (`10.0.0.0/16`).

### Regras de Saída

1. **Todo o Tráfego:**
   - Permite que todo o tráfego de saída seja enviado para qualquer destino (`0.0.0.0/0`), independentemente do tipo ou protocolo.

## Observações

- A configuração de entrada restringe o acesso a portas específicas.
- A configuração de saída está totalmente aberta, permitindo que a instância envie tráfego para qualquer destino sem restrições.

# Configuração do Grupo de Segunrança do RDS.

## Security Group: ec2-sg

1. No Console da AWS, vá para **RDS** e depois para **Grupos de Segurança**.
2. Clique em **Criar grupo de segurança**.
3. Preencha os seguintes campos:
   - **Nome do Grupo de Segurança**: `rds-sg`
   - **Descrição**: `Grupo de segurança para as EC2`
   - **VPC**: Selecione a VPC associada (`vpc-wp` ou equivalente).

## Security Group: `sg-0a110b2772810c3a4` - rds-sg

### Regras de Entrada

| Nome | ID da Regra do Grupo | Versão do IP | Tipo           | Protocolo | Intervalo de Portas | Origem              | Descrição |
|------|----------------------|--------------|----------------|-----------|--------------------|--------------------|-----------|
| -    | sgr-0a4aae4cf804a75c56| -            | MYSQL/Aurora   | TCP       | 3306               | sg-071700449bbd88d97... | -       |

### Regras de Saída

| Nome | ID da Regra do Grupo | Versão do IP | Tipo         | Protocolo | Intervalo de Portas | Destino  | Descrição |
|------|----------------------|--------------|--------------|-----------|--------------------|----------|-----------|
| -    | sgr-0fb06e3899bbc7e30| IPv4         | Todo o tráfego | Tudo     | Tudo               | 0.0.0.0/0 | -         |

## Obs.: Essa origem do grupo de segunrança é do grupo das EC2 criado acima.

## Descrição das Regras

### Regras de Entrada

1. **MYSQL/Aurora (Porta 3306):**
   - Permite o tráfego de entrada para o banco de dados MySQL/Aurora na porta 3306 apenas do grupo de segurança específico (`sg-071700449bbd88d97...`).

### Regras de Saída

1. **Todo o Tráfego:**
   - Permite que todo o tráfego de saída seja enviado para qualquer destino (`0.0.0.0/0`), independentemente do tipo ou protocolo.

## Observações

- A configuração de entrada é restritiva, permitindo conexões somente de um grupo de segurança específico, o que melhora a segurança do acesso ao banco de dados.
- A configuração de saída está totalmente aberta, permitindo que a instância envie tráfego para qualquer destino sem restrições. Isso é comum para RDS, pois permite a comunicação sem limitações com outros serviços.

# Configuração de Conectividade para RDS

## Passos para Configuração

### 1. Recurso de Computação

Durante a configuração, selecione a opção:
- **Não se conectar a um recurso de computação do EC2**
  - Isso indica que o RDS não estará diretamente conectado a uma instância EC2 específica, permitindo uma configuração mais flexível onde a conexão pode ser estabelecida manualmente mais tarde, se necessário.

### 2. Seleção da VPC (Nuvem Privada Virtual)

- **Escolha a VPC criada:** 
  - Esta VPC possui **4 Sub-redes** e **2 Zonas de Disponibilidade**, oferecendo alta disponibilidade e redundância para o banco de dados.

### 3. Grupo de Segurança de VPC

- **Opção escolhida:** `Selecionar existente`
  - Foi selecionado um grupo de segurança existente para garantir que as regras apropriadas de firewall estejam aplicadas ao banco de dados.

### 4. Grupos de Segurança da VPC Existentes

- **Grupo de Segurança selecionado:** `rds-sg`
  - Este grupo de segurança foi escolhido para controlar o tráfego de rede que pode acessar o banco de dados, garantindo que apenas instâncias permitidas possam se comunicar com ele.

## Observações

- A escolha de uma VPC com várias sub-redes e zonas de disponibilidade é uma prática recomendada para garantir que o banco de dados seja resiliente a falhas e tenha alta disponibilidade.
- Utilizar grupos de segurança existentes permite centralizar e padronizar as regras de acesso, facilitando a manutenção e a auditoria da segurança.

# Criação de um Sistema de Arquivos EFS

Aqui se explica as etapas necessárias para criar um sistema de arquivos EFS na AWS, incluindo a configuração de rede conforme exibido nas imagens fornecidas.

## Passos para Criar um EFS

### 1. Criar Sistema de Arquivos EFS

1. Acesse o console do Amazon EFS na AWS.
2. Clique no botão **Criar sistema de arquivos**.
3. Na tela de criação, configure as seguintes opções:
   - **Nome:** (Opcional) Insira um nome para identificar facilmente o sistema de arquivos.
   - **VPC (Virtual Private Cloud):** Selecione a VPC onde você deseja que as instâncias EC2 se conectem ao sistema de arquivos. 
    
4. Após configurar estas opções, clique em **Criar** para prosseguir.

### 2. Configuração de Rede do EFS

Após criar o sistema de arquivos, configure a rede para que o EFS esteja acessível em diferentes zonas de disponibilidade (AZ) que já foram criadas. No meu caso ficou as abaixo relacionadas:

| Zona de Disponibilidade (ID da AZ) | ID do Destino de Montagem | ID da Sub-rede                   | Estado do Destino de Montagem | Endereço IP | ID da Interface de Rede            | Grupos de Segurança                       |
|------------------------------------|--------------------------|--------------------------------|------------------------------|-------------|-----------------------------------|-----------------------------------------|
| us-east-1a (use1-az6)              | fsmt-01bf160ac4de3d896   | subnet-05b04002e0520657c        | Disponível                   | 10.0.1.21   | eni-079a7f91febdb1ed               | sg-071700449bbd88d97 (ec2-sg)            |
| us-east-1b (use1-az1)              | fsmt-0c6e860eb391923e6   | subnet-022c1cf04d9170d39        | Disponível                   | 10.0.3.136  | eni-00c19658ed4dcad58              | sg-071700449bbd88d97 (ec2-sg)            |

### 3. Passos para Configurar a Rede do EFS

1. **Configuração de Sub-redes e Zonas de Disponibilidade:**
   - Garanta que cada Zona de Disponibilidade tenha um destino de montagem associado.
   - Selecione sub-redes que estejam dentro da mesma VPC configurada no momento da criação do sistema de arquivos.

2. **Grupos de Segurança:**
   - Utilize grupos de segurança configurados para permitir acesso adequado ao sistema de arquivos EFS a partir das instâncias EC2.
   - Para este caso, o grupo de segurança utilizado é `sg-071700449bbd88d97 (ec2-sg)`, que deve estar configurado para permitir tráfego na rede privada.

3. **Endereços IP e Interfaces de Rede:**
   - Cada destino de montagem deve ter um endereço IP privado associado.
   - As interfaces de rede (`eni`) devem ser configuradas para comunicação dentro da VPC.

### Finalizando a Configuração

- Após configurar todos os parâmetros de rede e grupos de segurança, certifique-se de revisar as configurações para garantir que o EFS esteja disponível e acessível em todas as sub-redes configuradas.
- Salve e aplique as configurações para finalizar o processo de criação do EFS.

# Modelo de Execução para EC2

Aqui é descrito as configurações do modelo de execução para instâncias EC2 e os passos para sua correta configuração, incluindo a adição de um script de inicialização.

## Detalhes do Modelo de Execução

- **ID do Modelo de Execução:** `lt-00f81efe739ee99de`
- **Nome do Modelo de Execução:** `wp-ec2-template`
- **Versão Padrão:** `1`
- **Descrição:** `EC2 template`

## Detalhes da Versão do Modelo

### Detalhes da Instância

- **ID da AMI:** `ami-00f251754ac5da7f0`
- **Tipo de Instância:** `t2.micro`
- **Grupo de Segurança:** Escolha o grupo de segurança que foi criado para a EC2
- **Nome do Par de Chaves:** `projeto-docker` Obs.: Se não tiver o par de chaves, crie um.

### Configurações Importantes

1. **AMI e Tipo de Instância:**
   - A AMI utilizada é `ami-00f251754ac5da7f0`, que define a imagem base da instância.
   - O tipo de instância é `t2.micro`, adequado para workloads de baixo custo e aplicações de pequeno porte.

2. **Grupos de Segurança:**
   - O grupo de segurança associado é o da EC2, garantindo que as regras de segurança definidas sejam aplicadas para proteger a instância.

3. **Par de Chaves:**
   - Foi configurado para utilizar o par de chaves `projeto-docker` para acesso seguro à instância. Se não tiver a sua, crie.

## Configurações Avançadas

### Adição do Script de Inicialização (user_data)

Durante a criação da instância, é essencial adicionar um script de inicialização que configure a instância automaticamente. Para isso, siga os passos abaixo:

1. Acesse as **Configurações Avançadas** ao criar a instância baseada nesse modelo.
2. Na seção de **Dados de usuário**, adicione o conteúdo do script `user_data.sh`, que está disponível no repositório do projeto.
3. Certifique-se de que o script está configurado corretamente para inicializar os serviços e as configurações necessárias para a aplicação assim que a instância for iniciada.

### Sobre o Script `user_data.sh`

- O script `user_data.sh` é responsável por configurar automaticamente a instância, instalando pacotes e configurando o ambiente conforme necessário.
- Esse script é executado na primeira inicialização da instância, garantindo que ela esteja pronta para uso sem necessidade de configuração manual adicional.
- O script irá baixar o Docker, Docker Compose e montar o EFS.
# Obs.: Não esquecer de configurar o script com o seu ID da EFS criada.

## Observações

- O uso de scripts `user_data` é uma prática recomendada para automatizar o provisionamento de instâncias EC2, aumentando a eficiência e reduzindo erros humanos.
- Revise as configurações de segurança e o conteúdo do script para garantir que atendam às necessidades específicas do seu projeto.

# Criação e Configuração de um Load Balancer na AWS

Aqui explica as etapas para criar e configurar um Load Balancer do tipo Application na AWS, com base nas configurações mostradas na imagem fornecida.

### 1. Criação do Load Balancer

1. No console da AWS, acesse a seção de **Load Balancers**.
2. Clique em **Criar Load Balancer** e selecione **Application Load Balancer**.
3. Configure o Load Balancer com as seguintes opções:
   - **Nome:** `wp-lba`
   - **Esquema:** Selecione **Internet-facing** para tornar o Load Balancer acessível a partir da internet.
   - **VPC:** Escolha a VPC que você criou

4. Escolha as Zonas de Disponibilidade e Sub-redes:
   - Adicione as sub-redes publicas criadas

### 2. Configuração de Receptores

1. **Adicionar um receptor HTTP:**
   - Configure o receptor para ouvir na porta **80** com o protocolo **HTTP**.
   - Defina a ação padrão para **encaminhar** o tráfego para o grupo de destino `wp-destino`.

### 3. Configurações de Segurança

- **Política de Segurança:** Não aplicável para o protocolo HTTP sem SSL.
- **Certificado SSL/TLS:** Não aplicável, pois o tráfego é HTTP.

### 4. Verificações e Monitoramento

- **Status do Load Balancer:** Deve estar ativo após a configuração correta.
- **Monitoramento:** Use as ferramentas de monitoramento da AWS para rastrear o desempenho e a saúde do Load Balancer.

## Observações

- **Segurança:** Considere configurar HTTPS para proteger a comunicação do cliente ao Load Balancer.
- **Escalabilidade:** O Application Load Balancer é ideal para distribuir tráfego com base em regras e pode ser facilmente integrado a um grupo de Auto Scaling para gerenciar picos de tráfego.
- **DNS:** Use o nome DNS `wp-lba-1551271840.us-east-1.elb.amazonaws.com` para acessar seu Load Balancer.

# Criação de um Grupo de Auto Scaling na AWS

Aqui descreve os passos para criar um grupo de Auto Scaling na AWS, configurado conforme as especificações mostradas na imagem fornecida.

## Passo 1: Configuração do Grupo de Auto Scaling

### 1.1 Criação do Grupo de Auto Scaling

1. Acesse o console da AWS e vá para **EC2** > **Grupos de Auto Scaling**.
2. Clique em **Criar grupo de Auto Scaling**.

### 1.2 Configurações do Grupo

- **Nome do grupo de Auto Scaling:** `WP-SC`
- **Capacidade desejada:** 2 instâncias
- **Capacidade mínima:** 2 instâncias
- **Capacidade máxima:** 2 instâncias
- **Tipo de capacidade:** Unidades (número de instâncias)

### 1.3 Configurações de Rede

- **Zonas de Disponibilidade:** 
  - `us-east-1a` e `us-east-1b`
- **Sub-redes associadas:**
  - `subnet-02c1eaf9d71d53f17` (us-east-1b)
  - `subnet-0b892fca4530c34fe` (us-east-1a)

## Passo 2: Configuração do Modelo de Execução

### 2.1 Modelo de Execução

- **Modelo de execução:** `wp-ec2-template`
- **Versão:** Latest (Mais recente)
- **ID do modelo de execução:** `lt-00f81efe739ee99de`

### 2.2 Configurações de Instância

- **ID da AMI:** `ami-00f251754ac5da7f0`
- **Tipo de instância:** `t2.micro`
- **Grupo de segurança:** 
  - `sg-071700449bbd88d97`
- **Nome do par de chaves:** `projeto-docker`. Selecione o par de chaves já criados.

## Passo 4: Revisão e Finalização

1. Revise todas as configurações do grupo de Auto Scaling para garantir que estejam conforme os requisitos do projeto.
2. Clique em **Criar grupo de Auto Scaling** para finalizar a configuração.

## Observações

- **Alta Disponibilidade:** As configurações incluem várias zonas de disponibilidade para garantir alta disponibilidade e resiliência do serviço.
- **Escalabilidade Fixa:** A configuração é fixa em 2 instâncias, sem ajuste automático, ideal para cargas de trabalho que requerem uma quantidade constante de recursos.
- **Segurança:** As instâncias estão associadas a grupos de segurança previamente configurados para controlar o acesso à rede.

# Criação de um Load Balancer na AWS

### 1. Configuração do Load Balancer

1. Acesse o console da AWS e vá para **Load Balancers**.
2. Clique em **Criar Load Balancer** e selecione **Application Load Balancer**.
3. Configure com as seguintes opções:
   - **Nome do Load Balancer:** `wp-lba`
   - **Esquema:** Internet-facing
   - **VPC:** Escolha a VPC já criada.
   - **Sub-redes:** Selecione as duas sub-redes privadas:
     - `wp-privada-01` (us-east-1a)
     - `wp-privada-02` (us-east-1b)

### 4.2 Associação ao Grupo de Segurança

- Selecione o grupo de segurança criado anteriormente para o Auto Scaling.

### 4.3 Configuração do Listener

1. Configure um **Listener** para o Load Balancer:
   - **Protocolo:** HTTP
   - **Porta:** 80
2. Defina o **Grupo de Destino** para o tráfego de entrada:
   - **Grupo de Destino:** Selecione o grupo de instâncias associadas.

## Passo 5: Verificação e Finalização

1. Revise todas as configurações para garantir que tudo esteja configurado corretamente.
2. Clique em **Criar** para finalizar a configuração do Load Balancer.

## Observações

- **Alta Disponibilidade:** O uso de múltiplas sub-redes privadas em diferentes zonas de disponibilidade garante maior resiliência e alta disponibilidade do Load Balancer.
- **Segurança:** As regras de segurança devem ser revisadas regularmente para garantir que apenas o tráfego necessário seja permitido.
- **Roteamento:** A configuração da tabela de rotas do IGW é essencial para permitir que o Load Balancer roteie o tráfego corretamente entre as sub-redes e a internet.

#  Criação de um EC2 Instance Connect Endpoint

Aqui descreve os passos necessários para criar e configurar um EC2 Instance Connect Endpoint na AWS, permitindo acesso seguro a instâncias EC2.

## Passo 1: Criação do EC2 Instance Connect Endpoint

1. Acesse o console da AWS e vá para **VPC** > **Endpoints**.
2. Clique em **Criar endpoint** e selecione **EC2 Instance Connect Endpoint**.
3. Configure as seguintes opções:
   - **Nome do endpoint:** `wp-endpoint`
   - **ID da VPC:** Escolha a VPC criada
   - **Sub-rede:** Escolha uma VPC Publica criada
   - **Tipo de endpoint:** `EC2 Instance Connect Endpoint`

## Passo 2: Configuração do Grupo de Segurança

### 2.1 Configuração do Grupo de Segurança Associado

- **Grupo de Segurança:** Escolha o grupo de segurança criado pro Endpoint

## Passo 3: Verificação de Configuração

1. Após a criação do endpoint e configuração do grupo de segurança, verifique se o status do endpoint está **Disponível**.
2. Use o nome DNS do endpoint para se conectar à instância EC2 utilizando o EC2 Instance Connect.

### Conectando à Instância EC2

- Use o console EC2 Instance Connect ou um cliente SSH para acessar a instância EC2 utilizando o endpoint configurado.
- Certifique-se de que as permissões no grupo de segurança permitem conexões SSH.

## Observações

- **Segurança:** A configuração de acesso SSH deve ser restrita ao mínimo necessário, permitindo apenas endereços IP confiáveis para evitar tentativas de acesso não autorizado.
- **Disponibilidade:** Garantir que o endpoint esteja configurado em uma sub-rede que possua conectividade adequada para acessar suas instâncias EC2.










