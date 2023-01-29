locals {
  common_env = [
    {
      name  = "PUID"
      value = 1000
    },
    {
      name  = "PGID"
      value = 1000
    },
    {
      name  = "TZ"
      value = "America/Toronto"
    }
  ]
}
