# Better Together — Ansible Automation Platform + Terraform Enterprise

Demo de integração entre **Red Hat Ansible Automation Platform (AAP)** e **HashiCorp Terraform Enterprise (TFE)**, demonstrando a estratégia *Better Together*: Terraform provisiona (Day 0/1), Ansible configura, gerencia e orquestra todo o ciclo de vida (Day 1/2), com atualização de ITSM (ServiceNow).

## Arquitetura da demo

### Workflow 1 — Provisionamento (Day 1)

```
AAP Workflow
 ├── 1. Provisionar IaC com Terraform (run no TFE disparado pelo AAP)
 ├── 2. Sincronizar Inventário Dinâmico (state do Terraform → inventário AAP)
 ├── 3. Configurar / Aplicação / Compliance (Ansible nos novos hosts)
 ├── 4. Orquestrar infraestrutura de apoio (atualizar Load Balancer)
 └── 5. Atualizar ITSM (ServiceNow) com o novo workload
```

### Workflow 2 — Descomissionamento (Day 2)

```
AAP Workflow
 ├── 1. Remover hosts do Load Balancer
 ├── 2. Snapshot dos volumes (política de arquivamento)
 ├── 3. Terraform Destroy (run destroy no TFE disparado pelo AAP)
 ├── 4. Sincronizar Inventário Dinâmico
 └── 5. Atualizar ITSM/CMDB com o descomissionamento
```

## Estrutura do repositório

| Diretório | Conteúdo |
|---|---|
| `terraform/aws-webapp/` | Código Terraform do workload (VPC, SG, EC2) — usado pelo workspace no TFE |
| `inventories/` | Inventário dinâmico via plugin `cloud.terraform.terraform_state` |
| `playbooks/` | Playbooks numerados na ordem dos workflows |
| `roles/` | Roles de apoio (`tfe_run`, webserver, etc.) |
| `collections/requirements.yml` | Collections necessárias no Execution Environment |
| `controller_config/` | Configuration-as-Code do AAP (projetos, credenciais, JTs, workflows) |
| `docs/` | Roteiro da demo e diagramas |

## Pré-requisitos

- AAP 2.5+ com Execution Environment contendo as collections de `collections/requirements.yml`
- Terraform Enterprise com organização e workspace criados (modo API-driven ou VCS-driven apontando para `terraform/aws-webapp/`)
- Credenciais no AAP:
  - `TFE API Token` (custom credential type — ver `controller_config/credential_types.yml`)
  - `AWS` (para snapshots/queries diretas)
  - `ServiceNow` (opcional — passos de ITSM são tolerantes a falha na demo)
  - `Machine` (SSH para as instâncias EC2 provisionadas)

## Variáveis principais

Definidas em nível de Job Template / Survey (ver `controller_config/job_templates.yml`):

| Variável | Descrição | Exemplo |
|---|---|---|
| `tfe_hostname` | Host do Terraform Enterprise | `tfe.example.com` |
| `tfe_organization` | Organização no TFE | `redhat-demo` |
| `tfe_workspace` | Workspace do workload | `aws-webapp-demo` |
| `app_version` | Versão/conteúdo da aplicação a publicar | `v1.0` |
| `snow_instance` | Instância do ServiceNow | `devXXXX.service-now.com` |

## Como executar (resumo)

1. Aplique a configuração do AAP: `controller_config/` (collection `infra.aap_configuration`).
2. Execute o workflow **`BT - 01 Provision Web App`**.
3. Mostre o run no TFE, o inventário sincronizado e a aplicação no browser.
4. Execute **`BT - 02 Update Application`** para demonstrar Day 2 (atualização da app).
5. Execute **`BT - 99 Decommission`** para encerrar com o ciclo completo.

Roteiro detalhado da demo em [`docs/demo-guide.md`](docs/demo-guide.md).
