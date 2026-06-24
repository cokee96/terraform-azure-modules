# Pipelines CI/CD

Este directorio cubre tres tipos de despliegue, cada uno disponible para
GitHub Actions, Azure DevOps y Jenkins:

| Tipo | Cuándo usarlo |
|---|---|
| **Terraform (Azure)** | Provisionar infraestructura Azure via Terraform |
| **Kubernetes (AKS)** | Desplegar contenedores en Azure Kubernetes Service |
| **Kubernetes (On-Premise)** | Desplegar en un cluster k8s propio (kubeconfig) |
| **Ansible (On-Premise)** | Desplegar en servidores Linux con Docker vía Ansible/SSH |

Todos siguen el mismo principio:

```
build/plan (visible) → aprobación manual → deploy/apply
```

Nadie ejecuta cambios sin haber visto antes qué va a cambiar.

---

## Ficheros

| Pipeline | GitHub Actions | Azure DevOps | Jenkins |
|---|---|---|---|
| Terraform (Azure) | `.github/workflows/terraform-deploy.yml` | `pipelines/azure-devops/azure-pipelines.yml` | `pipelines/jenkins/Jenkinsfile` |
| Kubernetes (AKS) | `.github/workflows/k8s-deploy.yml` | `pipelines/azure-devops/k8s-deploy.yml` | `pipelines/jenkins/Jenkinsfile-k8s` |
| Kubernetes (On-Prem) | `.github/workflows/k8s-onpremise.yml` | `pipelines/azure-devops/k8s-onpremise.yml` | `pipelines/jenkins/Jenkinsfile-k8s-onpremise` |
| Ansible (On-Prem) | `.github/workflows/ansible-deploy.yml` | `pipelines/azure-devops/ansible-deploy.yml` | `pipelines/jenkins/Jenkinsfile-ansible` |

---

## Tabla comparativa (Terraform)

| Característica | GitHub Actions | Azure DevOps | Jenkins |
|---|---|---|---|
| Fichero | `.github/workflows/terraform-deploy.yml` | `pipelines/azure-devops/azure-pipelines.yml` | `pipelines/jenkins/Jenkinsfile` |
| Autenticación Azure | OIDC (sin secretos de larga duración) | Service Connection | Service Principal vía Credentials |
| Aprobación manual | GitHub Environments (Required reviewers) | Azure DevOps Environments (Approvals) | `input` step con timeout |
| Plan visible antes de aprobar | Sí — logs del job `plan` + artefacto | Sí — logs del stage `Plan` + artefacto | Sí — `input` muestra el resumen del plan |
| Comentario en PR | Sí — diff del plan en el PR | No (añadible con extensión) | No |
| Destroy | Job separado con aprobación | Stage separado con aprobación | `ACTION=destroy` con aprobación |

---

## GitHub Actions

### Prerrequisitos

1. **Storage Account para el estado remoto** (una sola vez):
   ```bash
   az group create -n rg-terraform-state -l westeurope
   az storage account create -n stterraformstate -g rg-terraform-state --sku Standard_LRS
   az storage container create -n tfstate --account-name stterraformstate
   ```

2. **Service Principal con OIDC** (sin secretos que rotan):
   ```bash
   APP_ID=$(az ad app create --display-name "sp-terraform-github" --query appId -o tsv)
   az ad sp create --id $APP_ID

   # Federated credential — solo los runs de este repo pueden usar este SP
   az ad app federated-credential create --id $APP_ID --parameters '{
     "name": "github-actions",
     "issuer": "https://token.actions.githubusercontent.com",
     "subject": "repo:TU_ORG/terraform-azure-modules:environment:prod",
     "audiences": ["api://AzureADTokenExchange"]
   }'

   az role assignment create \
     --assignee $APP_ID \
     --role Contributor \
     --scope /subscriptions/TU_SUBSCRIPTION_ID
   ```

