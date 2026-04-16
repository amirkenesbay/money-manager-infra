#!/bin/bash
mongosh \
  --username "$MONGO_INITDB_ROOT_USERNAME" \
  --password "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase admin \
  <<EOF
db = db.getSiblingDB('moneyManagerBot');
db.createUser({
  user: '$MONGO_USERNAME',
  pwd: '$MONGO_PASSWORD',
  roles: [{ role: 'readWrite', db: 'moneyManagerBot' }]
});
EOF
