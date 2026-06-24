locals {
  # Prefijo base usado en todos los nombres: {project}-{environment}
  prefix = "${var.project}-${var.environment}"

  # Tags aplicados a todos los recursos
  tags = merge(
    {
      project     = var.project
      environment = var.environment
      managed_by  = "terraform"
    },
    var.extra_tags
  )

  # Nombres de recursos — derivados automáticamente del prefijo
  # Algunos servicios de Azure tienen restricciones en el nombre (sin guiones, longitud máxima).
  names = {
    resource_group = "rg-${local.prefix}"
    vnet           = "vnet-${local.prefix}"
    nsg_aks        = "nsg-aks-${local.prefix}"
    aks            = "aks-${local.prefix}"

    # ACR y Storage solo admiten caracteres alfanuméricos
    acr     = "acr${replace(local.prefix, "-", "")}"
    storage = "st${replace(local.prefix, "-", "")}"

    # Key Vault: máx 24 caracteres
    keyvault = "kv-${local.prefix}"

    sql_server    = "sql-${local.prefix}"
    sql_database  = "db-${local.prefix}"
    redis         = "redis-${local.prefix}"
    app_service   = "app-${local.prefix}"
    servicebus    = "sb-${local.prefix}"
    cosmosdb      = "cosmos-${local.prefix}"
    log_workspace = "log-${local.prefix}"
    app_insights  = "appi-${local.prefix}"

    # Private Endpoints
    pe_keyvault   = "pe-kv-${local.prefix}"
    pe_sql        = "pe-sql-${local.prefix}"
    pe_redis      = "pe-redis-${local.prefix}"
    pe_storage    = "pe-st-${local.prefix}"
    pe_acr        = "pe-acr-${local.prefix}"
    pe_servicebus = "pe-sb-${local.prefix}"
    pe_cosmosdb   = "pe-cosmos-${local.prefix}"
  }
}
