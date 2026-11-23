#!/bin/sh
# Writes the S3 identities (one admin key for Worklenz, anonymous read-only for
# the bucket so avatars and logos load) and starts SeaweedFS in mini mode.
set -e
: "${S3_SECRET_ACCESS_KEY:?S3_SECRET_ACCESS_KEY is not set}"
umask 077
mkdir -p /etc/seaweedfs-railway
cat > /etc/seaweedfs-railway/s3.json <<JSON
{
  "identities": [
    {
      "name": "worklenz",
      "credentials": [{ "accessKey": "${S3_ACCESS_KEY_ID}", "secretKey": "${S3_SECRET_ACCESS_KEY}" }],
      "actions": ["Admin", "Read", "Write", "List", "Tagging"]
    },
    {
      "name": "anonymous",
      "actions": ["Read:${S3_BUCKET}"]
    }
  ]
}
JSON
chown -R seaweed:seaweed /etc/seaweedfs-railway

# Railway's private network is IPv6: listen on :: when the container has a
# non-loopback IPv6 address, otherwise (plain Docker without IPv6) on 0.0.0.0.
BIND=0.0.0.0
if [ -r /proc/net/if_inet6 ] && awk '$6 != "lo" {f=1} END {exit !f}' /proc/net/if_inet6; then
  BIND=::
fi
exec /entrypoint.sh mini -dir=/data \
  -ip=127.0.0.1 -ip.bind="$BIND" \
  -s3.port="${PORT}" \
  -s3.config=/etc/seaweedfs-railway/s3.json \
  -bucket="${S3_BUCKET}" \
  -webdav=false -admin.ui=false \
  -s3.port.iceberg=0 -s3.port.lance=0
