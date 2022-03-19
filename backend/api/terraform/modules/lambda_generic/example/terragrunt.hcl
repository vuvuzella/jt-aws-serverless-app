include "root" {
  path = find_in_parent_folders()
}

inputs = {
  app_artifact = "../../../../artifacts/app.zip"
  app_dep_artifact = "../../../../artifacts/dependencies.zip"
}
