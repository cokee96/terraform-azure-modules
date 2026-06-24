locals {
  location = "westeurope"
  prefix   = "webapp-example"

  tags = {
    environment = "example"
    managed_by  = "terraform"
    project     = "web-app"
  }
}
