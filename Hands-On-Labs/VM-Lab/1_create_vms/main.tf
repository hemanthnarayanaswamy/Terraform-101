resource "google_compute_instance" "vms" {
  count        = 2
  name         = "vm-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = 15
      type  = var.disk_type
    }
  }

  network_interface {
    network = "default"
    access_config {} # Public IP
  }

  tags = ["tf-vm"]
}