3. **Secrets en GitHub** (Settings → Secrets → Actions):
   | Secret | Valor |
   |---|---|
   | `AZURE_CLIENT_ID` | App ID del SP |
   | `AZURE_TENANT_ID` | Tenant ID |
   | `AZURE_SUBSCRIPTION_ID` | Subscription ID |
   | `SQL_ADMIN_PASSWORD` | Contraseña del SQL Server |

4. **Variables en GitHub** (Settings → Variables → Actions):
   | Variable | Valor |
   |---|---|
   | `TF_BACKEND_RG` | `rg-terraform-state` |
   | `TF_BACKEND_SA` | `stterraformstate` |

5. **Environments con aprobadores** (Settings → Environments):
   - Crea los environments `dev`, `pre`, `prod`
   - En `pre` y `prod`: añade **Required reviewers**
   - El revisor verá el botón de aprobación **después** de leer los logs del job `plan`

### Uso

```
Actions → Terraform Deploy → Run workflow
  └── environment: prod
  └── action: apply
```

El flujo es:
1. Job `plan` se ejecuta — el plan queda en los logs y como artefacto ZIP
2. Job `apply` espera aprobación del revisor configurado en el Environment
3. El revisor abre los logs del job `plan`, lee el plan, y aprueba o rechaza
4. Si aprueba: `terraform apply` se ejecuta con el plan guardado

---

## Azure DevOps

### Prerrequisitos

1. **Service Connection** hacia Azure:
   Project Settings → Service connections → New → Azure Resource Manager
   → Service Principal (automatic) → Nombre: `azure-service-connection`

2. **Variable Groups** (Pipelines → Library):

   `terraform-global`:
   | Variable | Valor |
   |---|---|
   | `TF_BACKEND_RG` | `rg-terraform-state` |
   | `TF_BACKEND_SA` | `stterraformstate` |

   `terraform-dev`, `terraform-pre`, `terraform-prod`:
   | Variable | Valor |
   |---|---|
   | `SQL_ADMIN_PASSWORD` | *(marcar como secreto)* |

3. **Environments con aprobadores** (Pipelines → Environments):
   - Crea `dev`, `pre`, `prod`
   - En `pre` y `prod`: Approvals and checks → Approvals → añade aprobadores

4. **Crear el pipeline**:
   Pipelines → New pipeline → Azure Repos Git → selecciona el repo
   → Existing Azure Pipelines YAML file → `pipelines/azure-devops/azure-pipelines.yml`

### Uso

Ejecuta el pipeline manualmente con los parámetros:
- **environment**: dev / pre / prod
- **action**: plan / apply / destroy

El flujo es idéntico al de GitHub Actions:
1. Stage `Plan` — el plan queda en los logs y como artefacto publicado
2. Stage `Apply` espera al aprobador configurado en el Environment de Azure DevOps
3. El aprobador lee los logs del stage anterior y acepta o rechaza

---

## Jenkins

### Prerrequisitos

1. **Plugins necesarios**:
   - Pipeline
   - AnsiColor
   - Credentials Binding
   - Timestamper

2. **Credenciales** (Manage Jenkins → Credentials → Global):
   | ID | Tipo | Valor |
   |---|---|---|
   | `AZURE_CLIENT_ID` | Secret text | App ID del SP |
   | `AZURE_CLIENT_SECRET` | Secret text | Secreto del SP |
   | `AZURE_TENANT_ID` | Secret text | Tenant ID |
   | `AZURE_SUBSCRIPTION_ID` | Secret text | Subscription ID |
   | `SQL_ADMIN_PASSWORD` | Secret text | Contraseña SQL |
   | `TF_BACKEND_RG` | Secret text | `rg-terraform-state` |
   | `TF_BACKEND_SA` | Secret text | `stterraformstate` |

3. **Terraform en el agente**:
   ```bash
   # En el agente Jenkins (Ubuntu)
   wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip
   unzip /tmp/terraform.zip -d /usr/local/bin/
   ```

4. **Crear el pipeline**:
   New Item → Pipeline → Pipeline script from SCM
   → Script Path: `pipelines/jenkins/Jenkinsfile`

### Uso

Build with Parameters:
- **ENVIRONMENT**: dev / pre / prod
- **ACTION**: plan / apply / destroy

