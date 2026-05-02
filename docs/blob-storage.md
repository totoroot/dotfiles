# Blob Storage Setup

This document describes how to set up and manage the blob storage service at `blob.thym.it`.

## NGINX Configuration

The blob storage is served via NGINX with the following configuration:

- Domain: `blob.thym.it`
- Root directory: `/var/www/blob.thym.it`
- HTTPS enabled via Let's Encrypt
- Serves static files directly

## Setup Instructions

### 1. Create the Directory Structure

On the server (jam), create the directory structure:

```bash
sudo mkdir -p /var/www/blob.thym.it/stt-models
sudo chown -R nginx:nginx /var/www/blob.thym.it
sudo chmod -R 755 /var/www/blob.thym.it
```

### 2. Deploy the Model File

To deploy the parakeet-v3-int8.tar.gz model:

```bash
# Download the model (example from Jam)
curl -L https://blob.handy.computer/parakeet-v3-int8.tar.gz -o /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz

# Set proper permissions
sudo chown nginx:nginx /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz
sudo chmod 644 /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz
```

### 3. Verify Access

After deployment, the model should be accessible at:
https://blob.thym.it/stt-models/parakeet-v3-int8.tar.gz

### 4. Add More Models

To add additional models, simply place them in the appropriate subdirectory and ensure proper permissions:

```bash
# Example: Add another model
sudo cp /path/to/model.tar.gz /var/www/blob.thym.it/stt-models/
sudo chown nginx:nginx /var/www/blob.thym.it/stt-models/model.tar.gz
sudo chmod 644 /var/www/blob.thym.it/stt-models/model.tar.gz
```

## Directory Structure

```
/var/www/blob.thym.it/
├── stt-models/
│   ├── parakeet-v3-int8.tar.gz
│   └── ... (other speech-to-text models)
└── ... (other categories as needed)
```

## Security Considerations

- The directory is served with read-only permissions
- HTTPS is enforced
- No directory listing is enabled by default
- Consider adding basic authentication if sensitive models are hosted

## Maintenance

To update a model:

```bash
# Backup existing model
sudo mv /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz.bak

# Deploy new version
sudo cp /path/to/new-model.tar.gz /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz

# Set permissions
sudo chown nginx:nginx /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz
sudo chmod 644 /var/www/blob.thym.it/stt-models/parakeet-v3-int8.tar.gz
```

## Troubleshooting

If files are not accessible:

1. Check NGINX logs: `journalctl -u nginx -f`
2. Verify file permissions: `ls -la /var/www/blob.thym.it/stt-models/`
3. Check SELinux context if applicable: `ls -Z /var/www/blob.thym.it/`
4. Test NGINX configuration: `sudo nginx -t`
5. Reload NGINX: `sudo systemctl reload nginx`
