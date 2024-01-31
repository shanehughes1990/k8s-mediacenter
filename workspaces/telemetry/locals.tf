locals {
  keel_annotations = {
    "keel.sh/policy"       = "force"
    "keel.sh/pollSchedule" = "@every 10m"
    "keel.sh/trigger"      = "poll"
  }
}
