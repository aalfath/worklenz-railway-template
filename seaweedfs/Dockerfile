# SeaweedFS (single-process "mini" mode) as Worklenz's S3-compatible file storage.
FROM chrislusf/seaweedfs:4.54@sha256:4b42c212543a0acd4c0e675215ecdcaf62a186ef98def76c7e12701871222d15
COPY start.sh /railway-start.sh
RUN chmod +x /railway-start.sh
ENV PORT=8333 \
    S3_BUCKET=worklenz-bucket \
    S3_ACCESS_KEY_ID=worklenz \
    GOMAXPROCS=2 \
    GOMEMLIMIT=300MiB
EXPOSE 8333
ENTRYPOINT ["/railway-start.sh"]
