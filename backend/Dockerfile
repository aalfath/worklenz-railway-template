# Worklenz backend (official image), plus a small first-boot step that loads the
# base schema and runs the database migrations before the API starts.
ARG WORKLENZ_COMMIT=ccd4dd283d403e3a83b6a459da2103c490e6f6b4

# The official image ships the migrations but not the base schema, so fetch the
# base SQL files from the same release commit (v3.4.2).
FROM chamikajaycey/worklenz-backend:3.4.2@sha256:d4ce4e4f6bb87d696be363b8d95208350cfa22de40884d2f5fb57cf5238efd4e AS sql
ARG WORKLENZ_COMMIT
RUN mkdir -p /sql && cd /sql && node -e '\
const fs=require("fs");\
const base="https://raw.githubusercontent.com/Worklenz/worklenz/"+process.argv[1]+"/worklenz-backend/database/sql/";\
const files=["0_extensions.sql","1_tables.sql","indexes.sql","4_functions.sql","triggers.sql","3_views.sql","2_dml.sql"];\
(async()=>{for(const f of files){const r=await fetch(base+f);if(!r.ok)throw new Error(f+": HTTP "+r.status);fs.writeFileSync(f,Buffer.from(await r.arrayBuffer()));console.log("fetched",f);}})().catch(e=>{console.error(e);process.exit(1);});' "$WORKLENZ_COMMIT"

FROM chamikajaycey/worklenz-backend:3.4.2@sha256:d4ce4e4f6bb87d696be363b8d95208350cfa22de40884d2f5fb57cf5238efd4e
COPY --from=sql /sql /app/railway/sql
COPY init-db.js start.sh /app/railway/
RUN chmod +x /app/railway/start.sh
ENV NODE_ENV=production \
    PORT=3000 \
    WORKLENZ_DEPLOYMENT_MODE=self_hosted \
    STORAGE_PROVIDER=s3 \
    S3_BUCKET=worklenz-bucket \
    S3_REGION=us-east-1 \
    SESSION_NAME=worklenz.sid \
    DB_MAX_CLIENTS=10 \
    USE_PG_NATIVE=false \
    UV_THREADPOOL_SIZE=2
EXPOSE 3000
ENTRYPOINT []
CMD ["/app/railway/start.sh"]