El flujo:
1. Stage `Plan` — ejecuta el plan y muestra un resumen en los logs
2. Stage `Approval` — muestra las últimas líneas del plan y abre un diálogo:
   ```
   ¿Deseas continuar con el apply en prod?
   [Sí, ejecutar apply en prod]  [Abort]
   ```
3. Timeout de 30 minutos — si nadie responde, el pipeline falla
4. En `prod` solo pueden aprobar los usuarios del grupo `admin,team-leads`

---

## Kubernetes On-Premise

Usa los mismos pipelines (`k8s-onpremise.*`) pero sin dependencia de Azure.
La autenticación es un **kubeconfig guardado como secreto** (base64-encoded).

### Generar el secreto de kubeconfig

```bash
# En tu máquina local, con acceso al cluster:
base64 -w0 ~/.kube/config
# Pega el resultado en:
#   GitHub  → Settings → Secrets → KUBECONFIG_DEV / _PRE / _PROD
#   AzDevOps → Library → Variable Group → KUBECONFIG_B64 (marcar como secreto)
#   Jenkins  → Credentials → Secret file → KUBECONFIG_DEV / _PRE / _PROD
```

### Variables necesarias

| Variable | Valor |
|---|---|
| `REGISTRY_HOST` | Hostname del registry on-prem (e.g. `harbor.company.com`) |
| `REGISTRY_USER` | Usuario del registry |
| `REGISTRY_PASSWORD` | Contraseña del registry |
| `APP_NAME` | Nombre de la aplicación |
| `KUBECONFIG_DEV/PRE/PROD` | kubeconfig en base64 por entorno |

---

## Ansible On-Premise

Para servidores Linux que corren Docker directamente (sin Kubernetes).
El pipeline construye la imagen, la sube al registry, y usa Ansible para
conectarse por SSH y reiniciar el contenedor.

### Estructura Ansible esperada

```
ansible/
  inventories/
    dev/hosts.ini      ← IPs/hostnames de los servidores de dev
    pre/hosts.ini
    prod/hosts.ini
  playbooks/
    deploy.yml         ← playbook incluido en este repo como ejemplo
```

### Variables necesarias

| Variable | Valor |
|---|---|
| `REGISTRY_HOST` | Hostname del registry |
| `REGISTRY_USER` | Usuario del registry |
| `REGISTRY_PASSWORD` | Contraseña del registry |
| `APP_NAME` | Nombre de la aplicación |
| `SSH_PRIVATE_KEY` | Clave privada SSH del usuario de deploy |

### Flujo del pipeline Ansible

1. **Build** — construye y sube la imagen al registry
2. **Plan** — ejecuta `ansible-playbook --check --diff` (dry-run sin cambios reales)
3. **Approval** — muestra el diff del dry-run, espera confirmación
4. **Deploy** — ejecuta el playbook real (`--diff`)

El playbook incluido (`ansible/playbooks/deploy.yml`):
- Verifica que Docker está instalado y corriendo
- Hace `docker pull` de la nueva imagen
- Para el contenedor antiguo (graceful, 30 s timeout)
- Arranca el nuevo contenedor
- Espera el health check en `/healthz` (configurable)

---

## Recomendaciones de seguridad

- **Nunca** guardes `*.tfvars` con contraseñas en el repositorio
- Usa siempre OIDC / federated credentials en lugar de secretos de larga duración
- El estado de Terraform contiene valores sensibles — asegúrate de que el Storage Account tiene acceso restringido y cifrado en reposo activado
- Revisa el plan completo antes de aprobar: presta especial atención a las líneas con `# will be destroyed` y `# must be replaced`
- Para Kubernetes on-prem: usa un kubeconfig de Service Account con permisos mínimos (solo `get/list/watch/update` en Deployments del namespace concreto), no el kubeconfig de admin del cluster
- Para Ansible: crea un usuario `deploy` sin contraseña en los servidores, autoriza solo su clave pública, y no lo añadas al grupo `sudo` — usa `become` con contraseña distinta si necesitas permisos de root
