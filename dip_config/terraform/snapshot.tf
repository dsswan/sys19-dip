resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"

  schedule_policy {
    expression = "0 15 ? * *"
  }

  retention_period = "24h"
  snapshot_count = 7

  snapshot_spec {
    description = "daily-snapshot"
  }

  disk_ids = ["${yandex_compute_instance.bastion.boot_disk.0.disk_id}",
    "${yandex_compute_instance.web1.boot_disk.0.disk_id}",
    "${yandex_compute_instance.web2.boot_disk.0.disk_id}",
    "${yandex_compute_instance.zabbix.boot_disk.0.disk_id}",
    "${yandex_compute_instance.elastic.boot_disk.0.disk_id}",
    "${yandex_compute_instance.kibana.boot_disk.0.disk_id}"]
}