# Managed by Terraform. Any manual edits in the Tailscale admin console will be reverted.
resource "tailscale_acl" "policy" {
  acl = jsonencode({
    grants = [
      {
        src = ["*"]
        dst = ["*"]
        ip  = ["*"]
      }
    ]

    ssh = [
      {
        action = "check"
        src    = ["autogroup:member"]
        dst    = ["autogroup:self"]
        users  = ["autogroup:nonroot", "root"]
      }
    ]

    tagOwners = {
      "tag:server"    = ["autogroup:admin"]
      "tag:container" = ["tag:server"]
    }

    autoApprovers = {
      services = {
        "tag:container" = ["tag:server"]
      }
    }
  })
}
