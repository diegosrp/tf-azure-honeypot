# Azure T-Pot Honeypot VM

Terraform configuration for an Azure Linux VM running T-Pot Community Edition.

The deployment creates a public Ubuntu VM, opens honeypot traffic on ports `1-64000`, restricts T-Pot administrative ports to your detected public IP, then uses cloud-init to clone `telekom-security/tpotce`, run the unattended hive installer, and reboot the VM. T-Pot exposes its WebUI at `https://<public-ip>:64297` after installation finishes.

## Usage

1. Deploy:

   ```bash
   terraform init
   terraform validate
   terraform apply
   ```

2. Use the outputs:

   ```bash
   terraform output public_ip_address
   terraform output tpot_web_url
   terraform output ssh_command
   ```

3. Get WebUI credentials when needed:

   ```bash
   terraform output tpot_web_username
   terraform output tpot_web_password
   ```

4. Save the generated private SSH key locally only if you need SSH access:

   ```bash
   terraform output -raw ssh_private_key_pem > tpot_ssh_key.pem
   chmod 600 tpot_ssh_key.pem
   ```

## Notes

- Bootstrap runs apt update, unattended apt upgrade and Git installation, clones T-Pot, and runs `./install.sh -s -t h -u azhoneypot -p <generated-password>` as the non-root administrator with the correct HOME. These flags replace interactive confirmations and password repetition.
- The default WebUI user is `azhoneypot`. The password is randomly generated, never hardcoded, and available only through the sensitive output.
- Terraform apply creates the VM but does not wait for cloud-init or portal readiness. Installation and image downloads continue until cloud-init reboots the VM after successful Compose validation and image pulls.
- On installation failure the success marker is not created and the automatic reboot is skipped. Review `/var/log/tpot-install.log` and cloud-init status on the VM.
- Changing VM custom data can replace the VM and its OS disk. Review the plan before applying to an existing deployment.
- The portal uses a self-signed certificate; browsers may show a certificate warning.
- SSH password authentication is disabled. Terraform generates an ED25519 key and creates an Azure SSH Public Key resource for the VM.
- T-Pot moves SSH to port `64295` during installation.
- The NSG allows honeypot traffic on ports `1-64000` from any source, but restricts administrative ports `64294`, `64295`, and `64297` to your detected public IP by default.
- You can override admin access with `management_source_address_prefixes` when running Terraform from a network different from the browser or SSH client network.
- The WebUI password is sensitive, but the rendered cloud-init custom data is stored in Terraform state.
- The generated SSH private key is sensitive and is also stored in Terraform state.