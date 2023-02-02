variable "gcp_auth_key" {
  type     = string
}

provider "google" {
    credentials = file("hybridcloudpoc-sa-terraform.json")
    project     = "hybridcloudpoc"
    region      = "asia-east1"
}

resource "google_cloud_run_v2_service" "tf-created" {
  name     = "tf-created"
  location = "asia-east1"
  ingress = "INGRESS_TRAFFIC_ALL"

  binary_authorization {
    use_default = true
  #  breakglass_justification = "Some justification"
  }

  template {
    containers {
      image = "asia-east1-docker.pkg.dev/hybridcloudpoc/cloud-run-source-deploy/helloworld"
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.tf-created.location
  project     = google_cloud_run_v2_service.tf-created.project
  name        = google_cloud_run_v2_service.tf-created.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
