locals {
  location = "westeurope"
  prefix   = "microservices-example"

  tags = {
    environment = "example"
    managed_by  = "terraform"
    project     = "microservices"
  }
}
