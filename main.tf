terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "airflow_dag_execution_failure" {
  source    = "./modules/airflow_dag_execution_failure"

  providers = {
    shoreline = shoreline
  }
}