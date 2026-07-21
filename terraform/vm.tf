# vm.tf

resource "google_compute_instance" "mongo_vm" {
  name         = "wiz-mongo-vm"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["mongo-vm"]

  # Intentional Misconfiguration: Hardcoded Outdated OS satisfying the 1+ year requirement
  boot_disk {
    initialize_params {
      # Hardcoded GCP image reference
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20260713"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vm_subnet.id
    access_config {
      # Ephemeral Public IP for global SSH access
    }
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    exec > /var/log/startup.log 2>&1

    # 1. Install libssl1.1 (required for legacy MongoDB 4.4 on Ubuntu 22.04+)
    apt-get update -y
    apt-get install -y gnupg wget
    wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
    dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y

    # 2. Install Outdated MongoDB 4.4
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
    apt-get update -y
    apt-get install -y mongodb-org=4.4.18 mongodb-org-server=4.4.18 mongodb-org-shell=4.4.18 mongodb-org-mongos=4.4.18 mongodb-org-tools=4.4.18

    # 3. Bind MongoDB to 0.0.0.0
    sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
    systemctl restart mongod
    systemctl enable mongod

    # 4. Enable Mongo Database Authentication
    sleep 5
    mongo admin --eval 'db.createUser({user: "admin", pwd: "WizPassword123!", roles: [{role: "userAdminAnyDatabase", db: "admin"}]})'
    mongo todo_db --eval 'db.createUser({user: "todo_user", pwd: "TodoPassword123!", roles: [{role: "readWrite", db: "todo_db"}]})'

    # 5. Create Automated Database Backup Script
    cat << 'SCRIPT' > /usr/local/bin/backup.sh
    #!/bin/bash
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="/tmp/mongodump_$TIMESTAMP"
    
    # Run mongodump
    mongodump --username todo_user --password TodoPassword123! --authenticationDatabase todo_db --db todo_db --out $BACKUP_DIR
    tar -czf "$BACKUP_DIR.tar.gz" -C $BACKUP_DIR .
    
    # Push archive to public GCS bucket
    gcloud storage cp "$BACKUP_DIR.tar.gz" "gs://${google_storage_bucket.backup_bucket.name}/backup_$TIMESTAMP.tar.gz"
    rm -rf $BACKUP_DIR "$BACKUP_DIR.tar.gz"
    SCRIPT

    chmod +x /usr/local/bin/backup.sh

    # Trigger immediate execution and configure daily cron task
    /usr/local/bin/backup.sh
    (crontab -l 2>/devnull; echo "0 0 * * * /usr/local/bin/backup.sh") | crontab -
  EOF
}
