# Azure Database Services
# Uncomment dan sesuaikan sesuai kebutuhan

# # Azure SQL Database
# resource "azurerm_mssql_server" "main" {
#   name                         = "${local.name_prefix}-sqlserver"
#   resource_group_name          = azurerm_resource_group.main.name
#   location                     = azurerm_resource_group.main.location
#   version                      = "12.0"
#   administrator_login          = "sqladmin"
#   administrator_login_password = random_password.sql_password.result
# 
#   tags = var.tags
# }
# 
# resource "azurerm_mssql_database" "main" {
#   name           = "${local.name_prefix}-database"
#   server_id      = azurerm_mssql_server.main.id
#   collation      = "SQL_Latin1_General_CP1_CI_AS"
#   license_type   = "LicenseIncluded"
#   max_size_gb    = 2
#   sku_name       = "Basic"
# 
#   tags = var.tags
# }
# 
# # Azure PostgreSQL Database
# resource "azurerm_postgresql_server" "main" {
#   name                = "${local.name_prefix}-postgresql"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
# 
#   administrator_login          = "psqladmin"
#   administrator_login_password = random_password.postgres_password.result
# 
#   sku_name   = "B_Gen5_1"
#   version    = "11"
#   storage_mb = 5120
# 
#   backup_retention_days        = 7
#   geo_redundant_backup_enabled = false
#   auto_grow_enabled           = true
# 
#   tags = var.tags
# }
# 
# # Random passwords
# resource "random_password" "sql_password" {
#   length  = 16
#   special = true
# }
# 
# resource "random_password" "postgres_password" {
#   length  = 16
#   special = true
# }
# 
# output "sql_server_name" {
#   description = "Name of the SQL Server"
#   value       = azurerm_mssql_server.main.name
# }
# 
# output "postgresql_server_name" {
#   description = "Name of the PostgreSQL Server"
#   value       = azurerm_postgresql_server.main.name
# } 