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

  keel_annotations = {
    "keel.sh/policy"       = "force"
    "keel.sh/pollSchedule" = "@every 10m"
    "keel.sh/trigger"      = "poll"
  }
}
