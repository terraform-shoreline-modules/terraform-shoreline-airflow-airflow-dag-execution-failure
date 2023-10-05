resource "shoreline_notebook" "airflow_dag_execution_failure" {
  name       = "airflow_dag_execution_failure"
  data       = file("${path.module}/data/airflow_dag_execution_failure.json")
  depends_on = [shoreline_action.invoke_airflow_dags_list_show,shoreline_action.invoke_airflow_journalctl,shoreline_action.invoke_airflow_dag_check,shoreline_action.invoke_restart_airflow_dag]
}

resource "shoreline_file" "airflow_dags_list_show" {
  name             = "airflow_dags_list_show"
  input_file       = "${path.module}/data/airflow_dags_list_show.sh"
  md5              = filemd5("${path.module}/data/airflow_dags_list_show.sh")
  description      = "3. Check the DAGs folder for any syntax errors:"
  destination_path = "/agent/scripts/airflow_dags_list_show.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "airflow_journalctl" {
  name             = "airflow_journalctl"
  input_file       = "${path.module}/data/airflow_journalctl.sh"
  md5              = filemd5("${path.module}/data/airflow_journalctl.sh")
  description      = "8. Check the system logs for any relevant errors or warnings:"
  destination_path = "/agent/scripts/airflow_journalctl.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "airflow_dag_check" {
  name             = "airflow_dag_check"
  input_file       = "${path.module}/data/airflow_dag_check.sh"
  md5              = filemd5("${path.module}/data/airflow_dag_check.sh")
  description      = "Configuration errors in the Apache Airflow DAG (Directed Acyclic Graph) file."
  destination_path = "/agent/scripts/airflow_dag_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restart_airflow_dag" {
  name             = "restart_airflow_dag"
  input_file       = "${path.module}/data/restart_airflow_dag.sh"
  md5              = filemd5("${path.module}/data/restart_airflow_dag.sh")
  description      = "Ensure that all dependencies for the DAG are installed and updated. This includes any packages, libraries, or plugins used in the DAG."
  destination_path = "/agent/scripts/restart_airflow_dag.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_airflow_dags_list_show" {
  name        = "invoke_airflow_dags_list_show"
  description = "3. Check the DAGs folder for any syntax errors:"
  command     = "`chmod +x /agent/scripts/airflow_dags_list_show.sh && /agent/scripts/airflow_dags_list_show.sh`"
  params      = ["DAG_ID"]
  file_deps   = ["airflow_dags_list_show"]
  enabled     = true
  depends_on  = [shoreline_file.airflow_dags_list_show]
}

resource "shoreline_action" "invoke_airflow_journalctl" {
  name        = "invoke_airflow_journalctl"
  description = "8. Check the system logs for any relevant errors or warnings:"
  command     = "`chmod +x /agent/scripts/airflow_journalctl.sh && /agent/scripts/airflow_journalctl.sh`"
  params      = []
  file_deps   = ["airflow_journalctl"]
  enabled     = true
  depends_on  = [shoreline_file.airflow_journalctl]
}

resource "shoreline_action" "invoke_airflow_dag_check" {
  name        = "invoke_airflow_dag_check"
  description = "Configuration errors in the Apache Airflow DAG (Directed Acyclic Graph) file."
  command     = "`chmod +x /agent/scripts/airflow_dag_check.sh && /agent/scripts/airflow_dag_check.sh`"
  params      = ["EXECUTION_DATE","DAG_FILE_PATH","TASK_ID","DAG_ID"]
  file_deps   = ["airflow_dag_check"]
  enabled     = true
  depends_on  = [shoreline_file.airflow_dag_check]
}

resource "shoreline_action" "invoke_restart_airflow_dag" {
  name        = "invoke_restart_airflow_dag"
  description = "Ensure that all dependencies for the DAG are installed and updated. This includes any packages, libraries, or plugins used in the DAG."
  command     = "`chmod +x /agent/scripts/restart_airflow_dag.sh && /agent/scripts/restart_airflow_dag.sh`"
  params      = ["NAME_OF_THE_DAG","PATH_TO_DEPENDENCIES_FILE","PATH_TO_VIRTUALENV"]
  file_deps   = ["restart_airflow_dag"]
  enabled     = true
  depends_on  = [shoreline_file.restart_airflow_dag]
}

