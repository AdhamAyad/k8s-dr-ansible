# Kubernetes Disaster Recovery - Automated Ansible & Terraform Solution

## Overview
This project provides a comprehensive Disaster Recovery (DR) and Backup framework for self-managed Kubernetes clusters. It leverages Terraform for AWS infrastructure management (S3 and OIDC), Ansible for cluster-level backup/restore operations, and GitHub Actions for CI/CD pipeline automation.

## Project Structure
The repository is organized into four main functional areas:
- **ansible/**: Contains roles for ETCD snapshots, PKI certificate backups, Static Pod manifests, and K8s configurations.
- **terraform/**: Manages S3 buckets for state and backups, and configures GitHub OIDC authentication.
- **kubernetes/**: Defines CronJobs for scheduled on-cluster backup tasks.
- **cicd**: GitHub Actions workflows for automated recovery triggered by S3 events or manual dispatch.

## Prerequisites
- AWS CLI configured with appropriate permissions.
- Terraform v1.7+ and Ansible v2.15+.
- A running Kubernetes cluster (Master and Worker nodes).
- SSH access to all cluster nodes from the Ansible controller.

## 1. Infrastructure Provisioning (Terraform)
The infrastructure layer creates the necessary S3 buckets and IAM roles with OIDC provider for secure GitHub Actions integration.

```bash
cd terraform
terraform init
terraform apply -var="github_repo=AdhamAyad/k8s-dr-ansible"
```
**Key Components:**
- **S3 Buckets**: Managed in `s3.tf` for Terraform state and DR archives.
- **OIDC Module**: Managed in `modules/github-oidc` to eliminate the need for long-lived AWS Access Keys.

## 2. Backup Strategy (Ansible & K8s)
The project supports both manual and scheduled backups.

### Automated Backups
Scheduled backups are handled by Kubernetes CronJobs located in the `kubernetes/` directory, which sync data directly to S3.
```bash
kubectl apply -f kubernetes/pvc.yaml
kubectl apply -f kubernetes/cronJob-s3.yaml
```

### Manual Backup
Run the backup playbook to capture the current state of the control plane:
```bash
ansible-playbook -i ansible/inventory ansible/backup-cluster.yaml
```
**Captured Data:**
- ETCD Snapshot (encrypted).
- `/etc/kubernetes/pki` directory.
- `/etc/kubernetes/manifests` (Static Pods).
- Core configuration files (`kubelet.conf`, etc.).

## 3. Disaster Recovery Process (Restore)
The restore process is designed to handle total control plane failure.

### Execution via GitHub Actions
1. Navigate to GitHub Actions -> Restore Cluster.
2. Select 'Run workflow'.
3. Input the `backup_folder_name` (e.g., `backup_2026-03-22_04-18`).

### Manual Restore logic
The restore playbook performs the following critical steps:
1. **Download**: Fetches the specified backup from S3.
2. **ETCD Restore**: Stops the API server and restores the ETCD data directory.
3. **PKI/Configs**: Restores certificates and control plane configurations.
4. **Manifest Bouncing**: A critical post-restore step that moves static pod manifests out of `/etc/kubernetes/manifests` and back in. This forces the Kubelet to re-register Mirror Pods with the API server, solving potential synchronization conflicts after an ETCD state change.

```bash
ansible-playbook -i ansible/inventory ansible/restore-cluster.yaml -e "backup_folder_name=YOUR_BACKUP_NAME"
```

## 4. Verification
After the restoration completes, verify the cluster health:
```bash
kubectl get nodes
kubectl get pods -A
```
Ensure all control plane components (etcd, api-server, scheduler) are running and the Node status is 'Ready'.

## Security Considerations
- **OIDC Authentication**: GitHub Actions assumes an IAM Role via Web Identity, adhering to the principle of least privilege.
- **State Locking**: Terraform state is stored in a dedicated S3 bucket to prevent concurrent infrastructure changes.
- **Data Integrity**: Backups are archived and timestamped to prevent accidental overwrites.
