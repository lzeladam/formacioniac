data "azuread_user" "aad" {
  mail_nickname = "alexander.zelada_outlook.com#EXT#"
}

resource "azuread_group" "k8sadmins" {
  display_name = "Kubernetes Admins"
  members = [
    data.azuread_user.aad.object_id,
  ]
  security_enabled = true
}