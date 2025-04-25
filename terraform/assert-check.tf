data "external" "data_os-project-id" {
  program = ["${path.module}/assert-vars.sh"]
}

data "external" "check_os-project-id" {
  program = ["${path.module}/assert-check.sh", data.external.data_os-project-id.result.project_id]
}
